#include "web_message_channel.h"

#include <string>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"

namespace flutter_inappwebview_plugin {

WebMessageChannel::WebMessageChannel(flutter::BinaryMessenger* messenger,
                                     const std::string& channelId,
                                     InAppWebView* webView)
    : ChannelDelegate(messenger,
                      std::string(METHOD_CHANNEL_NAME_PREFIX) + channelId),
      id_(channelId),
      webView_(webView) {
}

WebMessageChannel::~WebMessageChannel() {
  debugLog("dealloc WebMessageChannel");
  dispose();
}

void WebMessageChannel::dispose() {
  UnregisterMethodCallHandler();
  webView_ = nullptr;
}

void WebMessageChannel::HandleMethodCall(
  const flutter::MethodCall<flutter::EncodableValue>& method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (webView_ == nullptr) {
    result->Success(make_fl_value());
    return;
  }

  auto& methodName = method_call.method_name();
  auto& args = std::get<flutter::EncodableMap>(*method_call.arguments());

  if (string_equals(methodName, "setWebMessageCallback")) {
    auto portIndex = get_fl_map_value<int64_t>(args, "index");
    webView_->setWebMessageCallback(id_, static_cast<int>(portIndex));
    result->Success(make_fl_value(true));
    return;
  }

  if (string_equals(methodName, "postMessage")) {
    auto portIndex = get_fl_map_value<int64_t>(args, "index");
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

    webView_->postWebMessageOnPort(id_, static_cast<int>(portIndex), messageData, messageType);
    result->Success(make_fl_value(true));
    return;
  }

  if (string_equals(methodName, "close")) {
    auto portIndex = get_fl_map_value<int64_t>(args, "index");
    webView_->closeWebMessagePort(id_, static_cast<int>(portIndex));
    result->Success(make_fl_value(true));
    return;
  }

  result->NotImplemented();
}

void WebMessageChannel::onMessage(int portIndex, const std::string* message,
                                  int64_t messageType) {
  if (!channel) {
    return;
  }

  flutter::EncodableValue messageMap = make_fl_value();
  if (message != nullptr) {
    flutter::EncodableValue dataValue;
    if (messageType == 1) {
      std::vector<uint8_t> bytes;
      std::string value;
      for (char c : *message) {
        if (c == ',') {
          if (!value.empty()) {
            bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
            value.clear();
          }
        } else {
          value += c;
        }
      }
      if (!value.empty()) {
        bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
      }
      dataValue = flutter::EncodableValue(bytes);
    } else {
      dataValue = make_fl_value(*message);
    }

    messageMap = make_fl_value(flutter::EncodableMap{
        {make_fl_value("data"), dataValue},
        {make_fl_value("type"), make_fl_value(messageType)},
    });
  }

  flutter::EncodableMap args = {
      {make_fl_value("index"), make_fl_value(portIndex)},
      {make_fl_value("message"), messageMap},
  };

  channel->InvokeMethod("onMessage", std::make_unique<flutter::EncodableValue>(args));
}

}  // namespace flutter_inappwebview_plugin
