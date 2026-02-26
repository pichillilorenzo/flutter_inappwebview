#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "url_request.h"

namespace flutter_inappwebview_plugin
{
  enum class NavigationActionType {
    linkActivated = 0,
    backForward,
    reload,
    other
  };

  inline std::optional<int64_t> NavigationActionTypeToInteger(const std::optional<NavigationActionType>& action)
  {
    return action.has_value() ? static_cast<int64_t>(action.value()) : std::optional<int64_t>{};
  }

  class NavigationAction
  {
  public:
    const std::shared_ptr<URLRequest> request;
    const bool isForMainFrame;
    const std::optional<bool> isRedirect;
    const std::optional<NavigationActionType> navigationType;

    NavigationAction(std::shared_ptr<URLRequest> request, const bool& isForMainFrame, const std::optional<bool>& isRedirect, const std::optional<NavigationActionType>& navigationType);
    ~NavigationAction() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_