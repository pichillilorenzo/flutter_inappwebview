#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CHANNEL_DELEGATE_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>

#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class WebNotificationController;

  class WebNotificationChannelDelegate : public ChannelDelegate
  {
  public:
    WebNotificationChannelDelegate(WebNotificationController* webNotificationController,
      flutter::BinaryMessenger* messenger, const std::string& channelName);
    ~WebNotificationChannelDelegate() override;

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

    void onClose() const;

    void dispose();

  private:
    WebNotificationController* webNotificationController_;
    bool disposed_ = false;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CHANNEL_DELEGATE_H_
