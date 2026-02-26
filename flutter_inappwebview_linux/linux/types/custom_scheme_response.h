#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

/**
 * CustomSchemeResponse - Response for custom URI scheme requests.
 *
 * This class represents the response returned by the onLoadResourceWithCustomScheme
 * event. It allows loading a specific resource with custom scheme.
 */
class CustomSchemeResponse {
 public:
  // Data to be returned for the custom scheme request
  std::vector<uint8_t> data;

  // Content-Type of the data, such as "image/png"
  std::string contentType;

  // Content-Encoding of the data, such as "utf-8"
  std::string contentEncoding;

  CustomSchemeResponse();
  explicit CustomSchemeResponse(FlValue* map);
  ~CustomSchemeResponse() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CUSTOM_SCHEME_RESPONSE_H_
