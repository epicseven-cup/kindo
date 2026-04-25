// RemoteBlock(T) — comptime generic wrapper returned by alloc(); exposes read/write/copyInto/copyFrom/slice/free;
// migration_mutex lives in heap-allocated RemoteBlockInner so RemoteBlock(T) is safe to copy and return by value
//
//
pub const RemoteBlock = packed struct {

};
