const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const triangle = b.addExecutable(.{
        .name = "triangle",
        .target = target,
        .optimize = optimize,
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

    const triangle_run_cmd = b.addRunArtifact(triangle);

    const rectangle = b.addExecutable(.{
        .name = "rectangle",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    rectangle.linkLibCpp();
    rectangle.linkSystemLibrary("vulkan");
    rectangle.linkSystemLibrary("glfw");
    rectangle.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/rectangle.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(rectangle);

    const rectangle_run_cmd = b.addRunArtifact(rectangle);

    triangle_run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        triangle_run_cmd.addArgs(args);
        rectangle_run_cmd.addArgs(args);
    }

    const triangle_run_step = b.step("triangle", "Run the triangle demo");
    triangle_run_step.dependOn(&triangle_run_cmd.step);

    const rectangle_run_step = b.step("rectangle", "Run the rectangle demo");
    rectangle_run_step.dependOn(&rectangle_run_cmd.step);
}
