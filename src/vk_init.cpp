#include <vulkan/vulkan.hpp>

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

vk::PhysicalDevice vman::pick_physical_device(vk::Instance instance,
                                              vk::SurfaceKHR surface) {
    auto devices = instance.enumeratePhysicalDevices();

    // this will kinda never happen
    if (devices.empty()) {
        throw std::runtime_error("failed to find GPUs with Vulkan support!");
    }

    for (const auto &device : devices) {
        auto dx =
            std::vector(device_extensions.begin(), device_extensions.end());

        auto d_extention_props = device.enumerateDeviceExtensionProperties();

        bool ext_supported = false;
        bool swapchain_adequate = false;

        for (const auto &ext : d_extention_props) {
            for (size_t i = 0; i < dx.size(); i++) {
                if (ext.extensionName == dx[i])
                    dx.erase(dx.begin() + i);
            }
            if (dx.empty())
                ext_supported = true;
        }

        if (ext_supported) {
            auto s_caps = device.getSurfaceCapabilitiesKHR(surface);
            auto s_formats = device.getSurfaceFormats2KHR(surface);
            auto s_p_modes = device.getSurfacePresentModesKHR(surface);

            swapchain_adequate = !s_formats.empty() && !s_p_modes.empty();
        }

        if (!d_extention_props.empty() && ext_supported && swapchain_adequate) {
            return device;
        }
    }

    throw std::runtime_error("failed to find a suitable GPU!");
}

vk::Device vman::create_logical_device(vk::Instance instance,
                                       vk::PhysicalDevice ph_device,
                                       vk::SurfaceKHR surface) {
    auto qf_props = ph_device.getQueueFamilyProperties();
    auto q_create_infos = std::vector<vk::DeviceQueueCreateInfo>();

    float q_priority = 1.0f;

    int gf_index = -1, ps_index = -1, i = 0;
    for (const auto &qf_prop : qf_props) {
        if (qf_prop.queueFlags & vk::QueueFlagBits::eGraphics) {
            gf_index = i;
        }

        auto present_support =
            ph_device.getSurfaceSupportKHR(gf_index, surface);

        if (present_support) {
            ps_index = i;
            break;
        }

        if (gf_index > 0 | ps_index > 0) {
            auto dqci = vk::DeviceQueueCreateInfo({}, gf_index, 1, &q_priority);

            q_create_infos.push_back(dqci);
        }

        i++;
    }

    if (gf_index < 0 | ps_index < 0) {
        throw std::runtime_error("failed to create logical device!");
    }

    auto create_info = vk::DeviceCreateInfo(
        {}, q_create_infos.size(), q_create_infos.data(),
        validation_layers.size(), validation_layers.data(),
        device_extensions.size(), device_extensions.data());

    return ph_device.createDevice(create_info);
}
