#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_IMAGE_FORMAT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_IMAGE_FORMAT_H_

#include <optional>
#include <WebView2.h>

namespace flutter_inappwebview_plugin
{
  enum class FaviconImageFormat {
    png = 0,
    jpeg = 1
  };

  inline FaviconImageFormat FaviconImageFormatFromInteger(const std::optional<int64_t>& value)
  {
    if (!value.has_value()) {
      return FaviconImageFormat::png;
    }
    switch (value.value()) {
    case 1:
      return FaviconImageFormat::jpeg;
    case 0:
    default:
      return FaviconImageFormat::png;
    }
  }

  inline COREWEBVIEW2_FAVICON_IMAGE_FORMAT FaviconImageFormatToCoreWebView2(const FaviconImageFormat& value)
  {
    switch (value) {
    case FaviconImageFormat::jpeg:
      return COREWEBVIEW2_FAVICON_IMAGE_FORMAT_JPEG;
    case FaviconImageFormat::png:
    default:
      return COREWEBVIEW2_FAVICON_IMAGE_FORMAT_PNG;
    }
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FAVICON_IMAGE_FORMAT_H_