// LocalPool — GPA-backed on-demand allocator for local blocks; prepends a 32-byte
// BlockHeader before every payload; stores the block's absolute address in
// Pointer.offset (fits in u48 on x86_64); no upfront memory commitment

const std = @import("std");

pub fn LocalAllocator(allocator: std.mem.Allocator) RemoteBlock {
    return
}
