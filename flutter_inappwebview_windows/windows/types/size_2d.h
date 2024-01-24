#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SIZE_2D_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SIZE_2D_H_

#include <flutter/standard_method_codec.h>
#include <optional>

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
  class Size2D
  {
  public:
    const double width;
    const double height;

    Size2D(const double& width, const double& height);
    Size2D(const flutter::EncodableMap& map);
    ~Size2D() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SIZE_2D_H_