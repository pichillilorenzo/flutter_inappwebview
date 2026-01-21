#include "web_message_listener.h"

#include <algorithm>
#include <regex>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"
#include "web_message_listener_channel_delegate.h"

namespace flutter_inappwebview_plugin {

std::unique_ptr<WebMessageListener> WebMessageListener::fromEncodableValue(
    flutter::BinaryMessenger* messenger,
    const flutter::EncodableValue& value,
    InAppWebView* webView) {
  if (!std::holds_alternative<flutter::EncodableMap>(value)) {
    return nullptr;
  }

  auto map = std::get<flutter::EncodableMap>(value);
  std::string id = get_fl_map_value<std::string>(map, "id", "");
  std::string jsObjectName = get_fl_map_value<std::string>(map, "jsObjectName", "");

  std::set<std::string> allowedOriginRules;
  if (fl_map_contains_not_null(map, "allowedOriginRules")) {
    auto rules = std::get<flutter::EncodableList>(map.at(make_fl_value("allowedOriginRules")));
    for (const auto& ruleValue : rules) {
      if (std::holds_alternative<std::string>(ruleValue)) {
        allowedOriginRules.insert(std::get<std::string>(ruleValue));
      }
    }
  }

  if (id.empty() || jsObjectName.empty()) {
    debugLog("WebMessageListener::fromEncodableValue: missing id or jsObjectName");
    return nullptr;
  }

  return std::make_unique<WebMessageListener>(
      messenger, id, jsObjectName, allowedOriginRules, webView);
}

WebMessageListener::WebMessageListener(flutter::BinaryMessenger* messenger,
                                       const std::string& id,
                                       const std::string& jsObjectName,
                                       const std::set<std::string>& allowedOriginRules,
                                       InAppWebView* webView)
    : id_(id),
      jsObjectName_(jsObjectName),
      allowedOriginRules_(allowedOriginRules),
      webView_(webView) {
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
    if (rule == "*") {
      return true;
    }

    if (rule.empty()) {
      continue;
    }

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

    int normalizedRulePort = rulePort == 0 ? (ruleScheme == "https" ? 443 : 80) : rulePort;
    int normalizedPort = port == 0 ? (scheme == "https" ? 443 : 80) : port;

    if (scheme != ruleScheme) {
      continue;
    }

    if (normalizedPort != normalizedRulePort) {
      continue;
    }

    if (ruleHost.empty() || host == ruleHost) {
      return true;
    }

    if (ruleHost.size() > 2 && ruleHost[0] == '*' && ruleHost[1] == '.') {
      std::string suffix = ruleHost.substr(1);
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

  if (!sourceOrigin.empty() && sourceOrigin != "null") {
    if (!isOriginAllowed(scheme, host, port)) {
      debugLog("WebMessageListener: Origin not allowed: " + sourceOrigin);
      return;
    }
  }

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
