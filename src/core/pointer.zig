// Pointer encoding — packs a 16-bit machine ID into the top bits and a 48-bit
// offset into the bottom bits of a u64; machine ID 0 is always local

pub const LOCAL_MACHINE_ID: u16 = 0;

pub const Pointer = packed struct {
    offset:     u48,
    machine_id: u16,

    pub fn isLocal(self: Pointer) bool {
        return self.machine_id == LOCAL_MACHINE_ID;
    }
};

pub fn encode(machine_id: u16, off: u48) u64 {
    return (@as(u64, machine_id) << 48) | @as(u64, off);
}

pub fn machineId(ptr: u64) u16 {
    return @truncate(ptr >> 48);
}

pub fn offset(ptr: u64) u48 {
    return @truncate(ptr);
}

pub fn isLocal(ptr: u64) bool {
    return machineId(ptr) == LOCAL_MACHINE_ID;
}
