const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const core_module = b.createModule(.{
        .root_source_file = b.path("src/core/mod.zig"),
        .target = target,
        .optimize = optimize,
    });

    const kindo_module = b.createModule(.{
        .root_source_file = b.path("src/kindo.zig"),
        .target = target,
        .optimize = optimize,
    });
    kindo_module.addImport("core", core_module);

    const daemon_module = b.createModule(.{
        .root_source_file = b.path("src/daemon.zig"),
        .target = target,
        .optimize = optimize,
    });
    daemon_module.addImport("core", core_module);
    daemon_module.addImport("kindo", kindo_module);

    const daemon_exe = b.addExecutable(.{
        .name = "kindo-daemon",
        .root_module = daemon_module,
    });
    b.installArtifact(daemon_exe);

    const run_cmd = b.addRunArtifact(daemon_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    b.step("run", "Run the kindo daemon").dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");

    const simulator_module = b.createModule(.{
        .root_source_file = b.path("tests/simulator.zig"),
        .target = target,
        .optimize = optimize,
    });

    // inline tests inside src/ files
    const src_test_files = &[_][]const u8{
        "src/core/mod.zig",
        "src/kindo.zig",
        "src/daemon.zig",
    };
    for (src_test_files) |src| {
        const mod = b.createModule(.{
            .root_source_file = b.path(src),
            .target = target,
            .optimize = optimize,
        });
        mod.addImport("core", core_module);
        mod.addImport("kindo", kindo_module);
        const t = b.addTest(.{ .root_module = mod });
        test_step.dependOn(&b.addRunArtifact(t).step);
    }

    // tests/ — one file per subsystem
    const subsystem_tests = &[_][]const u8{
        "tests/test_local.zig",
        "tests/test_wire.zig",
        "tests/test_slab.zig",
        "tests/test_rebalancer.zig",
        "tests/test_profile.zig",
    };
    for (subsystem_tests) |src| {
        const mod = b.createModule(.{
            .root_source_file = b.path(src),
            .target = target,
            .optimize = optimize,
        });
        mod.addImport("core", core_module);
        mod.addImport("kindo", kindo_module);
        mod.addImport("simulator", simulator_module);
        const t = b.addTest(.{ .root_module = mod });
        test_step.dependOn(&b.addRunArtifact(t).step);
    }
}
