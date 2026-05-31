const std = @import("std");
// zig fmt: off

const AllocatorError = error {
    InvalidFree,
};

pub const LocalAllocator = struct {
    limit: usize,
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex,
    memory_used: usize,

    pub fn init(limit: usize, allocator_interface: std.mem.Allocator) LocalAllocator {
        return LocalAllocator {
            .limit  = limit,
            .allocator = allocator_interface,
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
        self.mutex.lock(); defer self.mutex.unlock();
        if (self.memory_used + size > self.limit) {
            return error.OutOfMemory;
        }
        const block = try self.allocator.alloc(u8, size);
        self.memory_used += size;
        return block;
    }

    pub fn free(self: *LocalAllocator, ptr: []u8) !void {
        self.mutex.lock(); defer self.mutex.unlock();
        if (self.memory_used < ptr.len) {
            std.debug.print("Memory used is less than the size of the block freed {} < {} \n", .{ self.memory_used, ptr.len });
            return AllocatorError.InvalidFree;
        }
        self.allocator.free(ptr);
        self.memory_used -= ptr.len;
    }
};
// zig fmt: on
