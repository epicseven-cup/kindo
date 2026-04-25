const std = @import("std");

pub const SimulatedMachine = struct {
    id: u16,
};

pub const InFlightMessage = struct {
    from: u16,
    to: u16,
    tick_deliver: u64,
    bytes: []const u8,
};

pub const Simulator = struct {
    rng: std.rand.DefaultPrng,
    tick: u64,
    machines: std.AutoHashMap(u16, SimulatedMachine),
    in_flight: std.ArrayList(InFlightMessage),
    drop_rate: f32,
    partition: ?[2]u16,
    ally: std.mem.Allocator,

    pub fn init(ally: std.mem.Allocator, seed: u64) Simulator {
        return .{
            .rng = std.rand.DefaultPrng.init(seed),
            .tick = 0,
            .machines = std.AutoHashMap(u16, SimulatedMachine).init(ally),
            .in_flight = std.ArrayList(InFlightMessage).init(ally),
            .drop_rate = 0.0,
            .partition = null,
            .ally = ally,
        };
    }

    pub fn deinit(self: *Simulator) void {
        self.machines.deinit();
        self.in_flight.deinit();
    }

    pub fn advance(self: *Simulator) void {
        self.tick += 1;
    }

    pub fn addMachine(self: *Simulator, id: u16) !void {
        try self.machines.put(id, .{ .id = id });
    }

    pub fn partitionBetween(self: *Simulator, a: u16, b: u16) void {
        self.partition = .{ a, b };
    }

    pub fn heal(self: *Simulator) void {
        self.partition = null;
    }
};
