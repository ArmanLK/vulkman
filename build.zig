const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "vulkman",
        //.root_source_file = b.path("src/vulkman.cpp"),
        .target = target,
        .optimize = optimize,
        .use_lld = true,
        .pic = true,
        .linkage = .dynamic,
    });
    exe.linkLibCpp();
    exe.linkSystemLibrary("vulkan");
    exe.linkSystemLibrary("glfw");
    exe.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/vulkman.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werr",
            "-Wextra",
        },
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
