// 32-byte BlockHeader prefixing every allocated block — fields largest-first to
// avoid implicit padding; comptime size assertion ensures exact layout

pub const BlockHeader = struct {
    size:     u64,    // payload size in bytes
    base:     u64,    // absolute address of this block (points to header, not payload)
    next_ptr: u64,    // next free block in free list (encoded pointer, 0 = none)
    owner_id: u16,    // machine ID of allocating machine
    free:     u8,     // 0=allocated, 1=free
    _padding: [5]u8,
};

comptime {
    if (@sizeOf(BlockHeader) != 32)
        @compileError("BlockHeader must be exactly 32 bytes");
    if (@offsetOf(BlockHeader, "size")     != 0)  @compileError("size must be at offset 0");
    if (@offsetOf(BlockHeader, "base")     != 8)  @compileError("base must be at offset 8");
    if (@offsetOf(BlockHeader, "next_ptr") != 16) @compileError("next_ptr must be at offset 16");
    if (@offsetOf(BlockHeader, "owner_id") != 24) @compileError("owner_id must be at offset 24");
    if (@offsetOf(BlockHeader, "free")     != 26) @compileError("free must be at offset 26");
}
