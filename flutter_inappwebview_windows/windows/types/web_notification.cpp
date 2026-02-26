#include "web_notification.h"

namespace flutter_inappwebview_plugin
{
  WebNotification::WebNotification(const std::optional<std::string>& title,
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
    const std::optional<std::vector<int64_t>>& vibrationPattern)
    : title(title), body(body), direction(direction), language(language), tag(tag), iconUri(iconUri), badgeUri(badgeUri),
    bodyImageUri(bodyImageUri), shouldRenotify(shouldRenotify), requiresInteraction(requiresInteraction), isSilent(isSilent),
    timestamp(timestamp), vibrationPattern(vibrationPattern)
  {}

  WebNotification::WebNotification(const flutter::EncodableMap& map)
    : WebNotification(get_optional_fl_map_value<std::string>(map, "title"),
      get_optional_fl_map_value<std::string>(map, "body"),
      TextDirectionKindFromOptionalInteger(get_optional_fl_map_value<int64_t>(map, "direction")),
      get_optional_fl_map_value<std::string>(map, "language"),
      get_optional_fl_map_value<std::string>(map, "tag"),
      get_optional_fl_map_value<std::string>(map, "iconUri"),
      get_optional_fl_map_value<std::string>(map, "badgeUri"),
      get_optional_fl_map_value<std::string>(map, "bodyImageUri"),
      get_optional_fl_map_value<bool>(map, "shouldRenotify"),
      get_optional_fl_map_value<bool>(map, "requiresInteraction"),
      get_optional_fl_map_value<bool>(map, "isSilent"),
      get_optional_fl_map_value<double>(map, "timestamp"),
      get_optional_fl_map_value<std::vector<int64_t>>(map, "vibrationPattern"))
  {}

  flutter::EncodableMap WebNotification::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"title", make_fl_value(title)},
      {"body", make_fl_value(body)},
      {"direction", make_fl_value(TextDirectionKindToInteger(direction))},
      {"language", make_fl_value(language)},
      {"tag", make_fl_value(tag)},
      {"iconUri", make_fl_value(iconUri)},
      {"badgeUri", make_fl_value(badgeUri)},
      {"bodyImageUri", make_fl_value(bodyImageUri)},
      {"shouldRenotify", make_fl_value(shouldRenotify)},
      {"requiresInteraction", make_fl_value(requiresInteraction)},
      {"isSilent", make_fl_value(isSilent)},
      {"timestamp", make_fl_value(timestamp)},
      {"vibrationPattern", make_fl_value(vibrationPattern)}
    };
  }
}