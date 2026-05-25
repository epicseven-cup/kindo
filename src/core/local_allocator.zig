// LocalPool — GPA-backed on-demand allocator for local blocks; prepends a 32-byte
// BlockHeader before every payload; stores the block's absolute address in
// Pointer.offset (fits in u48 on x86_64); no upfront memory commitment

pub const CHUNK_SIZE: usize = 64 * 1024;

pub const FREE_QUEUE_CAPACITY: usize = 256;

// 70% of predicted peak reserved for hot sites; overflow uses the general pool
pub const HOT_RESERVATION_FACTOR: f32 = 0.7;
