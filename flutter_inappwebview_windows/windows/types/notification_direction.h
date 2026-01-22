#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_NOTIFICATION_DIRECTION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_NOTIFICATION_DIRECTION_H_

#include <optional>

namespace flutter_inappwebview_plugin
{
  enum class NotificationDirection {
    default_direction = 0,
    left_to_right = 1,
    right_to_left = 2
  };

  inline NotificationDirection NotificationDirectionFromInteger(const std::optional<int64_t>& direction)
  {
    if (!direction.has_value()) {
      return NotificationDirection::default_direction;
    }
    switch (direction.value()) {
    case 1:
      return NotificationDirection::left_to_right;
    case 2:
      return NotificationDirection::right_to_left;
    case 0:
    default:
      return NotificationDirection::default_direction;
    }
  }

  inline std::optional<NotificationDirection> NotificationDirectionFromOptionalInteger(const std::optional<int64_t>& direction)
  {
    return direction.has_value() ? std::optional<NotificationDirection>{ NotificationDirectionFromInteger(direction) } : std::optional<NotificationDirection>{};
  }

  inline std::optional<int64_t> NotificationDirectionToInteger(const std::optional<NotificationDirection>& direction)
  {
    return direction.has_value() ? static_cast<int64_t>(direction.value()) : std::optional<int64_t>{};
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_NOTIFICATION_DIRECTION_H_