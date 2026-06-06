const std = @import("std");

// Local allocator — three tier allocation strategy:
//
//   1. Thread local bin cache (t_bins) — freed blocks per size class, no lock
//   2. Thread local bump pointer (thread_chunk) — carve from 64kb chunk, no lock
//   3. Main pool mutex — only hit when thread chunk is exhausted
//
// alloc: check t_bins[class] → bump thread_chunk → lock + get new chunk
// free:  push onto t_bins[class], no lock
//
// Size classes: 64b, 256b, 1kb, 4kb, 64kb, 1mb (matches slab allocator)
// Allocations larger than 1mb go directly to the main pool.

// TODO: add t_bins threadlocal array — one *BlockHeader free list per size class
threadlocal var thread_chunk: []u8 = &.{};
threadlocal var thread_index: usize = 0;

const CHUNK_SIZE = 1024 * 64;

// zig fmt: off
const AllocatorError = error {
    InvalidFree,
};

pub const LocalAllocator = struct {
    limit: usize,
    memory_allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,
    memory_used: usize,

    pub fn init(limit: usize, allocator_interface: std.mem.Allocator) LocalAllocator {
        return LocalAllocator {
            .limit  = limit,
            .memory_allocator = allocator_interface,
            .mutex = std.Thread.Mutex{},
            .memory_used =  0,
        };
    }

    fn vtableAlloc(ctx: *anyopaque, len:usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
        const self: *LocalAllocator = @ptrCast(@alignCast(ctx));
        _ = ptr_align; _ = ret_addr;
        const block = self.alloc(len) catch return null;
        return @ptrCast(block);
    }

    fn vtableFree(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
        const self: *LocalAllocator = @ptrCast(@alignCast(ctx));
        _ = buf_align; _ = ret_addr;
        self.free(buf) catch {};
    }

    fn vtableResize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
        _ = ctx; _ = buf; _ =  buf_align; _ = new_len; _ = ret_addr;
        return false;
    }

    pub fn allocator(self: *LocalAllocator) std.mem.Allocator {
        return std.mem.Allocator {
            .ptr = self,
            .vtable = &.{
                .alloc = vtableAlloc,
                .free = vtableFree,
                .resize = vtableResize,
            },
        };
    }


    pub fn alloc(self: *LocalAllocator, size: usize) ![]u8 {
        // Locking the allocator so we dont get race conditions when allocating/deallocating memory checking limits

        var ptr: []u8 = undefined;
        if (thread_index + size >= thread_chunk.len){
            ptr = thread_chunk[thread_index..thread_index+size];
            thread_index += size;
            return ptr;
        }

        self.mutex.lock(); defer self.mutex.unlock();
        if (self.memory_used + size > self.limit) {
            return error.OutOfMemory;
        }

        thread_chunk = try self.memory_allocator.alloc(u8, CHUNK_SIZE);
        thread_index = 0;

        ptr = thread_chunk[thread_index..thread_index+size];
        // keeping track of the pointer index
        thread_index += size;

        // Assuming that it is using all the chunk
        self.memory_used += CHUNK_SIZE;
        return ptr;
    }

    pub fn free(self: *LocalAllocator, ptr: []u8) !void {
        self.mutex.lock(); defer self.mutex.unlock();
        if (self.memory_used < ptr.len) {
            std.debug.print("Memory used is less than the size of the block freed {} < {} \n", .{ self.memory_used, ptr.len });
            return AllocatorError.InvalidFree;
        }
        self.memory_allocator.free(ptr);
        self.memory_used -= ptr.len;
    }
};
// zig fmt: on
