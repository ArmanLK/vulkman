const cglm = @cImport({
    @cInclude("cglm/vec4.h");
    @cInclude("cglm/mat2.h");
    @cInclude("cglm/mat4.h");
});

const std = @import("std");
const init = @import("init_vulkan.zig");

const Allocator = std.mem.Allocator;
var GPA = std.heap.GeneralPurposeAllocator(.{}){};
const gallocator = GPA.allocator();

const Vertex = struct {
    pos: cglm.vec2,
    color: cglm.vec2,
    texCoord: cglm.vec2,
};

const UBO = struct {
    model: cglm.mat4 align(16),
    view: cglm.mat4 align(16),
    proj: cglm.mat4 align(16),
};

pub fn main() void {
    return;
}
