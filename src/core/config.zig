// Startup config — parses CLI flags and optional config file into a Config struct; covers machine ID, pool sizes, port, peer list, seed nodes, mlock flag, idle timeout, and profile path

pub const RebalancerConfig = struct {
    hot_threshold: u32 = 100,
    cold_timeout_ms: u64 = 5_000,
    rebalance_interval_ms: u64 = 2_000,
};

pub const NetworkConfig = struct {
    request_timeout_ms: u64 = 5_000,
    connect_timeout_ms: u64 = 2_000,
};

// Why is the allocation time of all is the same fking thing, this needs to be restructure
pub const TimeoutConfig = struct {
    alloc_timeout_ms: u64 = 5_000,
    read_timeout_ms: u64 = 5_000,
    write_timeout_ms: u64 = 5_000,
    ping_timeout_ms: u64 = 2_000,
    broadcast_timeout_ms: u64 = 3_000,
};

pub const RemoteAllocConfig = struct {
    broadcast_cap: u8 = 16,
};

pub const ProfileConfig = struct {
    checkpoint_interval_ms: u64 = 60_000,
    profile_path: []const u8 = ".local/share/kindo/alloc_profile.bin",
};

pub const SlabConfig = struct {
    slots_per_slab: [6]u32 = .{ 256, 512, 512, 256, 64, 16 },
};

pub const ConnectionConfig = struct {
    idle_timeout_ms: u64 = 30_000,
};

pub const AllocStrategy = enum {
    smart,
    local_only,
    remote_only,
    local_preferred,
    remote_preferred,
};

pub const AllocOptions = struct {
    strategy: AllocStrategy = .smart,
    fallback_local: bool = true,
};
