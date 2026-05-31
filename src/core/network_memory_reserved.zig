// NetworkMemoryReserved — a fixed region of this machine's RAM offered to the cluster.
// Remote machines allocate into this zone via network requests. The zone is
// carved from the OS at startup and never changes size at runtime.
//
// Sits alongside the local allocator pool — they are separate regions:
//   Local pool             → your program allocates here (fast, no network)
//   Network memory reserved → remote machines allocate here (served over TCP)
//
// TODO: implement startup carving, inbound alloc/free request queues,
// peer table storage, and mlock to prevent OS from swapping the zone out.
