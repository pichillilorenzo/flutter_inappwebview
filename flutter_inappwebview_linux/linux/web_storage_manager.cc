#include "web_storage_manager.h"

#include <cstring>

#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

WebStorageManager::WebStorageManager(PluginInstance* plugin)
    : plugin_(plugin), channel_(nullptr), data_manager_(nullptr) {
  // Get the binary messenger from the plugin
  FlBinaryMessenger* messenger = plugin_->messenger();

  // Create the method channel
  channel_ = fl_method_channel_new(
      messenger,
      "com.pichillilorenzo/flutter_inappwebview_webstoragemanager",
      FL_METHOD_CODEC(fl_standard_method_codec_new()));

  // Set the method call handler
  fl_method_channel_set_method_call_handler(
      channel_, HandleMethodCall, this, nullptr);

  // Get the default website data manager from the network session
  WebKitNetworkSession* session = webkit_network_session_get_default();
  if (session != nullptr) {
    data_manager_ = webkit_network_session_get_website_data_manager(session);
    // data_manager_ is owned by session, don't unref it
  }
}

WebStorageManager::~WebStorageManager() {
  if (channel_ != nullptr) {
    fl_method_channel_set_method_call_handler(channel_, nullptr, nullptr, nullptr);
    g_object_unref(channel_);
    channel_ = nullptr;
  }
  // data_manager_ is owned by the network session, don't unref it
  data_manager_ = nullptr;
  plugin_ = nullptr;
}

void WebStorageManager::HandleMethodCall(FlMethodChannel* channel,
                                         FlMethodCall* method_call,
                                         gpointer user_data) {
  auto* self = static_cast<WebStorageManager*>(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (string_equals(method, "fetchDataRecords")) {
    self->fetchDataRecords(method_call);
  } else if (string_equals(method, "removeDataFor")) {
    self->removeDataFor(method_call);
  } else if (string_equals(method, "removeDataModifiedSince")) {
    self->removeDataModifiedSince(method_call);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

WebKitWebsiteDataTypes WebStorageManager::parseDataTypes(FlValue* dataTypesValue) {
  WebKitWebsiteDataTypes types = static_cast<WebKitWebsiteDataTypes>(0);

  if (dataTypesValue == nullptr ||
      fl_value_get_type(dataTypesValue) != FL_VALUE_TYPE_LIST) {
    return types;
  }

  size_t length = fl_value_get_length(dataTypesValue);
  for (size_t i = 0; i < length; i++) {
    FlValue* item = fl_value_get_list_value(dataTypesValue, i);
    if (fl_value_get_type(item) != FL_VALUE_TYPE_STRING) {
      continue;
    }

    const char* typeStr = fl_value_get_string(item);

    if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_DISK_CACHE") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_DISK_CACHE);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_MEMORY_CACHE") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_MEMORY_CACHE);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_COOKIES") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_COOKIES);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_SESSION_STORAGE") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_SESSION_STORAGE);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_LOCAL_STORAGE") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_LOCAL_STORAGE);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_INDEXEDDB_DATABASES") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_INDEXEDDB_DATABASES);
    } else if (strcmp(typeStr, "WEBKIT_WEBSITE_DATA_SERVICE_WORKER_REGISTRATIONS") == 0) {
      types = static_cast<WebKitWebsiteDataTypes>(types | WEBKIT_WEBSITE_DATA_SERVICE_WORKER_REGISTRATIONS);
    }
  }

  return types;
}

FlValue* WebStorageManager::dataTypesToFlValue(WebKitWebsiteDataTypes types) {
  g_autoptr(FlValue) list = fl_value_new_list();

  if (types & WEBKIT_WEBSITE_DATA_DISK_CACHE) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_DISK_CACHE"));
  }
  if (types & WEBKIT_WEBSITE_DATA_MEMORY_CACHE) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_MEMORY_CACHE"));
  }
  if (types & WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_OFFLINE_APPLICATION_CACHE"));
  }
  if (types & WEBKIT_WEBSITE_DATA_COOKIES) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_COOKIES"));
  }
  if (types & WEBKIT_WEBSITE_DATA_SESSION_STORAGE) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_SESSION_STORAGE"));
  }
  if (types & WEBKIT_WEBSITE_DATA_LOCAL_STORAGE) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_LOCAL_STORAGE"));
  }
  if (types & WEBKIT_WEBSITE_DATA_INDEXEDDB_DATABASES) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_INDEXEDDB_DATABASES"));
  }
  if (types & WEBKIT_WEBSITE_DATA_SERVICE_WORKER_REGISTRATIONS) {
    fl_value_append_take(list, fl_value_new_string("WEBKIT_WEBSITE_DATA_SERVICE_WORKER_REGISTRATIONS"));
  }

  return fl_value_ref(list);
}

void WebStorageManager::fetchDataRecords(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* dataTypesValue = fl_value_lookup_string(args, "dataTypes");

  WebKitWebsiteDataTypes types = parseDataTypes(dataTypesValue);

  // Store method_call for async callback
  g_object_ref(method_call);

  webkit_website_data_manager_fetch(
      data_manager_,
      types,
      nullptr,  // GCancellable
      [](GObject* source_object, GAsyncResult* res, gpointer user_data) {
        auto* method_call = static_cast<FlMethodCall*>(user_data);
        auto* data_manager = WEBKIT_WEBSITE_DATA_MANAGER(source_object);

        GError* error = nullptr;
        GList* records = webkit_website_data_manager_fetch_finish(
            data_manager, res, &error);

        if (error != nullptr) {
          fl_method_call_respond_error(
              method_call,
              "FETCH_ERROR",
              error->message,
              nullptr,
              nullptr);
          g_error_free(error);
          g_object_unref(method_call);
          return;
        }

        g_autoptr(FlValue) result = fl_value_new_list();

        for (GList* l = records; l != nullptr; l = l->next) {
          WebKitWebsiteData* data = static_cast<WebKitWebsiteData*>(l->data);
          const char* name = webkit_website_data_get_name(data);
          WebKitWebsiteDataTypes dataTypes = webkit_website_data_get_types(data);

          g_autoptr(FlValue) record = (name != nullptr)
              ? to_fl_map({
                  {"displayName", make_fl_value(name)},
                  {"dataTypes", WebStorageManager::dataTypesToFlValue(dataTypes)},
                })
              : to_fl_map({
                  {"dataTypes", WebStorageManager::dataTypesToFlValue(dataTypes)},
                });

          fl_value_append(result, record);
        }

        g_list_free_full(records, reinterpret_cast<GDestroyNotify>(webkit_website_data_unref));

        fl_method_call_respond_success(method_call, result, nullptr);
        g_object_unref(method_call);
      },
      method_call);
}

void WebStorageManager::removeDataFor(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* dataTypesValue = fl_value_lookup_string(args, "dataTypes");
  FlValue* recordListValue = fl_value_lookup_string(args, "recordList");

  WebKitWebsiteDataTypes types = parseDataTypes(dataTypesValue);

  if (recordListValue == nullptr ||
      fl_value_get_type(recordListValue) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(recordListValue) == 0) {
    // No records to delete
    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);
    return;
  }

  // Extract display names from the record list
  std::vector<std::string> displayNames;
  size_t length = fl_value_get_length(recordListValue);
  for (size_t i = 0; i < length; i++) {
    FlValue* record = fl_value_get_list_value(recordListValue, i);
    FlValue* displayNameValue = fl_value_lookup_string(record, "displayName");
    if (displayNameValue != nullptr &&
        fl_value_get_type(displayNameValue) == FL_VALUE_TYPE_STRING) {
      displayNames.push_back(fl_value_get_string(displayNameValue));
    }
  }

  if (displayNames.empty()) {
    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);
    return;
  }

  // We need to first fetch records to get WebKitWebsiteData pointers,
  // then remove matching ones
  struct RemoveContext {
    FlMethodCall* method_call;
    WebKitWebsiteDataManager* data_manager;
    WebKitWebsiteDataTypes types;
    std::vector<std::string> displayNames;
  };

  auto* ctx = new RemoveContext{method_call, data_manager_, types, std::move(displayNames)};
  g_object_ref(method_call);

  webkit_website_data_manager_fetch(
      data_manager_,
      types,
      nullptr,
      [](GObject* source_object, GAsyncResult* res, gpointer user_data) {
        auto* ctx = static_cast<RemoveContext*>(user_data);
        auto* data_manager = WEBKIT_WEBSITE_DATA_MANAGER(source_object);

        GError* error = nullptr;
        GList* all_records = webkit_website_data_manager_fetch_finish(
            data_manager, res, &error);

        if (error != nullptr) {
          fl_method_call_respond_error(
              ctx->method_call, "FETCH_ERROR", error->message, nullptr, nullptr);
          g_error_free(error);
          g_object_unref(ctx->method_call);
          delete ctx;
          return;
        }

        // Find matching records
        GList* matching_records = nullptr;
        for (GList* l = all_records; l != nullptr; l = l->next) {
          WebKitWebsiteData* data = static_cast<WebKitWebsiteData*>(l->data);
          const char* name = webkit_website_data_get_name(data);
          if (name != nullptr) {
            for (const auto& displayName : ctx->displayNames) {
              if (displayName == name) {
                matching_records = g_list_prepend(matching_records,
                                                  webkit_website_data_ref(data));
                break;
              }
            }
          }
        }

        g_list_free_full(all_records,
                         reinterpret_cast<GDestroyNotify>(webkit_website_data_unref));

        if (matching_records == nullptr) {
          fl_method_call_respond_success(ctx->method_call,
                                         fl_value_new_bool(TRUE), nullptr);
          g_object_unref(ctx->method_call);
          delete ctx;
          return;
        }

        // Now remove the matching records
        webkit_website_data_manager_remove(
            ctx->data_manager,
            ctx->types,
            matching_records,
            nullptr,
            [](GObject* source_object, GAsyncResult* res, gpointer user_data) {
              auto* ctx = static_cast<RemoveContext*>(user_data);
              auto* data_manager = WEBKIT_WEBSITE_DATA_MANAGER(source_object);

              GError* error = nullptr;
              gboolean success = webkit_website_data_manager_remove_finish(
                  data_manager, res, &error);

              if (error != nullptr) {
                fl_method_call_respond_error(
                    ctx->method_call, "REMOVE_ERROR", error->message, nullptr, nullptr);
                g_error_free(error);
              } else {
                fl_method_call_respond_success(ctx->method_call,
                                               fl_value_new_bool(success), nullptr);
              }

              g_object_unref(ctx->method_call);
              delete ctx;
            },
            ctx);

        g_list_free_full(matching_records,
                         reinterpret_cast<GDestroyNotify>(webkit_website_data_unref));
      },
      ctx);
}

void WebStorageManager::removeDataModifiedSince(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* dataTypesValue = fl_value_lookup_string(args, "dataTypes");
  FlValue* timestampValue = fl_value_lookup_string(args, "timestamp");

  WebKitWebsiteDataTypes types = parseDataTypes(dataTypesValue);

  // Get timestamp (seconds since epoch)
  gint64 timestamp = 0;
  if (timestampValue != nullptr &&
      fl_value_get_type(timestampValue) == FL_VALUE_TYPE_INT) {
    timestamp = fl_value_get_int(timestampValue);
  }

  // Convert to GDateTime
  GDateTime* datetime = g_date_time_new_from_unix_utc(timestamp);
  GTimeSpan timespan = g_date_time_to_unix(datetime);
  g_date_time_unref(datetime);

  g_object_ref(method_call);

  webkit_website_data_manager_clear(
      data_manager_,
      types,
      timespan,
      nullptr,  // GCancellable
      [](GObject* source_object, GAsyncResult* res, gpointer user_data) {
        auto* method_call = static_cast<FlMethodCall*>(user_data);
        auto* data_manager = WEBKIT_WEBSITE_DATA_MANAGER(source_object);

        GError* error = nullptr;
        gboolean success = webkit_website_data_manager_clear_finish(
            data_manager, res, &error);

        if (error != nullptr) {
          fl_method_call_respond_error(
              method_call, "CLEAR_ERROR", error->message, nullptr, nullptr);
          g_error_free(error);
        } else {
          fl_method_call_respond_success(method_call,
                                         fl_value_new_bool(success), nullptr);
        }

        g_object_unref(method_call);
      },
      method_call);
}

}  // namespace flutter_inappwebview_plugin
