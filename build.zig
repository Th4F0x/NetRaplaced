const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "netraplaced",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const zhtml_dep = b.dependency("html", .{ .target = target, .optimize = optimize });
    exe.root_module.addImport("html", zhtml_dep.module("html"));

    b.installArtifact(exe);

    // run comand "zig build run"
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run");
    run_step.dependOn(&run_exe.step);
}
