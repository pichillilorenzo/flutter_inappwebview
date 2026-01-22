#include "notification_received_request.h"

namespace flutter_inappwebview_plugin
{
  NotificationReceivedRequest::NotificationReceivedRequest(const std::optional<std::string>& senderOrigin, const std::shared_ptr<WebNotification> notification)
    : senderOrigin(senderOrigin), notification(std::move(notification))
  {}

  flutter::EncodableMap NotificationReceivedRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"senderOrigin", make_fl_value(senderOrigin)},
      {"notification", notification ? make_fl_value(notification->toEncodableMap()) : make_fl_value()}
    };
  }
}