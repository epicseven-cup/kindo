// Profile persistence — serialises DiskProfile (call-site averages + last-run access records) to ~/.local/share/kindo/alloc_profile.bin; checkpoints every 60s and flushes fully on graceful shutdown

pub const CHECKPOINT_INTERVAL_MS: u64 = 60_000;

// Rolling average weights — 80% historical, 20% new observation
pub const PROFILE_HISTORY_WEIGHT: f32 = 0.8;
pub const PROFILE_NEW_WEIGHT:     f32 = 0.2;

// Binary hash mismatch drops confidence to this level; drift detection runs for this long
pub const STALE_BINARY_CONFIDENCE: f32 = 0.3;
pub const DRIFT_DETECTION_MS:      u64 = 30_000;

pub const SCHEMA_VERSION: u16 = 1;
