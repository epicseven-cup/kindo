const std = @import("std");
// zig fmt: off
pub const LocalAllocator = struct {
    limit: usize,
    allocator: std.mem.Allocator,
    memory_used: usize,

    pub fn alloc(self: *LocalAllocator, size: usize) ![]u8 {
        if (self.memory_used + size > self.limit) {
            return error.OutOfMemory;
        }
        const block = try self.allocator.alloc(u8, size);
        self.memory_used += size;
        return block;
    }

    pub fn free(self: *LocalAllocator, ptr: []u8) void {
        self.allocator.free(ptr);
        self.memory_used -= ptr.len;
    }
};
// zig fmt: on
