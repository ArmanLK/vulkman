#include <vulkan/vulkan.hpp>
#include <vulkan/vulkan_handles.hpp>

#include "vk_init.hpp"

vman::Instance::Instance(std::vector<const char *> extentions,
                         PFN_vkDebugUtilsMessengerCallbackEXT callback) {

    auto app_info = vk::ApplicationInfo("vulkman", VK_MAKE_VERSION(1, 0, 0), {},
                                        {}, vk::ApiVersion13);

    auto instance_info = vk::InstanceCreateInfo(
        {}, &app_info, validation_layers.size(), validation_layers.data(),
        extentions.size(), extentions.data());

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
    auto deb_info = VkDebugUtilsMessengerCreateInfoEXT{
        .sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
        .messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
                           VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
                           VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT,
        .messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
                       VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
                       VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT,
        .pfnUserCallback = callback,
    };

    instance_info.pNext = &deb_info;

    instance = vk::createInstance(instance_info, alloc);

    auto func = (PFN_vkCreateDebugUtilsMessengerEXT)vkGetInstanceProcAddr(
        instance, "vkCreateDebugUtilsMessengerEXT");

    if (func != nullptr) {
        func(instance, &deb_info, alloc, &debug_messenger);
    }
#else
    instance = vk::createInstance(instance_info, alloc);
#endif
}

vk::PhysicalDevice vman::pick_physical_device(vk::Instance instance) {}

vk::Device vman::create_logical_device(vk::Instance instance,
                                       VkPhysicalDevice ph_device) {}
