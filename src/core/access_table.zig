// AccessTable — per-block access records (count, last access, pattern, locality, confidence) stored locally on the owner machine; updated on every read/write at zero network cost; feeds the rebalancer

pub const AccessPattern = enum(u8) {
    random     = 0,
    sequential = 1,
    repeated   = 2,
    bulk       = 3,
};

pub const Locality = enum(u8) {
    cold = 0,
    warm = 1,
    hot  = 2,
};
