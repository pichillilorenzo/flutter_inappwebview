#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "url_request.h"

namespace flutter_inappwebview_plugin
{
  class NavigationAction
  {
  public:
    const std::shared_ptr<URLRequest> request;
    const bool isForMainFrame;

    NavigationAction(std::shared_ptr<URLRequest> request, const bool& isForMainFrame);
    ~NavigationAction() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_NAVIGATION_ACTION_H_