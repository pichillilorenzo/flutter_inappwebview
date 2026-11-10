#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_GDK_SCALE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_GDK_SCALE_H_

#include <algorithm>
#include <cerrno>
#include <cmath>
#include <cstdlib>
#include <optional>

namespace flutter_inappwebview_plugin {

inline std::optional<double> ParseExplicitGdkScale(const char* value) {
  if (value == nullptr || *value == '\0') {
    return std::nullopt;
  }

  errno = 0;
  char* end = nullptr;
  const double scale = std::strtod(value, &end);
  if (end == value || *end != '\0' || errno == ERANGE ||
      !std::isfinite(scale) || std::floor(scale) != scale || scale < 1.0 ||
      scale > 4.0) {
    return std::nullopt;
  }
  return scale;
}

inline double EffectiveWpeScale(double flutter_scale, const char* gdk_scale) {
  const auto explicit_scale = ParseExplicitGdkScale(gdk_scale);
  return explicit_scale ? std::max(flutter_scale, *explicit_scale)
                        : flutter_scale;
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_GDK_SCALE_H_
