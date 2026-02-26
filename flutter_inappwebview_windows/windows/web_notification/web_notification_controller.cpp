#include "web_notification_controller.h"

#include "web_notification_channel_delegate.h"
#include "../in_app_webview/in_app_webview.h"

#include <wil/wrl.h>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/strconv.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  WebNotificationController::WebNotificationController(const std::string& id,
    wil::com_ptr<ICoreWebView2Notification> webNotification,
    std::shared_ptr<WebNotification> notification,
    flutter::BinaryMessenger* messenger,
    InAppWebView* inAppWebView)
    : id(id), webNotification_(webNotification), notification(notification), inAppWebView_(inAppWebView)
  {
    channelDelegate = std::make_unique<WebNotificationChannelDelegate>(
      this, messenger, METHOD_CHANNEL_NAME_PREFIX + id);
    registerEventHandlers();
  }

  void WebNotificationController::registerEventHandlers()
  {
    if (!webNotification_) {
      return;
    }

    if (!closeRequestedRegistered_) {
      EventRegistrationToken token = {};
      auto hr = webNotification_->add_CloseRequested(Callback<ICoreWebView2NotificationCloseRequestedEventHandler>(
        [this](ICoreWebView2Notification* sender, IUnknown* args) -> HRESULT
        {
          if (channelDelegate) {
            channelDelegate->onClose();
          }
          return S_OK;
        }).Get(), &token);
      if (succeededOrLog(hr)) {
        closeRequestedToken_ = token;
        closeRequestedRegistered_ = true;
      }
    }
  }

  void WebNotificationController::unregisterEventHandlers()
  {
    if (closeRequestedRegistered_ && webNotification_) {
      failedLog(webNotification_->remove_CloseRequested(closeRequestedToken_));
    }
    closeRequestedRegistered_ = false;
  }

  void WebNotificationController::reportShown()
  {
    if (webNotification_) {
      failedLog(webNotification_->ReportShown());
    }
  }

  void WebNotificationController::reportClicked()
  {
    if (webNotification_) {
      failedLog(webNotification_->ReportClicked());
    }
  }

  void WebNotificationController::reportClosed()
  {
    if (webNotification_) {
      failedLog(webNotification_->ReportClosed());
    }
  }

  void WebNotificationController::dispose()
  {
    if (disposed_) {
      return;
    }
    disposed_ = true;

    unregisterEventHandlers();
    if (channelDelegate) {
      channelDelegate->dispose();
      channelDelegate.reset();
    }
    webNotification_ = nullptr;
    notification = nullptr;
    // Erase self from parent webview's map (if parent is still valid)
    eraseFromParentWebView();
  }

  void WebNotificationController::invalidateParentWebView()
  {
    inAppWebView_ = nullptr;
  }

  void WebNotificationController::eraseFromParentWebView()
  {
    // Only erase if parent webview is still valid (not being destroyed)
    if (inAppWebView_) {
      inAppWebView_->eraseWebNotificationController(id);
      inAppWebView_ = nullptr;
    }
  }

  WebNotificationController::~WebNotificationController()
  {
    debugLog("dealloc WebNotificationController");
    dispose();
  }
}
