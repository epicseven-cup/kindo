# kindo

A distributed memory allocator written in Zig. Programs allocate memory using a typed wrapper — `RemoteBlock(T)` — that works the same whether the block lives locally or on a remote machine. When local memory is exhausted the allocator spills into remote machines on the network transparently.

## What it does

Every machine in your cluster is sitting on gigabytes of unused memory. Install one binary on every machine. Each machine contributes some of its unused RAM to a shared pool. Any program on any machine can use that pooled memory when it runs out locally.

No new hardware. No cloud costs. Just the RAM you already own.

## How it works

```
Program
    ↓
Distributed Allocator
    ├── Local pool     ← fast, no network, your program allocates here
    └── Network zone   ← your unused RAM, offered to the cluster
```

Remote memory access is explicit — `RemoteBlock(T)` makes the cost visible at the call site:

```zig
const allocator = try DistributedAllocator.init(.{ .seed = "192.168.1.10:7777" });

const buf: RemoteBlock(u8) = try allocator.alloc(u8, 1024, .{});
defer buf.free();

var val = try buf.read(0);   // 1 network call
val += 1;
try buf.write(0, val);       // 1 network call
```

The allocator learns access patterns across runs and pre-places blocks in the right location from the start. Hot blocks are pulled local automatically. Cold blocks stay remote.

## Status

Early development — Phase 1 (single machine, no network) in progress. Not yet usable.
