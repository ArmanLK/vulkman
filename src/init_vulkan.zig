const stb = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cInclude("stb/stb_image.h");
});

const std = @import("std");

const V = @import("vg.zig");
const vg = V.c;
const Err = V.Err;
const res_to_err = V.vk_res_to_err;

pub const InstanceOptions = struct {
    app_name: [:0]const u8 = "vulkman",
    app_ver: u32 = vg.VK_MAKE_VERSION(0, 0, 0),
    engine_name: ?[:0]const u8 = null,
    engine_ver: u32 = vg.VK_MAKE_VERSION(0, 0, 0),
    api_version: u32 = vg.VK_MAKE_VERSION(1, 3, 0),
    debug: bool = false,
    debug_callback: vg.PFN_vkDebugUtilsMessengerCallbackEXT = null,
    extensions: []const [*c]const u8 = &.{},
    alloc_callback: ?*vg.VkAllocationCallbacks = null,
};

pub const Instance = struct {
    handle: vg.VkInstance,
    debug_messenger: vg.VkDebugUtilsMessengerEXT,
};

pub fn create_instance(alloc: std.mem.Allocator, opts: InstanceOptions) Err!Instance {
    var enable_validation = opts.debug;

    var arena_state = std.heap.ArenaAllocator.init(alloc);
    defer arena_state.deinit();
    const arena = arena_state.allocator();

    var layer_count: u32 = undefined;
    try res_to_err(vg.vkEnumerateInstanceLayerProperties(&layer_count, null));

    // this is not actually immutable
    const layer_props = arena.alloc(
        vg.VkLayerProperties,
        layer_count,
    ) catch return Err.allocator_error;
    try res_to_err(vg.vkEnumerateInstanceLayerProperties(&layer_count, layer_props.ptr));

    var extension_count: u32 = undefined;
    try res_to_err(vg.vkEnumerateInstanceExtensionProperties(&extension_count, null));

    // this is not actually immutable
    const extension_props = arena.alloc(
        vg.VkExtensionProperties,
        layer_count,
    ) catch return Err.allocator_error;
    try res_to_err(vg.vkEnumerateInstanceExtensionProperties(&extension_count, layer_props.ptr));

    var layers = std.ArrayListUnmanaged([*c]const u8){};
    if (enable_validation) {
        enable_validation = for (layer_props) |prop| {
            const layer_name: [*c]const u8 = @ptrCast(prop.layerName[0..]);
            const validation_layer_name: [*c]const u8 = "VK_LAYER_KHRONOS_validation";
            if (std.mem.eql(u8, std.mem.span(validation_layer_name), std.mem.span(layer_name))) {
                layers.append(arena, validation_layer_name) catch return Err.allocator_error;
                break true;
            }
        } else false;
    }

    var extensions = std.ArrayListUnmanaged([*c]const u8){};
    const Finder = struct {
        fn find(name: [*c]const u8, props: []vg.VkExtensionProperties) bool {
            for (props) |prop| {
                const prop_name: [*c]const u8 = @ptrCast(prop.extensionName[0..]);
                if (std.mem.eql(u8, std.mem.span(name), std.mem.span(prop_name))) {
                    return true;
                }
            }
            return false;
        }
    };

    for (opts.extensions) |ext| {
        if (Finder.find(ext, extension_props)) {
            extensions.append(arena, ext) catch return Err.allocator_error;
        } else {
            std.log.err("required extention `{s}` not supported!", .{ext});
        }
    }

    const app_info = std.mem.zeroInit(vg.VkApplicationInfo, .{
        .sType = vg.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .apiVersion = opts.api_version,
        .pApplicationName = opts.application_name,
        .pEngineName = opts.engine_name orelse opts.application_name,
    });

    const instance_info = std.mem.zeroInit(vg.VkInstanceCreateInfo, .{
        .sType = vg.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
        .enabledLayerCount = @as(u32, @intCast(layers.items.len)),
        .ppEnabledLayerNames = layers.items.ptr,
        .enabledExtensionCount = @as(u32, @intCast(extensions.items.len)),
        .ppEnabledExtensionNames = extensions.items.ptr,
    });

    var instance: vg.VkInstance = undefined;
    try res_to_err(vg.vkCreateInstance(&instance_info, opts.alloc_callback, &instance));

    const debug_messenger = if (enable_validation) {} else null;

    return .{ .handle = instance, .debug_messenger = debug_messenger };
}

fn get_function_ptr(comptime Fn: type, instance: vg.VkInstance, name: [*c]const u8) Fn {
    const get_proc_addr: vg.PFN_vkGetInstanceProcAddr = @ptrCast(vg.SDL_Vulkan_GetVkGetInstanceProcAddr());
    if (get_proc_addr) |get_proc_addr_fn| {
        return @ptrCast(get_proc_addr_fn(instance, name));
    }

    @panic("SDL_Vulkan_GetVkGetInstanceProcAddr returned null");
}

fn create_debug_callback(instance: vg.VkInstance, opts: InstanceOptions) Err!vg.VkDebugUtilsMessengerEXT {
    const create_fn_opt: vg.PFN_vkCreateDebugUtilsMessengerEXT = get_function_ptr(
        vg.PFN_vkCreateDebugUtilsMessengerEXT,
        instance,
        "vkCreateDebugUtilsMessengerEXT",
    );

    // I hate this thing!!!
    if (create_fn_opt) |create_fn| {
        const create_info = std.mem.zeroInit(vg.VkDebugUtilsMessengerCreateInfoEXT, .{
            .sType = vg.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
            .messageType = vg.VK_DEBUG_UTILS_MESSAGE_TYPE_DEVICE_ADDRESS_BINDING_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
                vg.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
            .pfnUserCallback = opts.debug_callback orelse V.default_debug_callback,
            .pUserData = null,
        });

        var debug_messenger: vg.VkDebugUtilsMessengerEXT = undefined;
        try res_to_err(create_fn(instance, &create_info, opts.alloc_cb, &debug_messenger));
        std.log.info("Created vulkan debug messenger.", .{});
        return debug_messenger;
    }
    return null;
}
