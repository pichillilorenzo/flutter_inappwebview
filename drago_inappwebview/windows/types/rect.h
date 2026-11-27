#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_RECT_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_RECT_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "../utils/flutter.h"

namespace drago_inappwebview_plugin
{
  class Rect
  {
  public:
    const double x;
    const double y;
    const double width;
    const double height;

    Rect(const double& x, const double& y, const double& width, const double& height);
    Rect(const flutter::EncodableMap& map);
    ~Rect() = default;

    bool operator==(const Rect& other)
    {
      return x == other.x && y == other.y && width == other.width && height == other.height;
    }
    bool operator!=(const Rect& other)
    {
      return !(*this == other);
    }

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_RECT_H_