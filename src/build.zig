const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const kindo = b.addModule("kindo", .{ .root_source_file = b.path("src/allocator.zig"), .target = target, .optimize = optimize });

    const kindo_daemon = b.addExecutable(.{
        .name = "kindo-daemon",
        .root_module = "src/main.zig",
    });
}
