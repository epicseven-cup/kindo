// Wire format — 14-byte packed WireHeader (version, msg_type, msg_id, msg_size) plus typed payload structs;
// msg_size capped at MAX_MSG_SIZE (64mb) before any allocation to prevent DoS via crafted headers

pub const WireHeader = packed struct { version: u8, msg_type: u8, msg_id: u64, msg_size: u32 };

pub const AllocRequest = packed struct { size: u64, owner_id: u16 };

pub const AllocResponse = packed struct { ptr: u64, base: u64, success: u8 };

pub const AllocSlabRequest = packed struct { size_class: u8, num_slots: u32, owner_id: u16 };

pub const AllocSlabResponse = packed struct { base: u64, actual_slots: u32, success: u8 };

pub const FreeSlabRequest = packed struct { base: u64, size_class: u8, owner_id: u16 };

pub const ReadRequest = packed struct { ptr: u64, size: u64, block_base: u64 };

pub const ReadResponse = packed struct { success: u8 };

pub const WriteRequest = packed struct { ptr: u64, size: u64, block_base: u64 };

pub const WriteResponse = packed struct { success: u8 };

pub const FreeRequest = packed struct { ptr: u64, size: u64, owner_id: u16 };

pub const PingBlock = packed struct { ptr: u64, base: u64 };

pub const PingResponse = packed struct { exists: u8, owner_id: u16 };

pub const BatchPingRequest = packed struct { count: u32 };

pub const BatchPingResponse = packed struct { count: u32 };

comptime {
    if (@sizeOf(WireHeader) != 14) @compileError("WireHeader size is incorrect");
}
