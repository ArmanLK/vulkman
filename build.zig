const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const triangle = b.addExecutable(.{
        .name = "triangle",
        //.root_source_file = b.path("src/vulkman.cpp"),
        .target = target,
        .optimize = optimize,
        //.use_lld = true,
        //.pic = true,
        .linkage = .dynamic,
    });
    triangle.linkLibCpp();
    triangle.linkSystemLibrary("vulkan");
    triangle.linkSystemLibrary("glfw");
    triangle.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/triangle.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(triangle);

    const run_cmd = b.addRunArtifact(triangle);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("triangle", "Run the triangle demo");
    run_step.dependOn(&run_cmd.step);
}
