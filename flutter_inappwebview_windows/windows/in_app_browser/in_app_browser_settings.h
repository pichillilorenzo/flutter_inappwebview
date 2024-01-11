#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_

#include <flutter/standard_message_codec.h>
#include <string>

namespace flutter_inappwebview_plugin
{
  enum InAppBrowserWindowType {
    window,
    child,
    tabbed
  };

  class InAppBrowserSettings
  {
  public:
    bool hidden = false;
    InAppBrowserWindowType windowType = window;
    double windowAlphaValue = 1.0;

    InAppBrowserSettings();
    InAppBrowserSettings(const flutter::EncodableMap& encodableMap);
    ~InAppBrowserSettings();
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_SETTINGS_H_