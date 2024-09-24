#pragma once

#define VULKMAN_ENABLE_VALIDATION_LAYERS

#include <vulkan/vulkan.hpp>
//
// for now
#define alloc nullptr

namespace vman {
// this thing is not actually constant lol.
const std::vector<const char *> validation_layers = {
    "VK_LAYER_KHRONOS_validation",
};

const std::vector<const char *> device_extensions = {
    VK_KHR_SWAPCHAIN_EXTENSION_NAME,
};

struct Instance {
    vk::Instance instance;

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
    VkDebugUtilsMessengerEXT debug_messenger;
#endif

    Instance(std::vector<const char *> extentions,
             PFN_vkDebugUtilsMessengerCallbackEXT callback);
};

vk::PhysicalDevice pick_physical_device(vk::Instance instance);
vk::Device create_logical_device(vk::Instance instance,
                                 VkPhysicalDevice ph_device);
} // namespace vman
