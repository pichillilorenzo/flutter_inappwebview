#include "web_message_listener_channel_delegate.h"

#include <string>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"
#include "web_message_listener.h"

namespace flutter_inappwebview_plugin {

WebMessageListenerChannelDelegate::WebMessageListenerChannelDelegate(
    WebMessageListener* webMessageListener,
    flutter::BinaryMessenger* messenger,
    const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
      webMessageListener_(webMessageListener) {
}

WebMessageListenerChannelDelegate::~WebMessageListenerChannelDelegate() {
  debugLog("dealloc WebMessageListenerChannelDelegate");
  webMessageListener_ = nullptr;
}

void WebMessageListenerChannelDelegate::HandleMethodCall(
  const flutter::MethodCall<flutter::EncodableValue>& method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (webMessageListener_ == nullptr) {
    result->Success(make_fl_value());
    return;
  }

  auto& methodName = method_call.method_name();
  auto& args = std::get<flutter::EncodableMap>(*method_call.arguments());

  if (string_equals(methodName, "postMessage")) {
    InAppWebView* webView = webMessageListener_->webView();
    if (webView == nullptr) {
      result->Success(make_fl_value(false));
      return;
    }

    std::string messageData = "";
    int64_t messageType = 0;

    if (fl_map_contains_not_null(args, "message")) {
      auto messageMap = std::get<flutter::EncodableMap>(args.at(make_fl_value("message")));
      if (fl_map_contains_not_null(messageMap, "type")) {
        messageType = messageMap.at(make_fl_value("type")).LongValue();
      }
      if (fl_map_contains_not_null(messageMap, "data")) {
        const auto& dataValue = messageMap.at(make_fl_value("data"));
        if (std::holds_alternative<std::string>(dataValue)) {
          messageData = std::get<std::string>(dataValue);
        } else if (std::holds_alternative<std::vector<uint8_t>>(dataValue)) {
          const auto& bytes = std::get<std::vector<uint8_t>>(dataValue);
          for (size_t i = 0; i < bytes.size(); i++) {
            if (i > 0) messageData += ",";
            messageData += std::to_string(bytes[i]);
          }
          messageType = 1;
        }
      }
    }

    std::string messageDataJs;
    if (messageType == 1) {
      messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
    } else {
      std::string escaped;
      escaped.reserve(messageData.size() * 2);
      for (char c : messageData) {
        switch (c) {
          case '\\': escaped += "\\\\"; break;
          case '"': escaped += "\\\""; break;
          case '\n': escaped += "\\n"; break;
          case '\r': escaped += "\\r"; break;
          case '\t': escaped += "\\t"; break;
          default: escaped += c; break;
        }
      }
      messageDataJs = "\"" + escaped + "\"";
    }

    std::string jsObjectNameEscaped = webMessageListener_->jsObjectName();
    size_t pos = 0;
    while ((pos = jsObjectNameEscaped.find("'", pos)) != std::string::npos) {
      jsObjectNameEscaped.replace(pos, 1, "\\'");
      pos += 2;
    }

    std::string js =
      "(function() {\n"
      "    var webMessageListener = window['" + jsObjectNameEscaped + "'];\n"
      "    if (webMessageListener != null) {\n"
      "        var event = {data: " + messageDataJs + "};\n"
      "        if (webMessageListener.onmessage != null) {\n"
      "            webMessageListener.onmessage(event);\n"
      "        }\n"
      "        for (var listener of webMessageListener.listeners) {\n"
      "            listener(event);\n"
      "        }\n"
      "    }\n"
      "})();\n";

    webView->evaluateJavascript(js, ContentWorld::page(), nullptr);

    result->Success(make_fl_value(true));
    return;
  }

  result->NotImplemented();
}

void WebMessageListenerChannelDelegate::onPostMessage(const std::string* messageData,
                                                      int64_t messageType,
                                                      const std::string* sourceOrigin,
                                                      bool isMainFrame) const {
  if (!channel) {
    return;
  }

  flutter::EncodableValue messageMap = make_fl_value();
  if (messageData != nullptr) {
    flutter::EncodableValue dataValue;
    if (messageType == 1) {
      std::vector<uint8_t> bytes;
      std::string value;
      for (char c : *messageData) {
        if (c == ',') {
          if (!value.empty()) {
            try {
              bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
            } catch (...) {}
            value.clear();
          }
        } else {
          value += c;
        }
      }
      if (!value.empty()) {
        try {
          bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
        } catch (...) {}
      }
      dataValue = flutter::EncodableValue(bytes);
    } else {
      dataValue = make_fl_value(*messageData);
    }

    messageMap = make_fl_value(flutter::EncodableMap{
        {make_fl_value("data"), dataValue},
        {make_fl_value("type"), make_fl_value(messageType)},
    });
  }

  flutter::EncodableMap args = {
      {make_fl_value("message"), messageMap},
      {make_fl_value("sourceOrigin"), sourceOrigin != nullptr ? make_fl_value(*sourceOrigin) : make_fl_value()},
      {make_fl_value("isMainFrame"), make_fl_value(isMainFrame)},
  };

  channel->InvokeMethod("onPostMessage", std::make_unique<flutter::EncodableValue>(args));
}

void WebMessageListenerChannelDelegate::dispose() {
  debugLog("WebMessageListenerChannelDelegate::dispose");
  UnregisterMethodCallHandler();
  webMessageListener_ = nullptr;
}

}  // namespace flutter_inappwebview_plugin
