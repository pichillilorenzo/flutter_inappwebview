#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_ACCELERATOR_KEY_PRESSED_DETAIL_H
#define DRAGO_INAPPWEBVIEW_PLUGIN_ACCELERATOR_KEY_PRESSED_DETAIL_H

#include <flutter/standard_method_codec.h>
#include <optional>
#include <WebView2.h>
#include <wil/com.h>

#include "physical_key_status.h"

namespace drago_inappwebview_plugin
{
  class AcceleratorKeyPressedDetail
  {
  public:
    const std::optional<int64_t> keyEventKind;
    const std::optional<std::shared_ptr<PhysicalKeyStatus>> physicalKeyStatus;
    const std::optional<int64_t> virtualKey;

    AcceleratorKeyPressedDetail(const std::optional<int64_t>& keyEventKind,
      const std::optional<std::shared_ptr<PhysicalKeyStatus>> physicalKeyStatus,
      const std::optional<int64_t>& virtualKey);
    ~AcceleratorKeyPressedDetail() = default;

    static std::unique_ptr<AcceleratorKeyPressedDetail> fromICoreWebView2AcceleratorKeyPressedEventArgs(const wil::com_ptr<ICoreWebView2AcceleratorKeyPressedEventArgs> args);

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_ACCELERATOR_KEY_PRESSED_DETAIL_H