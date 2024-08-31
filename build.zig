const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cglm = b.addStaticLibrary(.{
        .name = "cglm",
        .target = target,
        .optimize = b.standardOptimizeOption(.{
            .preferred_optimize_mode = .ReleaseSafe,
        }),
    });
    cglm.linkLibC();
    cglm.addIncludePath(.{
        .cwd_relative = "lib/cglm/include/",
    });
    cglm.addCSourceFiles(.{
        .root = .{
            .cwd_relative = "lib/cglm/",
        },
        .files = &.{
            "src/euler.c",
            "src/affine.c",
            "src/io.c",
            "src/quat.c",
            "src/cam.c",
            "src/vec2.c",
            "src/ivec2.c",
            "src/vec3.c",
            "src/ivec3.c",
            "src/vec4.c",
            "src/ivec4.c",
            "src/mat2.c",
            "src/mat2x3.c",
            "src/mat2x4.c",
            "src/mat3.c",
            "src/mat3x2.c",
            "src/mat3x4.c",
            "src/mat4.c",
            "src/mat4x2.c",
            "src/mat4x3.c",
            "src/plane.c",
            "src/frustum.c",
            "src/box.c",
            "src/project.c",
            "src/sphere.c",
            "src/ease.c",
            "src/curve.c",
            "src/bezier.c",
            "src/ray.c",
            "src/affine2d.c",
            "src/clipspace/ortho_lh_no.c",
            "src/clipspace/ortho_lh_zo.c",
            "src/clipspace/ortho_rh_no.c",
            "src/clipspace/ortho_rh_zo.c",
            "src/clipspace/persp_lh_no.c",
            "src/clipspace/persp_lh_zo.c",
            "src/clipspace/persp_rh_no.c",
            "src/clipspace/persp_rh_zo.c",
            "src/clipspace/view_lh_no.c",
            "src/clipspace/view_lh_zo.c",
            "src/clipspace/view_rh_no.c",
            "src/clipspace/view_rh_zo.c",
            "src/clipspace/project_no.c",
            "src/clipspace/project_zo.c",
        },
        .flags = &.{
            "-Wall",
            "-Werror",
            "-std=c11",
        },
    });
    b.installArtifact(cglm);

    const vulkman = b.addExecutable(.{
        .name = "vulkman",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
        .root_source_file = .{
            .cwd_relative = "src/main.zig",
        },
    });
    vulkman.linkLibrary(cglm);
    vulkman.linkSystemLibrary("vulkan");
    vulkman.linkSystemLibrary("glfw");

    b.installArtifact(vulkman);

    const triangle = b.addExecutable(.{
        .name = "triangle",
        .target = target,
        .optimize = optimize,
        .linkage = .dynamic,
    });

    const vulkman_run_cmd = b.addRunArtifact(vulkman);

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
            "src/image.cpp",
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
