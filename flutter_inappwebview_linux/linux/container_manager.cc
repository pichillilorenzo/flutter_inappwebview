#include "container_manager.h"

#include <cstring>
#include <filesystem>
#include <string>
#include <system_error>

#include "container_session_cache.h"
#include "proxy_manager.h"
#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {

bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}

}  // namespace

ContainerManager::ContainerManager(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME),
      plugin_(plugin) {}

ContainerManager::~ContainerManager() {
  debugLog("dealloc ContainerManager");
  plugin_ = nullptr;
}

void ContainerManager::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(method, "getAllContainerNames")) {
    g_autoptr(FlValue) result = fl_value_new_list();
    std::error_code ec;
    const auto root = container_data_root();
    if (std::filesystem::exists(root, ec)) {
      for (const auto& entry : std::filesystem::directory_iterator(root, ec)) {
        if (entry.is_directory(ec)) {
          fl_value_append_take(
              result, fl_value_new_string(entry.path().filename().c_str()));
        }
      }
    }
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(method, "hasContainer")) {
    std::string id = get_fl_map_value<std::string>(args, "containerId", "");
    std::error_code ec;
    bool exists = !id.empty() &&
                  std::filesystem::is_directory(container_data_root() / id, ec);
    g_autoptr(FlValue) result = fl_value_new_bool(exists);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(method, "deleteContainer")) {
    std::string id = get_fl_map_value<std::string>(args, "containerId", "");
    if (id.empty()) {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
    std::error_code ec1, ec2;
    const auto data_dir = container_data_root() / id;
    const auto cache_dir = container_cache_root() / id;
    bool data_existed = std::filesystem::exists(data_dir, ec1);
    bool cache_existed = std::filesystem::exists(cache_dir, ec1);
    std::filesystem::remove_all(data_dir, ec1);
    std::filesystem::remove_all(cache_dir, ec2);
    bool deleted = (data_existed || cache_existed) && !ec1 && !ec2;
    // A deleted container takes its proxy with it: one created again under
    // the same id starts from the process-wide override, like any new
    // container.
    if (deleted) {
      unpin_container_proxy(id);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(deleted);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(method, "clearContainerData")) {
    // Clear everything in the container's WebKitNetworkSession
    // without removing the session itself — works while WebViews are
    // still bound, unlike deleteContainer. Goes through the cached
    // session rather than recreating one because (a) the cache
    // already holds a session if any WebView has joined this
    // container this process, and (b) only the cached session has
    // the right per-session data manager bound to the on-disk dirs.
    //
    // If the container hasn't been joined yet this process, there's
    // no live session to clear — return false. Callers that need to
    // wipe a never-joined container can use deleteContainer instead,
    // which just removes the on-disk directories.
    std::string id = get_fl_map_value<std::string>(args, "containerId", "");
    if (id.empty()) {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
    auto& cache = container_session_cache();
    auto it = cache.find(id);
    if (it == cache.end() || it->second == nullptr) {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
    WebKitWebsiteDataManager* manager =
        webkit_network_session_get_website_data_manager(it->second);
    if (manager == nullptr) {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
    g_object_ref(method_call);
    webkit_website_data_manager_clear(
        manager, WEBKIT_WEBSITE_DATA_ALL,
        0,        // timespan, 0 = since epoch
        nullptr,  // cancellable
        [](GObject* source, GAsyncResult* async_result, gpointer user_data) {
          auto* call = static_cast<FlMethodCall*>(user_data);
          GError* error = nullptr;
          gboolean success = webkit_website_data_manager_clear_finish(
              WEBKIT_WEBSITE_DATA_MANAGER(source), async_result, &error);
          if (error != nullptr) {
            errorLog(std::string("ContainerManager: clearContainerData failed: ") +
                     error->message);
            g_error_free(error);
          }
          g_autoptr(FlValue) result = fl_value_new_bool(success);
          fl_method_call_respond_success(call, result, nullptr);
          g_object_unref(call);
        },
        method_call);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

}  // namespace flutter_inappwebview_plugin
