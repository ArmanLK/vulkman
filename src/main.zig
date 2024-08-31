const vg = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("vulkan/vulkan.h");
    @cInclude("GLFW/glfw3.h");
});

const stb = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cInclude("stb/stb_image.h");
});

const std = @import("std");
const builtin = @import("builtin");
const cglm = @cImport({
    @cInclude("cglm/vec4.h");
    @cInclude("cglm/mat2.h");
    @cInclude("cglm/mat4.h");
});

const Allocator = std.mem.Allocator;
var GPA = std.heap.GeneralPurposeAllocator(.{}){};
const gallocator = GPA.allocator();
const gpu_allocator: [*c]const vg.VkAllocationCallbacks = null;

const Err = error{
    AllocatorError,
    ValidationLayersNotAvailable,
    DebugExtentionNotAvailable,
    DebugMessengerCreationFailed,
    InstanceCreationFailed,
};

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

const MAX_FRAMES_IN_FLIGHT = 2;
const validation_layers = .{
    "VK_LAYER_KHRONOS_validation",
};

const device_extentions = .{
    vg.VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

// why this is const? I don't care it's just for testing.
const vertices = .{
    Vertex{
        .pos = .{ -0.5, -0.5 },
        .color = .{ 1.0, 0.0, 0.0 },
        .texCoord = .{ 1.0, 0.0 },
    },
    .{
        .pos = .{ 0.5, -0.5 },
        .color = .{ 0.0, 1.0, 0.0 },
        .texCoord = .{ 0.0, 0.0 },
    },
    .{
        .pos = .{ 0.5, 0.5 },
        .color = .{ 0.0, 0.0, 1.0 },
        .texCoord = .{ 0.0, 1.0 },
    },
    .{
        .pos = .{ -0.5, 0.5 },
        .color = .{ 1.0, 1.0, 1.0 },
        .texCoord = .{ 1.0, 1.0 },
    },
};

const indices = .{ 0, 1, 2, 2, 3, 0 };

const enable_validation_layers: bool = switch (builtin.mode) {
    .Debug => true,
    else => false,
};

var width: c_int = 800;
var height: c_int = 600;

pub fn main() Err!void {
    // deinit GPA
    defer {
        defer switch (GPA.deinit()) {
            .ok => {},
            .leak => {
                _ = GPA.detectLeaks();
            },
        };
    }

    // init glfw
    const glfw_res = vg.glfwInit();
    assert(glfw_res == vg.GLFW_TRUE);
    defer vg.glfwTerminate();

    vg.glfwWindowHint(vg.GLFW_CLIENT_API, vg.GLFW_NO_API);
    vg.glfwWindowHint(vg.GLFW_RESIZABLE, vg.GLFW_FALSE);

    // init window
    const window = vg.glfwCreateWindow(
        width,
        height,
        "Triangle",
        null,
        null,
    );
    defer vg.glfwDestroyWindow(window);

    // init vulkan

    // create instance
    const instance = b: {
        if (enable_validation_layers and !try checkValidationLayerSupport()) {
            std.log.err("validation layers requested, but not available!", .{});
            return Err.ValidationLayersNotAvailable;
        }

        const app_info: vg.VkApplicationInfo = .{
            .sType = vg.VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .pApplicationName = "vulkman",
            .pEngineName = "From Scratch",
            .apiVersion = vg.VK_API_VERSION_1_3,
            .applicationVersion = vg.VK_MAKE_VERSION(0, 0, 0),
            .engineVersion = vg.VK_MAKE_VERSION(0, 0, 0),
        };

        var glfw_extention_count: u32 = 0;
        const glfw_extentions = vg.glfwGetRequiredInstanceExtensions(&glfw_extention_count);

        var extentions = std.ArrayList([*]const u8).initCapacity(
            gallocator,
            glfw_extention_count + 1,
        ) catch return Err.AllocatorError;
        defer extentions.deinit();

        for (glfw_extentions, 0..glfw_extention_count) |extention, _| {
            extentions.append(extention) catch return Err.AllocatorError;
        }
        if (enable_validation_layers) {
            extentions.append(vg.VK_EXT_DEBUG_UTILS_EXTENSION_NAME) catch return Err.AllocatorError;
        }

        var create_info: vg.VkInstanceCreateInfo = .{
            .sType = vg.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &app_info,
            .enabledExtensionCount = @intCast(extentions.items.len),
            .ppEnabledExtensionNames = extentions.items.ptr,
        };

        var debug_create_info: vg.VkDebugUtilsMessengerCreateInfoEXT = .{
            .sType = vg.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            .messageType = vg.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            .pfnUserCallback = debugCallback,
        };

        if (enable_validation_layers) {
            create_info.enabledLayerCount = @intCast(validation_layers.len);
            create_info.ppEnabledLayerNames = @ptrCast(@alignCast(validation_layers));

            create_info.pNext = &debug_create_info;
        } else {
            create_info.enabledLayerCount = 0;
            create_info.pNext = null;
        }

        var instance: vg.VkInstance = undefined;
        if (vg.vkCreateInstance(
            &create_info,
            gpu_allocator,
            &instance,
        ) != vg.VK_SUCCESS) {
            return Err.InstanceCreationFailed;
        }

        break :b instance;
    };

    // setup debug messenger
    const debug_messenger = b: {
        if (!enable_validation_layers) break :b;

        const create_info: vg.VkDebugUtilsMessengerCreateInfoEXT = .{
            .sType = vg.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            .messageType = vg.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            .pfnUserCallback = debugCallback,
        };

        var in_debug_messenger: vg.VkDebugUtilsMessengerEXT = null;
        const func_ptr: vg.PFN_vkCreateDebugUtilsMessengerEXT = @ptrCast(
            vg.vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT"),
        );

        if (func_ptr) |func| {
            if (func(
                instance,
                &create_info,
                gpu_allocator,
                &in_debug_messenger,
            ) != vg.VK_SUCCESS) {
                return Err.DebugMessengerCreationFailed;
            }
        } else return Err.DebugExtentionNotAvailable;

        break :b in_debug_messenger;
    };
    _ = debug_messenger; // autofix

    // main loop
    return;
}

fn assert(check: bool) void {
    if (!check) unreachable;
}

fn checkValidationLayerSupport() Err!bool {
    var layer_count: u32 = 0;
    _ = vg.vkEnumerateInstanceLayerProperties(
        &layer_count,
        null,
    );

    var available_layers = std.ArrayList(vg.VkLayerProperties).initCapacity(
        gallocator,
        layer_count,
    ) catch return Err.AllocatorError;

    defer available_layers.deinit();
    _ = vg.vkEnumerateInstanceLayerProperties(
        &layer_count,
        available_layers.items.ptr,
    );

    // this is safe! trust me future me!
    assert(available_layers.capacity == layer_count);
    available_layers.items.len = layer_count;

    inline for (validation_layers) |layer_name| {
        var layer_found = false;

        for (available_layers.items) |layer_properties| {
            const x = layer_properties.layerName[0..layer_name.len];
            if (std.mem.eql(u8, layer_name, x)) {
                layer_found = true;
                break;
            }
        }

        if (!layer_found) {
            return false;
        }
    }

    return true;
}

fn debugCallback(
    messageSeverity: vg.VkDebugUtilsMessageSeverityFlagBitsEXT,
    messageType: vg.VkDebugUtilsMessageTypeFlagsEXT,
    pCallbackData: [*c]const vg.VkDebugUtilsMessengerCallbackDataEXT,
    pUserData: ?*anyopaque,
) callconv(.C) vg.VkBool32 {
    _ = pUserData;
    _ = messageType;

    if (messageSeverity & vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT != 0) {
        std.log.info("validation layer: {s}", .{pCallbackData.*.pMessage});
    } else if (messageSeverity & vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT != 0) {
        std.log.warn("validation layer: {s}", .{pCallbackData.*.pMessage});
    } else if (messageSeverity & vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT != 0) {
        std.log.err("validation layer: {s}", .{pCallbackData.*.pMessage});
    }

    return vg.VK_FALSE;
}
