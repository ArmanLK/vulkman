const std = @import("std");

pub const vg = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("vulkan/vulkan.h");
    @cInclude("GLFW/glfw3.h");
});

pub const Err = error{
    allocator_error,
    vk_not_ready,
    vk_timeout,
    vk_event_set,
    vk_event_reset,
    vk_incomplete,
    vk_error_out_of_host_memory,
    vk_error_out_of_device_memory,
    vk_error_initialization_failed,
    vk_error_device_lost,
    vk_error_memory_map_failed,
    vk_error_layer_not_present,
    vk_error_extension_not_present,
    vk_error_feature_not_present,
    vk_error_incompatible_driver,
    vk_error_too_many_objects,
    vk_error_format_not_supported,
    vk_error_fragmented_pool,
    vk_error_unknown,
    vk_error_out_of_pool_memory,
    vk_error_invalid_external_handle,
    vk_error_fragmentation,
    vk_error_invalid_opaque_capture_address,
    vk_pipeline_compile_required,
    vk_error_surface_lost_khr,
    vk_error_native_window_in_use_khr,
    vk_suboptimal_khr,
    vk_error_out_of_date_khr,
    vk_error_incompatible_display_khr,
    vk_error_validation_failed_ext,
    vk_error_invalid_shader_nv,
    vk_error_image_usage_not_supported_khr,
    vk_error_video_picture_layout_not_supported_khr,
    vk_error_video_profile_operation_not_supported_khr,
    vk_error_video_profile_format_not_supported_khr,
    vk_error_video_profile_codec_not_supported_khr,
    vk_error_video_std_version_not_supported_khr,
    vk_error_invalid_drm_format_modifier_plane_layout_ext,
    vk_error_not_permitted_khr,
    vk_error_full_screen_exclusive_mode_lost_ext,
    vk_thread_idle_khr,
    vk_thread_done_khr,
    vk_operation_deferred_khr,
    vk_operation_not_deferred_khr,
    vk_error_compression_exhausted_ext,
    vk_error_incompatible_shader_binary_ext,
};

pub fn vk_res_to_err(res: vg.VkResult) Err {
    return switch (res) {
        vg.VK_SUCCESS => {},
        vg.VK_NOT_READY => error.vk_not_ready,
        vg.VK_TIMEOUT => error.vk_timeout,
        vg.VK_EVENT_SET => error.vk_event_set,
        vg.VK_EVENT_RESET => error.vk_event_reset,
        vg.VK_INCOMPLETE => error.vk_incomplete,
        vg.VK_ERROR_OUT_OF_HOST_MEMORY => error.vk_error_out_of_host_memory,
        vg.VK_ERROR_OUT_OF_DEVICE_MEMORY => error.vk_error_out_of_device_memory,
        vg.VK_ERROR_INITIALIZATION_FAILED => error.vk_error_initialization_failed,
        vg.VK_ERROR_DEVICE_LOST => error.vk_error_device_lost,
        vg.VK_ERROR_MEMORY_MAP_FAILED => error.vk_error_memory_map_failed,
        vg.VK_ERROR_LAYER_NOT_PRESENT => error.vk_error_layer_not_present,
        vg.VK_ERROR_EXTENSION_NOT_PRESENT => error.vk_error_extension_not_present,
        vg.VK_ERROR_FEATURE_NOT_PRESENT => error.vk_error_feature_not_present,
        vg.VK_ERROR_INCOMPATIBLE_DRIVER => error.vk_error_incompatible_driver,
        vg.VK_ERROR_TOO_MANY_OBJECTS => error.vk_error_too_many_objects,
        vg.VK_ERROR_FORMAT_NOT_SUPPORTED => error.vk_error_format_not_supported,
        vg.VK_ERROR_FRAGMENTED_POOL => error.vk_error_fragmented_pool,
        vg.VK_ERROR_UNKNOWN => error.vk_error_unknown,
        vg.VK_ERROR_OUT_OF_POOL_MEMORY => error.vk_error_out_of_pool_memory,
        vg.VK_ERROR_INVALID_EXTERNAL_HANDLE => error.vk_error_invalid_external_handle,
        vg.VK_ERROR_FRAGMENTATION => error.vk_error_fragmentation,
        vg.VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS => error.vk_error_invalid_opaque_capture_address,
        vg.VK_PIPELINE_COMPILE_REQUIRED => error.vk_pipeline_compile_required,
        vg.VK_ERROR_SURFACE_LOST_KHR => error.vk_error_surface_lost_khr,
        vg.VK_ERROR_NATIVE_WINDOW_IN_USE_KHR => error.vk_error_native_window_in_use_khr,
        vg.VK_SUBOPTIMAL_KHR => error.vk_suboptimal_khr,
        vg.VK_ERROR_OUT_OF_DATE_KHR => error.vk_error_out_of_date_khr,
        vg.VK_ERROR_INCOMPATIBLE_DISPLAY_KHR => error.vk_error_incompatible_display_khr,
        vg.VK_ERROR_VALIDATION_FAILED_EXT => error.vk_error_validation_failed_ext,
        vg.VK_ERROR_INVALID_SHADER_NV => error.vk_error_invalid_shader_nv,
        vg.VK_ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR => error.vk_error_image_usage_not_supported_khr,
        vg.VK_ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR => error.vk_error_video_picture_layout_not_supported_khr,
        vg.VK_ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR => error.vk_error_video_profile_operation_not_supported_khr,
        vg.VK_ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR => error.vk_error_video_profile_format_not_supported_khr,
        vg.VK_ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR => error.vk_error_video_profile_codec_not_supported_khr,
        vg.VK_ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR => error.vk_error_video_std_version_not_supported_khr,
        vg.VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT => error.vk_error_invalid_drm_format_modifier_plane_layout_ext,
        vg.VK_ERROR_NOT_PERMITTED_KHR => error.vk_error_not_permitted_khr,
        vg.VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT => error.vk_error_full_screen_exclusive_mode_lost_ext,
        vg.VK_THREAD_IDLE_KHR => error.vk_thread_idle_khr,
        vg.VK_THREAD_DONE_KHR => error.vk_thread_done_khr,
        vg.VK_OPERATION_DEFERRED_KHR => error.vk_operation_deferred_khr,
        vg.VK_OPERATION_NOT_DEFERRED_KHR => error.vk_operation_not_deferred_khr,
        vg.VK_ERROR_COMPRESSION_EXHAUSTED_EXT => error.vk_error_compression_exhausted_ext,
        vg.VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT => error.vk_error_incompatible_shader_binary_ext,
        else => error.vk_errror_unknown,
    };
}

pub fn default_debug_callback(
    severity: vg.VkDebugUtilsMessageSeverityFlagBitsEXT,
    msg_type: vg.VkDebugUtilsMessageTypeFlagsEXT,
    callback_data: ?*const vg.VkDebugUtilsMessengerCallbackDataEXT,
    user_data: ?*anyopaque,
) callconv(.C) vg.VkBool32 {
    _ = user_data;

    const type_str = switch (msg_type) {
        vg.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT => "general",
        vg.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT => "validation",
        vg.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT => "performance",
        vg.VK_DEBUG_UTILS_MESSAGE_TYPE_DEVICE_ADDRESS_BINDING_BIT_EXT => "device address",
        else => "unknown",
    };

    const message: [*c]const u8 = if (callback_data) |cb_data| cb_data.pMessage else "NO MESSAGE!";

    const fmt = "{}. {s}\n";
    const opts = .{ type_str, message };
    switch (severity) {
        vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT => std.log.info(fmt, opts),
        vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT => std.log.info(fmt, opts),
        vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT => std.log.warn(fmt, opts),
        vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT => std.log.err(fmt, opts),
        else => "unknown",
    }

    if (severity >= vg.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT) {
        // wut?
        @panic("Unrecoverable vulkan error.");
    }

    return vg.VK_FALSE;
}
