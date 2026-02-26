#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_TEXT_DIRECTION_KIND_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_TEXT_DIRECTION_KIND_H_

#include <optional>

namespace flutter_inappwebview_plugin
{
  enum class TextDirectionKind {
    default_direction = 0,
    left_to_right = 1,
    right_to_left = 2
  };

  inline TextDirectionKind TextDirectionKindFromInteger(const std::optional<int64_t>& direction)
  {
    if (!direction.has_value()) {
      return TextDirectionKind::default_direction;
    }
    switch (direction.value()) {
    case 1:
      return TextDirectionKind::left_to_right;
    case 2:
      return TextDirectionKind::right_to_left;
    case 0:
    default:
      return TextDirectionKind::default_direction;
    }
  }

  inline std::optional<TextDirectionKind> TextDirectionKindFromOptionalInteger(const std::optional<int64_t>& direction)
  {
    return direction.has_value() ? std::optional<TextDirectionKind>{ TextDirectionKindFromInteger(direction) } : std::optional<TextDirectionKind>{};
  }

  inline std::optional<int64_t> TextDirectionKindToInteger(const std::optional<TextDirectionKind>& direction)
  {
    return direction.has_value() ? static_cast<int64_t>(direction.value()) : std::optional<int64_t>{};
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_TEXT_DIRECTION_KIND_H_
