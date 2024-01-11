#include "../utils/flutter.h"
#include "in_app_browser_settings.h"

namespace flutter_inappwebview_plugin
{
  namespace
  {
    InAppBrowserWindowType inAppBrowserWindowTypeFromString(const std::string& s)
    {
      if (s.compare("CHILD") == 0) {
        return child;
      }
      else if (s.compare("TABBED") == 0) {
        return tabbed;
      }
      return window;
    }

    std::string inAppBrowserWindowTypeToString(const InAppBrowserWindowType& t)
    {
      switch (t) {
      case child:
        return "CHILD";
      case tabbed:
        return "TABBED";
      default:
        return "WINDOW";
      }
    }
  }

  InAppBrowserSettings::InAppBrowserSettings() {};

  InAppBrowserSettings::InAppBrowserSettings(const flutter::EncodableMap& encodableMap)
  {
    hidden = get_fl_map_value(encodableMap, "hidden", hidden);
    windowType = inAppBrowserWindowTypeFromString(get_fl_map_value<std::string>(encodableMap, "windowType", inAppBrowserWindowTypeToString(window)));
    windowAlphaValue = get_fl_map_value(encodableMap, "windowAlphaValue", windowAlphaValue);
  }

  InAppBrowserSettings::~InAppBrowserSettings()
  {
    debugLog("dealloc InAppBrowserSettings");
  };
}
