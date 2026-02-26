#include "content_blocker_handler.h"

#include <nlohmann/json.hpp>

#include <algorithm>
#include <cstring>
#include <filesystem>

#include "../utils/log.h"
#include "../utils/util.h"

using json = nlohmann::json;

namespace flutter_inappwebview_plugin {

ContentBlockerHandler::ContentBlockerHandler(WebKitUserContentManager* content_manager)
    : content_manager_(content_manager),
      filter_store_(nullptr),
      filter_identifier_("flutter_inappwebview_content_rules") {
  if (content_manager_ == nullptr) {
    errorLog("ContentBlockerHandler: content_manager is null");
    return;
  }

  // Get app-specific ID for isolated storage
  std::string app_id = resolve_application_id_sanitized();

  // Create filter store in a cache directory
  // Use XDG cache directory or fallback to /tmp
  const char* xdg_cache = g_get_user_cache_dir();
  if (xdg_cache != nullptr) {
    store_path_ = std::string(xdg_cache) + "/flutter_inappwebview/" + app_id + "/content_filters";
  } else {
    store_path_ = "/tmp/flutter_inappwebview/" + app_id + "/content_filters";
  }

  // Ensure directory exists
  std::error_code ec;
  std::filesystem::create_directories(store_path_, ec);
  if (ec) {
    errorLog("ContentBlockerHandler: Failed to create filter store directory: " + ec.message());
  }

  // Create the filter store
  filter_store_ = webkit_user_content_filter_store_new(store_path_.c_str());
  if (filter_store_ == nullptr) {
    errorLog("ContentBlockerHandler: Failed to create WebKitUserContentFilterStore");
  }
}

ContentBlockerHandler::~ContentBlockerHandler() {
  removeAllFilters();

  if (filter_store_ != nullptr) {
    g_object_unref(filter_store_);
    filter_store_ = nullptr;
  }
}

void ContentBlockerHandler::setContentBlockers(FlValue* contentBlockers,
                                                std::function<void(bool success)> callback) {
  if (filter_store_ == nullptr || content_manager_ == nullptr) {
    errorLog("ContentBlockerHandler: filter_store or content_manager is null");
    if (callback) callback(false);
    return;
  }

  // First remove existing filters
  removeAllFilters();

  // Check if there are any content blockers to apply
  if (contentBlockers == nullptr ||
      fl_value_get_type(contentBlockers) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(contentBlockers) == 0) {
    // No blockers - this is success (empty set)
    if (callback) callback(true);
    return;
  }

  // Convert to JSON string
  std::string jsonSource = convertToJsonString(contentBlockers);

  if (jsonSource.empty()) {
    errorLog("ContentBlockerHandler: Failed to convert content blockers to JSON");
    if (callback) callback(false);
    return;
  }

  // Compile the content blockers
  compileContentBlockers(jsonSource, callback);
}

void ContentBlockerHandler::removeAllFilters() {
  // Check if content_manager is still valid before calling WebKit API
  // The content_manager becomes invalid when the webview is destroyed
  if (content_manager_ != nullptr && WEBKIT_IS_USER_CONTENT_MANAGER(content_manager_)) {
    webkit_user_content_manager_remove_all_filters(content_manager_);
  }
}

std::string ContentBlockerHandler::convertToJsonString(FlValue* contentBlockers) {
  if (contentBlockers == nullptr ||
      fl_value_get_type(contentBlockers) != FL_VALUE_TYPE_LIST) {
    return "";
  }

  json jsonArray = json::array();

  size_t count = fl_value_get_length(contentBlockers);
  for (size_t i = 0; i < count; i++) {
    FlValue* blocker = fl_value_get_list_value(contentBlockers, i);
    if (fl_value_get_type(blocker) != FL_VALUE_TYPE_MAP) {
      continue;
    }

    json rule;

    // Parse trigger
    FlValue* triggerValue = fl_value_lookup_string(blocker, "trigger");
    if (triggerValue != nullptr && fl_value_get_type(triggerValue) == FL_VALUE_TYPE_MAP) {
      json trigger;

      // url-filter (required)
      FlValue* urlFilter = fl_value_lookup_string(triggerValue, "url-filter");
      if (urlFilter != nullptr && fl_value_get_type(urlFilter) == FL_VALUE_TYPE_STRING) {
        trigger["url-filter"] = fl_value_get_string(urlFilter);
      } else {
        // Skip this rule - url-filter is required
        continue;
      }

      // url-filter-is-case-sensitive
      FlValue* caseSensitive = fl_value_lookup_string(triggerValue, "url-filter-is-case-sensitive");
      if (caseSensitive != nullptr && fl_value_get_type(caseSensitive) == FL_VALUE_TYPE_BOOL) {
        if (fl_value_get_bool(caseSensitive)) {
          trigger["url-filter-is-case-sensitive"] = true;
        }
      }

      // resource-type (array)
      FlValue* resourceType = fl_value_lookup_string(triggerValue, "resource-type");
      if (resourceType != nullptr && fl_value_get_type(resourceType) == FL_VALUE_TYPE_LIST) {
        json types = json::array();
        for (size_t j = 0; j < fl_value_get_length(resourceType); j++) {
          FlValue* type = fl_value_get_list_value(resourceType, j);
          if (fl_value_get_type(type) == FL_VALUE_TYPE_STRING) {
            types.push_back(fl_value_get_string(type));
          }
        }
        if (!types.empty()) {
          trigger["resource-type"] = types;
        }
      }

      // if-domain (array)
      FlValue* ifDomain = fl_value_lookup_string(triggerValue, "if-domain");
      if (ifDomain != nullptr && fl_value_get_type(ifDomain) == FL_VALUE_TYPE_LIST) {
        json domains = json::array();
        for (size_t j = 0; j < fl_value_get_length(ifDomain); j++) {
          FlValue* domain = fl_value_get_list_value(ifDomain, j);
          if (fl_value_get_type(domain) == FL_VALUE_TYPE_STRING) {
            domains.push_back(fl_value_get_string(domain));
          }
        }
        if (!domains.empty()) {
          trigger["if-domain"] = domains;
        }
      }

      // unless-domain (array)
      FlValue* unlessDomain = fl_value_lookup_string(triggerValue, "unless-domain");
      if (unlessDomain != nullptr && fl_value_get_type(unlessDomain) == FL_VALUE_TYPE_LIST) {
        json domains = json::array();
        for (size_t j = 0; j < fl_value_get_length(unlessDomain); j++) {
          FlValue* domain = fl_value_get_list_value(unlessDomain, j);
          if (fl_value_get_type(domain) == FL_VALUE_TYPE_STRING) {
            domains.push_back(fl_value_get_string(domain));
          }
        }
        if (!domains.empty()) {
          trigger["unless-domain"] = domains;
        }
      }

      // load-type (array)
      FlValue* loadType = fl_value_lookup_string(triggerValue, "load-type");
      if (loadType != nullptr && fl_value_get_type(loadType) == FL_VALUE_TYPE_LIST) {
        json types = json::array();
        for (size_t j = 0; j < fl_value_get_length(loadType); j++) {
          FlValue* type = fl_value_get_list_value(loadType, j);
          if (fl_value_get_type(type) == FL_VALUE_TYPE_STRING) {
            types.push_back(fl_value_get_string(type));
          }
        }
        if (!types.empty()) {
          trigger["load-type"] = types;
        }
      }

      // if-top-url (array)
      FlValue* ifTopUrl = fl_value_lookup_string(triggerValue, "if-top-url");
      if (ifTopUrl != nullptr && fl_value_get_type(ifTopUrl) == FL_VALUE_TYPE_LIST) {
        json urls = json::array();
        for (size_t j = 0; j < fl_value_get_length(ifTopUrl); j++) {
          FlValue* url = fl_value_get_list_value(ifTopUrl, j);
          if (fl_value_get_type(url) == FL_VALUE_TYPE_STRING) {
            urls.push_back(fl_value_get_string(url));
          }
        }
        if (!urls.empty()) {
          trigger["if-top-url"] = urls;
        }
      }

      // unless-top-url (array)
      FlValue* unlessTopUrl = fl_value_lookup_string(triggerValue, "unless-top-url");
      if (unlessTopUrl != nullptr && fl_value_get_type(unlessTopUrl) == FL_VALUE_TYPE_LIST) {
        json urls = json::array();
        for (size_t j = 0; j < fl_value_get_length(unlessTopUrl); j++) {
          FlValue* url = fl_value_get_list_value(unlessTopUrl, j);
          if (fl_value_get_type(url) == FL_VALUE_TYPE_STRING) {
            urls.push_back(fl_value_get_string(url));
          }
        }
        if (!urls.empty()) {
          trigger["unless-top-url"] = urls;
        }
      }

      // if-frame-url (array) - WPE WebKit supports this
      FlValue* ifFrameUrl = fl_value_lookup_string(triggerValue, "if-frame-url");
      if (ifFrameUrl != nullptr && fl_value_get_type(ifFrameUrl) == FL_VALUE_TYPE_LIST) {
        json urls = json::array();
        for (size_t j = 0; j < fl_value_get_length(ifFrameUrl); j++) {
          FlValue* url = fl_value_get_list_value(ifFrameUrl, j);
          if (fl_value_get_type(url) == FL_VALUE_TYPE_STRING) {
            urls.push_back(fl_value_get_string(url));
          }
        }
        if (!urls.empty()) {
          trigger["if-frame-url"] = urls;
        }
      }

      rule["trigger"] = trigger;
    }

    // Parse action
    FlValue* actionValue = fl_value_lookup_string(blocker, "action");
    if (actionValue != nullptr && fl_value_get_type(actionValue) == FL_VALUE_TYPE_MAP) {
      json action;

      // type (required)
      FlValue* type = fl_value_lookup_string(actionValue, "type");
      if (type != nullptr && fl_value_get_type(type) == FL_VALUE_TYPE_STRING) {
        std::string typeStr = fl_value_get_string(type);

        // WPE WebKit supports: block, block-cookies, css-display-none,
        // ignore-previous-rules, make-https
        action["type"] = typeStr;
      } else {
        // Skip this rule - type is required
        continue;
      }

      // selector (for css-display-none)
      FlValue* selector = fl_value_lookup_string(actionValue, "selector");
      if (selector != nullptr && fl_value_get_type(selector) == FL_VALUE_TYPE_STRING) {
        action["selector"] = fl_value_get_string(selector);
      }

      rule["action"] = action;
    }

    if (rule.contains("trigger") && rule.contains("action")) {
      jsonArray.push_back(rule);
    }
  }

  if (jsonArray.empty()) {
    return "";
  }

  return jsonArray.dump();
}

void ContentBlockerHandler::compileContentBlockers(const std::string& jsonSource,
                                                    std::function<void(bool success)> callback) {
  if (filter_store_ == nullptr) {
    if (callback) callback(false);
    return;
  }

  // Create GBytes from JSON source
  GBytes* sourceBytes = g_bytes_new(jsonSource.c_str(), jsonSource.length());

  // Create context for async callback
  auto* context = new CompileContext{this, std::move(callback)};

  // Start async compilation
  webkit_user_content_filter_store_save(filter_store_, filter_identifier_.c_str(), sourceBytes,
                                         nullptr,  // cancellable
                                         onFilterCompiled, context);

  g_bytes_unref(sourceBytes);
}

void ContentBlockerHandler::onFilterCompiled(GObject* source, GAsyncResult* result,
                                              gpointer user_data) {
  auto* context = static_cast<CompileContext*>(user_data);
  if (context == nullptr) {
    return;
  }

  auto* handler = context->handler;
  auto callback = std::move(context->callback);
  delete context;

  if (handler == nullptr || handler->filter_store_ == nullptr) {
    if (callback) callback(false);
    return;
  }

  GError* error = nullptr;
  WebKitUserContentFilter* filter =
      webkit_user_content_filter_store_save_finish(handler->filter_store_, result, &error);

  if (error != nullptr) {
    errorLog("ContentBlockerHandler: Failed to compile content blockers: " +
             std::string(error->message));
    g_error_free(error);
    if (callback) callback(false);
    return;
  }

  if (filter == nullptr) {
    errorLog("ContentBlockerHandler: Compiled filter is null");
    if (callback) callback(false);
    return;
  }

  // Add the compiled filter to the content manager
  if (handler->content_manager_ != nullptr) {
    webkit_user_content_manager_add_filter(handler->content_manager_, filter);
  }

  webkit_user_content_filter_unref(filter);

  if (callback) callback(true);
}

}  // namespace flutter_inappwebview_plugin
