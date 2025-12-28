#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_TYPES_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_TYPES_H_

#include <flutter_linux/flutter_linux.h>

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
#endif

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
  PROTECTED_MEDIA_ID = 5,  // Not supported on Linux
  MIDI_SYSEX = 6,          // Not directly supported
  DEVICE_INFO = 7,
  POINTER_LOCK = 8
};

/**
 * Permission response actions.
 */
enum class PermissionResponseAction {
  DENY = 0,
  GRANT = 1,
  PROMPT = 2  // Not used on Linux - will default to deny
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
  static std::vector<PermissionResourceType> getResourceTypes(
      WebKitPermissionRequest* request);
};

/**
 * Response to a permission request.
 */
class PermissionResponse {
 public:
  std::vector<int64_t> resources;
  PermissionResponseAction action;

  PermissionResponse();
  PermissionResponse(FlValue* map);
  ~PermissionResponse() = default;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_PERMISSION_TYPES_H_
