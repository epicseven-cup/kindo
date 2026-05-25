// Slab allocator — pre-allocates contiguous slabs on remote machines; individual alloc/free within a slab cost zero network calls via a local free bitmap; six size classes 64b–1mb; whole-slab release sends one FreeSlabRequest

pub const NUM_SIZE_CLASSES: usize = 6;

pub const SIZE_CLASS_BYTES: [NUM_SIZE_CLASSES]usize = .{
    64,            // class 0 — small structs, short strings
    256,           // class 1 — medium buffers
    1 * 1024,      // class 2 — typical page-like objects
    4 * 1024,      // class 3 — page-sized
    64 * 1024,     // class 4 — large buffers
    1 * 1024 * 1024, // class 5 — bulk allocations
};
