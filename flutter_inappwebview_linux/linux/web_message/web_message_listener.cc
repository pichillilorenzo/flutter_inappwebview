#include "web_message_listener.h"

#include <algorithm>
#include <cstring>
#include <regex>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "web_message_listener_channel_delegate.h"

namespace flutter_inappwebview_plugin {

std::unique_ptr<WebMessageListener> WebMessageListener::fromFlValue(
    FlBinaryMessenger* messenger,
    FlValue* map,
    InAppWebView* webView) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }

  std::string id = get_fl_map_value<std::string>(map, "id", "");
  std::string jsObjectName = get_fl_map_value<std::string>(map, "jsObjectName", "");
  
  std::set<std::string> allowedOriginRules;
  FlValue* rules_value = fl_value_lookup_string(map, "allowedOriginRules");
  if (rules_value != nullptr && fl_value_get_type(rules_value) == FL_VALUE_TYPE_LIST) {
    size_t length = fl_value_get_length(rules_value);
    for (size_t i = 0; i < length; i++) {
      FlValue* rule = fl_value_get_list_value(rules_value, i);
      if (rule != nullptr && fl_value_get_type(rule) == FL_VALUE_TYPE_STRING) {
        allowedOriginRules.insert(fl_value_get_string(rule));
      }
    }
  }

  if (id.empty() || jsObjectName.empty()) {
    errorLog("WebMessageListener::fromFlValue: missing id or jsObjectName");
    return nullptr;
  }

  return std::make_unique<WebMessageListener>(
      messenger, id, jsObjectName, allowedOriginRules, webView);
}

WebMessageListener::WebMessageListener(FlBinaryMessenger* messenger,
                                       const std::string& id,
                                       const std::string& jsObjectName,
                                       const std::set<std::string>& allowedOriginRules,
                                       InAppWebView* webView)
    : id_(id),
      jsObjectName_(jsObjectName),
      allowedOriginRules_(allowedOriginRules),
      webView_(webView) {
  // Create the channel name following the pattern:
  // com.pichillilorenzo/flutter_inappwebview_web_message_listener_{id}_{jsObjectName}
  std::string channelName = std::string(METHOD_CHANNEL_NAME_PREFIX) + id + "_" + jsObjectName;
  
  channelDelegate_ = std::make_unique<WebMessageListenerChannelDelegate>(
      this, messenger, channelName);
}

WebMessageListener::~WebMessageListener() {
  debugLog("dealloc WebMessageListener");
  dispose();
}

bool WebMessageListener::isOriginAllowed(const std::string& scheme,
                                         const std::string& host,
                                         int port) const {
  for (const auto& rule : allowedOriginRules_) {
    // Wildcard matches all origins
    if (rule == "*") {
      return true;
    }

    // Skip empty rules
    if (rule.empty()) {
      continue;
    }

    // Parse the rule: scheme://host[:port]
    size_t schemeEnd = rule.find("://");
    if (schemeEnd == std::string::npos) {
      continue;
    }

    std::string ruleScheme = rule.substr(0, schemeEnd);
    std::string rest = rule.substr(schemeEnd + 3);

    std::string ruleHost;
    int rulePort = 0;

    size_t portStart = rest.find(':');
    if (portStart != std::string::npos) {
      ruleHost = rest.substr(0, portStart);
      try {
        rulePort = std::stoi(rest.substr(portStart + 1));
      } catch (...) {
        rulePort = 0;
      }
    } else {
      ruleHost = rest;
    }

    // Normalize ports (use default for scheme if not specified)
    int normalizedRulePort = rulePort;
    if (normalizedRulePort == 0) {
      normalizedRulePort = (ruleScheme == "https") ? 443 : 80;
    }

    int normalizedPort = port;
    if (normalizedPort == 0) {
      normalizedPort = (scheme == "https") ? 443 : 80;
    }

    // Check scheme match
    if (scheme != ruleScheme) {
      continue;
    }

    // Check port match
    if (normalizedPort != normalizedRulePort) {
      continue;
    }

    // Check host match (including wildcard subdomain matching)
    if (ruleHost.empty() || host == ruleHost) {
      return true;
    }

    // Handle wildcard subdomain matching: *.example.com
    if (ruleHost.size() > 2 && ruleHost[0] == '*' && ruleHost[1] == '.') {
      std::string suffix = ruleHost.substr(1);  // .example.com
      if (host.size() > suffix.size() &&
          host.compare(host.size() - suffix.size(), suffix.size(), suffix) == 0) {
        return true;
      }
    }
  }

  return false;
}

void WebMessageListener::onPostMessage(const std::string* messageData,
                                       int64_t messageType,
                                       const std::string& sourceOrigin,
                                       bool isMainFrame) {
  if (channelDelegate_ == nullptr) {
    return;
  }

  // Parse the origin to check if it's allowed
  std::string scheme;
  std::string host;
  int port = 0;

  if (!sourceOrigin.empty()) {
    size_t schemeEnd = sourceOrigin.find("://");
    if (schemeEnd != std::string::npos) {
      scheme = sourceOrigin.substr(0, schemeEnd);
      std::string rest = sourceOrigin.substr(schemeEnd + 3);

      size_t portStart = rest.find(':');
      size_t pathStart = rest.find('/');
      
      if (portStart != std::string::npos && (pathStart == std::string::npos || portStart < pathStart)) {
        host = rest.substr(0, portStart);
        size_t portEnd = (pathStart != std::string::npos) ? pathStart : rest.size();
        try {
          port = std::stoi(rest.substr(portStart + 1, portEnd - portStart - 1));
        } catch (...) {
          port = 0;
        }
      } else if (pathStart != std::string::npos) {
        host = rest.substr(0, pathStart);
      } else {
        host = rest;
      }
    }
  }

  // Check if this origin is allowed (unless origin is empty/about:blank)
  if (!sourceOrigin.empty() && sourceOrigin != "null") {
    if (!isOriginAllowed(scheme, host, port)) {
      debugLog("WebMessageListener: Origin not allowed: " + sourceOrigin);
      return;
    }
  }

  // Invoke the callback on the Dart side via the dedicated channel
  channelDelegate_->onPostMessage(messageData, messageType, &sourceOrigin, isMainFrame);
}

void WebMessageListener::dispose() {
  if (channelDelegate_) {
    channelDelegate_->dispose();
    channelDelegate_.reset();
  }
  webView_ = nullptr;
}

}  // namespace flutter_inappwebview_plugin
