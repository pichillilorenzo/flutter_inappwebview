#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_REQUEST_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <cstdint>
#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

/**
 * Permission resource types that can be requested.
 */
enum class PermissionResourceType {
  CAMERA = 0,
  MICROPHONE = 1,
  CAMERA_AND_MICROPHONE = 2,
  GEOLOCATION = 3,
  NOTIFICATIONS = 4,
  PROTECTED_MEDIA_ID = 5,  // EME/DRM permission (WebKitMediaKeySystemPermissionRequest)
  MIDI_SYSEX = 6,          // Not directly supported
  DEVICE_INFO = 7,
  POINTER_LOCK = 8
};

/**
 * Represents a permission request from web content.
 */
class PermissionRequest {
 public:
  std::optional<std::string> origin;
  std::vector<int64_t> resources;

  // Reference to the WebKit request to allow/deny later
  WebKitPermissionRequest* webkitRequest;

  PermissionRequest(const std::optional<std::string>& origin,
                    const std::vector<PermissionResourceType>& resourceTypes);
  ~PermissionRequest() = default;

  FlValue* toFlValue() const;

  /**
   * Determine the permission resource type from a WebKitPermissionRequest.
   */
  static std::vector<PermissionResourceType> getResourceTypes(WebKitPermissionRequest* request);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_REQUEST_H_
