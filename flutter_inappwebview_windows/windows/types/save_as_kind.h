#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SAVE_AS_KIND_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SAVE_AS_KIND_H_

#include <optional>

namespace flutter_inappwebview_plugin
{
  enum class SaveAsKind {
    default_kind = 0,
    html_only = 1,
    single_file = 2,
    complete = 3
  };

  inline SaveAsKind SaveAsKindFromInteger(const std::optional<int64_t>& kind)
  {
    if (!kind.has_value()) {
      return SaveAsKind::default_kind;
    }
    switch (kind.value()) {
    case 1:
      return SaveAsKind::html_only;
    case 2:
      return SaveAsKind::single_file;
    case 3:
      return SaveAsKind::complete;
    case 0:
    default:
      return SaveAsKind::default_kind;
    }
  }

  inline std::optional<SaveAsKind> SaveAsKindFromOptionalInteger(const std::optional<int64_t>& kind)
  {
    return kind.has_value() ? std::optional<SaveAsKind>{ SaveAsKindFromInteger(kind) } : std::optional<SaveAsKind>{};
  }

  inline std::optional<int64_t> SaveAsKindToInteger(const std::optional<SaveAsKind>& kind)
  {
    return kind.has_value() ? static_cast<int64_t>(kind.value()) : std::optional<int64_t>{};
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SAVE_AS_KIND_H_