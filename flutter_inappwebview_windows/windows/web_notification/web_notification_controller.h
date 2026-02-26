#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CONTROLLER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CONTROLLER_H_

#include <flutter/binary_messenger.h>
#include <flutter/standard_message_codec.h>
#include <WebView2.h>
#include <wil/com.h>

#include <functional>
#include <memory>
#include <optional>
#include <string>

#include "../types/web_notification.h"

namespace flutter_inappwebview_plugin
{
  class WebNotificationChannelDelegate;
  class InAppWebView;

  class WebNotificationController
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_webnotificationcontroller_";

    const std::string id;
    std::shared_ptr<WebNotification> notification;
    std::unique_ptr<WebNotificationChannelDelegate> channelDelegate;

    WebNotificationController(const std::string& id,
      wil::com_ptr<ICoreWebView2Notification> webNotification,
      std::shared_ptr<WebNotification> notification,
      flutter::BinaryMessenger* messenger,
      InAppWebView* inAppWebView);
    ~WebNotificationController();

    void reportShown();
    void reportClicked();
    void reportClosed();
    void dispose();

    // Called by InAppWebView before destruction to invalidate pointer
    void invalidateParentWebView();

    InAppWebView* getParentWebView() const { return inAppWebView_; }

  private:
    wil::com_ptr<ICoreWebView2Notification> webNotification_;
    InAppWebView* inAppWebView_ = nullptr;
    EventRegistrationToken closeRequestedToken_{};
    bool closeRequestedRegistered_ = false;
    bool disposed_ = false;

    void registerEventHandlers();
    void unregisterEventHandlers();
    void eraseFromParentWebView();
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_CONTROLLER_H_
