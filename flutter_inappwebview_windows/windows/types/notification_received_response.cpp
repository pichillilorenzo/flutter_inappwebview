#include "notification_received_response.h"

namespace flutter_inappwebview_plugin
{
  NotificationReceivedResponse::NotificationReceivedResponse(const bool& handled)
    : handled(handled)
  {}

  NotificationReceivedResponse::NotificationReceivedResponse(const flutter::EncodableMap& map)
    : NotificationReceivedResponse(get_fl_map_value<bool>(map, "handled", false))
  {}

  flutter::EncodableMap NotificationReceivedResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"handled", make_fl_value(handled)}
    };
  }
}