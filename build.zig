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

    const rectangle_3d = b.addExecutable(.{
        .name = "rectangle_3d",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    rectangle_3d.linkLibCpp();
    rectangle_3d.linkSystemLibrary("vulkan");
    rectangle_3d.linkSystemLibrary("glfw");
    rectangle_3d.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/rectangle_3d.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(rectangle_3d);

    const rectangle_3d_run_cmd = b.addRunArtifact(rectangle_3d);

    triangle_run_cmd.step.dependOn(b.getInstallStep());
    rectangle_run_cmd.step.dependOn(b.getInstallStep());
    rectangle_3d_run_cmd.step.dependOn(b.getInstallStep());

    const triangle_run_step = b.step("triangle", "Run the triangle demo");
    triangle_run_step.dependOn(&triangle_run_cmd.step);

    const rectangle_run_step = b.step("rectangle", "Run the rectangle demo");
    rectangle_run_step.dependOn(&rectangle_run_cmd.step);

    const rectangle_3d_run_step = b.step("rectangle_3d", "Run the rectangle demo");
    rectangle_3d_run_step.dependOn(&rectangle_3d_run_cmd.step);
}
