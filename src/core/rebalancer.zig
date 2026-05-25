// Rebalancer — background thread that scans the access table and pulls hot blocks local or evicts cold blocks remote; holds migration_mutex only during the atomic ptr flip, not during the byte copy

// Confidence adjustment rates — slow to trust, fast to distrust
pub const CONFIDENCE_HIT:   f32 = 0.05;
pub const CONFIDENCE_MISS:  f32 = 0.20;
pub const CONFIDENCE_INIT:  f32 = 0.50;

// Minimum confidence required before acting on a profile entry
pub const CONFIDENCE_MIN_ACT: f32 = 0.30;

// Access count thresholds for locality classification
pub const HOT_ACCESS_THRESHOLD:  u32 = 100;
pub const WARM_ACCESS_THRESHOLD: u32 = 20;
pub const COLD_ACCESS_MAX:       u32 = 5;
