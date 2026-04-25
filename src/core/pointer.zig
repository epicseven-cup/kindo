// Pointer encoding — packs a 16-bit machine ID into the top bits and a 48-bit offset into the bottom bits of a u64; machine ID 0 is always local

pub const LOCAL_MACHINE_ID: u16 = 0;

// Order matters
pub const Pointer = packed struct {
    offset: u48,
    machine_id: u16,

    pub fn isLocal(self: Pointer) bool {
        return self.machine_id == LOCAL_MACHINE_ID;
    }
};
