#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>
#include <vector>

#include "../utils/flutter.h"
#include "text_direction_kind.h"

namespace flutter_inappwebview_plugin
{
  class WebNotification
  {
  public:
    const std::optional<std::string> title;
    const std::optional<std::string> body;
    const std::optional<TextDirectionKind> direction;
    const std::optional<std::string> language;
    const std::optional<std::string> tag;
    const std::optional<std::string> iconUri;
    const std::optional<std::string> badgeUri;
    const std::optional<std::string> bodyImageUri;
    const std::optional<bool> shouldRenotify;
    const std::optional<bool> requiresInteraction;
    const std::optional<bool> isSilent;
    const std::optional<double> timestamp;
    const std::optional<std::vector<int64_t>> vibrationPattern;

    WebNotification(const std::optional<std::string>& title,
      const std::optional<std::string>& body,
      const std::optional<TextDirectionKind>& direction,
      const std::optional<std::string>& language,
      const std::optional<std::string>& tag,
      const std::optional<std::string>& iconUri,
      const std::optional<std::string>& badgeUri,
      const std::optional<std::string>& bodyImageUri,
      const std::optional<bool>& shouldRenotify,
      const std::optional<bool>& requiresInteraction,
      const std::optional<bool>& isSilent,
      const std::optional<double>& timestamp,
      const std::optional<std::vector<int64_t>>& vibrationPattern);
    WebNotification(const flutter::EncodableMap& map);
    ~WebNotification() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_NOTIFICATION_H_