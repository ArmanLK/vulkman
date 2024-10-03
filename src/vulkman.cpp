#include <cassert>
#include <iostream>

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#include "defer.hpp"
#include "vk_init.hpp"

using std::cerr;
using std::runtime_error;
using std::vector;

const uint32_t WIDTH = 800;
const uint32_t HEIGHT = 600;

const int MAX_FRAMES_IN_FLIGHT = 2;

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
bool check_validation_layer_support() {
    auto v = vk::enumerateInstanceLayerProperties();

    for (auto const &layer_name : vman::validation_layers) {
        bool found = false;
        for (auto const &props : v) {
            if (props.layerName == layer_name) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }

    return true;
}

VKAPI_ATTR VkBool32 VKAPI_CALL
debug_callback(VkDebugUtilsMessageSeverityFlagBitsEXT message_severity,
               VkDebugUtilsMessageTypeFlagsEXT message_type,
               const VkDebugUtilsMessengerCallbackDataEXT *call_back_data,
               void *p_user_data) {

    const char *msg;
    switch (message_severity) {
    case VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT:
        msg = "Verbos:";
        break;
    case VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT:
        msg = "Info";
        break;
    case VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT:
        msg = "Warning";
        break;
    case VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT:
        msg = "Error";
        break;
    case VK_DEBUG_UTILS_MESSAGE_SEVERITY_FLAG_BITS_MAX_ENUM_EXT:
        msg = "WUT?";
        break;
    }

    std::cerr << msg << " (validation layer): " << call_back_data->pMessage
              << "\n";

    return VK_FALSE;
}
#endif

int main() {

    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    auto window = glfwCreateWindow(WIDTH, HEIGHT, "Image", nullptr, nullptr);

    defer({
        glfwDestroyWindow(window);
        glfwTerminate();
    });

    vk::Instance instance;

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
    vk::DebugUtilsMessengerEXT debug_messenger;
#endif

    {
        uint32_t glfwExtensionCount = 0;
        const char **glfwExtensions;
        glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

        vector<const char *> extensions(glfwExtensions,
                                        glfwExtensions + glfwExtensionCount);

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);

        if (!check_validation_layer_support()) {
            throw runtime_error(
                "validation layer requested but not available!");
        }

        auto in = vman::Instance(extensions, debug_callback);
        instance = in.instance;
        debug_messenger = in.debug_messenger;
#else
        instance = vman::Instance(extensions).instance;
#endif
    }

    VkSurfaceKHR raw_surface;
    defer(vkDestroySurfaceKHR(instance, raw_surface, alloc););

    if (glfwCreateWindowSurface(instance, window, nullptr, &raw_surface) !=
        VK_SUCCESS) {
        cerr << "glfwCreateWindowSurface failed!";
        return -1;
    }

    auto ph_device = vman::pick_physical_device(instance, raw_surface);
    auto device = vman::create_logical_device(instance, ph_device, raw_surface);

    auto phd_surface_caps = ph_device.getSurfaceCapabilitiesKHR(raw_surface);
    auto phd_surface_formats = ph_device.getSurfaceFormatsKHR(raw_surface);
    auto phd_surface_modes = ph_device.getSurfacePresentModesKHR(raw_surface);

    auto surface_format = phd_surface_formats[0];
    for (const auto &format : phd_surface_formats) {
        if (format.format == vk::Format::eB8G8R8A8Srgb &&
            format.colorSpace == vk::ColorSpaceKHR::eSrgbNonlinear) {
            surface_format = format;
        }
    }

    auto present_mode = vk::PresentModeKHR::eFifo;
    for (const auto p_mode : phd_surface_modes) {
        if (p_mode == vk::PresentModeKHR::eMailbox) {
        }
    }

    auto swap_chain =
        device.createSwapchainKHR(vk::SwapchainCreateInfoKHR({}, raw_surface));
}
