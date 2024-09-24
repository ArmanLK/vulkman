const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vulkman = b.addExecutable(.{
        .name = "vulkman",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    vulkman.linkLibCpp();
    vulkman.linkSystemLibrary("vulkan");
    vulkman.linkSystemLibrary("glfw");
    vulkman.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/vulkman.cpp",
        },
        .flags = &.{
            "-std=c++20",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(vulkman);

    const vulkman_run_cmd = b.addRunArtifact(vulkman);

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
            "src/exp/triangle.cpp",
        },
        .flags = &.{
            "-std=c++20",
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
            "src/exp/rectangle.cpp",
        },
        .flags = &.{
            "-std=c++20",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(rectangle);

    const rectangle_run_cmd = b.addRunArtifact(rectangle);

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
            "src/exp/rectangle_3d.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werror",
        },
    });

    b.installArtifact(rectangle_3d);

    const rectangle_3d_run_cmd = b.addRunArtifact(rectangle_3d);

    const image = b.addExecutable(.{
        .name = "image",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    image.linkLibCpp();
    image.linkSystemLibrary("vulkan");
    image.linkSystemLibrary("glfw");
    image.addCSourceFiles(.{
        .root = .{ .cwd_relative = "" },
        .files = &.{
            "src/exp/image.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Werror",
            "-Iinclude/",
        },
    });

    b.installArtifact(image);

    const image_run_cmd = b.addRunArtifact(image);

    if (b.args) |args| {
        vulkman_run_cmd.addArgs(args);
        triangle_run_cmd.addArgs(args);
        rectangle_run_cmd.addArgs(args);
        rectangle_3d_run_cmd.addArgs(args);
        image_run_cmd.addArgs(args);
    }

    vulkman_run_cmd.step.dependOn(b.getInstallStep());
    triangle_run_cmd.step.dependOn(b.getInstallStep());
    rectangle_run_cmd.step.dependOn(b.getInstallStep());
    rectangle_3d_run_cmd.step.dependOn(b.getInstallStep());

    const vulkman_run_step = b.step("run", "Run the main app");
    vulkman_run_step.dependOn(&vulkman_run_cmd.step);

    const triangle_run_step = b.step("triangle", "Run the triangle demo");
    triangle_run_step.dependOn(&triangle_run_cmd.step);

    const rectangle_run_step = b.step("rectangle", "Run the rectangle demo");
    rectangle_run_step.dependOn(&rectangle_run_cmd.step);

    const rectangle_3d_run_step = b.step("rectangle_3d", "Run the 3d rectangle demo");
    rectangle_3d_run_step.dependOn(&rectangle_3d_run_cmd.step);

    const image_run_step = b.step("image", "Run the image demo");
    image_run_step.dependOn(&image_run_cmd.step);
}
