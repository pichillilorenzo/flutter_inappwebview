#include "permission_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

PermissionRequest::PermissionRequest(const std::optional<std::string>& origin,
                                     const std::vector<PermissionResourceType>& resourceTypes)
    : origin(origin), webkitRequest(nullptr) {
  for (const auto& type : resourceTypes) {
    resources.push_back(static_cast<int64_t>(type));
  }
}

FlValue* PermissionRequest::toFlValue() const {
  return to_fl_map({
      {"origin", make_fl_value(origin)},
      {"resources", make_fl_value(resources)},
      {"frame", make_fl_value()},  // always null for WPE WebKit
  });
}

std::vector<PermissionResourceType> PermissionRequest::getResourceTypes(
    WebKitPermissionRequest* request) {
  std::vector<PermissionResourceType> types;

  if (WEBKIT_IS_GEOLOCATION_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::GEOLOCATION);
  } else if (WEBKIT_IS_NOTIFICATION_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::NOTIFICATIONS);
  } else if (WEBKIT_IS_USER_MEDIA_PERMISSION_REQUEST(request)) {
    gboolean isAudio = FALSE;
    gboolean isVideo = FALSE;

    g_object_get(request, "is-for-audio-device", &isAudio, "is-for-video-device", &isVideo,
                 nullptr);

    if (isAudio && isVideo) {
      types.push_back(PermissionResourceType::CAMERA_AND_MICROPHONE);
    } else if (isAudio) {
      types.push_back(PermissionResourceType::MICROPHONE);
    } else if (isVideo) {
      types.push_back(PermissionResourceType::CAMERA);
    }
  }
  // Note: WEBKIT_IS_POINTER_LOCK_PERMISSION_REQUEST is not available in WPE WebKit
  else if (WEBKIT_IS_DEVICE_INFO_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::DEVICE_INFO);
  } else if (WEBKIT_IS_MEDIA_KEY_SYSTEM_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::PROTECTED_MEDIA_ID);
  }

  return types;
}

}  // namespace flutter_inappwebview_plugin
