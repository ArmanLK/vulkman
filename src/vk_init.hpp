#pragma once

#include <vulkan/vulkan.hpp>

// for now
#define alloc nullptr

#ifndef NDEBUG
#define VULKMAN_ENABLE_VALIDATION_LAYERS
#else
#undef VULKMAN_ENABLE_VALIDATION_LAYERS
#endif

/**
 * I don't need Documentation here, but people say comments are important so
 * here you go.
 */
namespace vman {
// this thing is not actually constant lol.
const std::vector<const char *> validation_layers = {
#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
    "VK_LAYER_KHRONOS_validation",
#endif
};

// this thing is not actually constant lol.
const std::vector<const char *> device_extensions = {
    VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

/** I need tuples but I don't like stl's pair or whatever. */
struct Instance {
    vk::Instance instance;

    // I feel like a c++ magician now.
#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
    VkDebugUtilsMessengerEXT debug_messenger;
#endif

    Instance(std::vector<const char *> extentions,
             PFN_vkDebugUtilsMessengerCallbackEXT callback);
};

vk::PhysicalDevice pick_physical_device(vk::Instance instance,
                                        vk::SurfaceKHR surface);
vk::Device create_logical_device(vk::Instance instance,
                                 vk::PhysicalDevice ph_device,
                                 vk::SurfaceKHR surface);
/** the user of this function is responsible for recreating the swapchain if
 * needed. (typically you call this function more than once.)
 */
vk::SwapchainKHR create_swapchain(vk::Device device,
                                  vk::PhysicalDevice ph_device);
void init_images(vk::Device device, vk::SwapchainKHR swapchain,
                 std::vector<vk::Image> images);
void init_image_views(vk::Device device, vk::SwapchainKHR swapchain,
                      std::vector<vk::ImageView> image_views);

} // namespace vman
