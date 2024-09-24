#include <cassert>
#include <iostream>
#include <optional>

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#include "defer.hpp"
#include "vk_init.hpp"

using std::cerr;
using std::optional;
using std::runtime_error;
using std::vector;

const uint32_t WIDTH = 800;
const uint32_t HEIGHT = 600;

const int MAX_FRAMES_IN_FLIGHT = 2;

#ifdef NDEBUG
#undef VULKMAN_ENABLE_VALIDATION_LAYERS
#else
#define VULKMAN_ENABLE_VALIDATION_LAYERS
#endif

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
    optional<vk::DebugUtilsMessengerEXT> debug_messenger = {};

    {
        uint32_t glfwExtensionCount = 0;
        const char **glfwExtensions;
        glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

        vector<const char *> extensions(glfwExtensions,
                                        glfwExtensions + glfwExtensionCount);

#ifdef VULKMAN_ENABLE_VALIDATION_LAYERS
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
        auto in = vman::Instance(extensions, debug_callback);

        if (!check_validation_layer_support()) {
            throw runtime_error(
                "validation layer requested but not available!");
        }

        debug_messenger = vk::DebugUtilsMessengerEXT();
#else
        auto in = vman::Instance();
#endif
    }

    VkSurfaceKHR raw_surface;
    defer(vkDestroySurfaceKHR(instance, raw_surface, alloc););

    if (glfwCreateWindowSurface(instance, window, nullptr, &raw_surface) !=
        VK_SUCCESS) {
        cerr << "glfwCreateWindowSurface failed!";
        return -1;
    }

    auto ph_device = vman::pick_physical_device(instance);
    auto device = vman::create_logical_device(instance, ph_device);
}
