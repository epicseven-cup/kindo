// 32-byte BlockHeader prefixing every allocated block — fields largest-first to
// avoid implicit padding; comptime size assertion ensures exact layout


pub const BlockHeader = struct {
    size: u64,
    base: u64,
    next_ptr: u64,
    owner_id: u16,
    free: bool,
    _padding: [5]u8
};



comptime {
    if (@sizeOf(BlockHeader) != 32) {
        @compileError("BlockHeader must be exactly 32 bytes");
    }
}
