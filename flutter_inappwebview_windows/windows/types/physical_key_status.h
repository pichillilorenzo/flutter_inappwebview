#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PHYSICAL_KEY_STATUS_H
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PHYSICAL_KEY_STATUS_H

#include <flutter/standard_method_codec.h>
#include <WebView2.h>

namespace flutter_inappwebview_plugin
{
  class PhysicalKeyStatus
  {
  public:
    const int64_t repeatCount;
    const int64_t scanCode;
    const bool isExtendedKey;
    const bool isMenuKeyDown;
    const bool wasKeyDown;
    const bool isKeyReleased;

    PhysicalKeyStatus(const int64_t& repeatCount,
      const int64_t& scanCode,
      const bool& isExtendedKey,
      const bool& isMenuKeyDown,
      const bool& wasKeyDown,
      const bool& isKeyReleased);
    ~PhysicalKeyStatus() = default;

    static std::unique_ptr<PhysicalKeyStatus> fromCOREWEBVIEW2_PHYSICAL_KEY_STATUS(const COREWEBVIEW2_PHYSICAL_KEY_STATUS& status);

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PHYSICAL_KEY_STATUS_H