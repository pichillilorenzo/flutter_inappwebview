#include "permission_types.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// === PermissionRequest ===

PermissionRequest::PermissionRequest(
    const std::optional<std::string>& origin,
    const std::vector<PermissionResourceType>& resourceTypes)
    : origin(origin), webkitRequest(nullptr) {
  for (const auto& type : resourceTypes) {
    resources.push_back(static_cast<int64_t>(type));
  }
}

FlValue* PermissionRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();
  
  if (origin.has_value()) {
    fl_value_set_string_take(map, "origin",
                             fl_value_new_string(origin.value().c_str()));
  } else {
    fl_value_set_string_take(map, "origin", fl_value_new_null());
  }
  
  FlValue* resourcesList = fl_value_new_list();
  for (int64_t res : resources) {
    fl_value_append_take(resourcesList, fl_value_new_int(res));
  }
  fl_value_set_string_take(map, "resources", resourcesList);
  
  // frame is always null for WebKitGTK (no easy way to get frame info)
  fl_value_set_string_take(map, "frame", fl_value_new_null());
  
  return map;
}

std::vector<PermissionResourceType> PermissionRequest::getResourceTypes(
    WebKitPermissionRequest* request) {
  std::vector<PermissionResourceType> types;
  
  if (WEBKIT_IS_GEOLOCATION_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::GEOLOCATION);
  }
  else if (WEBKIT_IS_NOTIFICATION_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::NOTIFICATIONS);
  }
  else if (WEBKIT_IS_USER_MEDIA_PERMISSION_REQUEST(request)) {
    gboolean isAudio = FALSE;
    gboolean isVideo = FALSE;
    
    g_object_get(request,
                 "is-for-audio-device", &isAudio,
                 "is-for-video-device", &isVideo,
                 nullptr);
    
    if (isAudio && isVideo) {
      types.push_back(PermissionResourceType::CAMERA_AND_MICROPHONE);
    } else if (isAudio) {
      types.push_back(PermissionResourceType::MICROPHONE);
    } else if (isVideo) {
      types.push_back(PermissionResourceType::CAMERA);
    }
  }
#ifndef USE_WPE_WEBKIT
  // WEBKIT_IS_POINTER_LOCK_PERMISSION_REQUEST is not available in WPE WebKit
  else if (WEBKIT_IS_POINTER_LOCK_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::POINTER_LOCK);
  }
#endif
  else if (WEBKIT_IS_DEVICE_INFO_PERMISSION_REQUEST(request)) {
    types.push_back(PermissionResourceType::DEVICE_INFO);
  }
  
  return types;
}

// === PermissionResponse ===

PermissionResponse::PermissionResponse()
    : action(PermissionResponseAction::DENY) {}

PermissionResponse::PermissionResponse(FlValue* map)
    : action(PermissionResponseAction::DENY) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }
  
  int64_t actionInt = get_fl_map_value<int64_t>(map, "action", 0);
  action = static_cast<PermissionResponseAction>(actionInt);
  
  FlValue* resourcesValue = fl_value_lookup_string(map, "resources");
  if (resourcesValue != nullptr &&
      fl_value_get_type(resourcesValue) == FL_VALUE_TYPE_LIST) {
    size_t len = fl_value_get_length(resourcesValue);
    for (size_t i = 0; i < len; i++) {
      FlValue* item = fl_value_get_list_value(resourcesValue, i);
      if (fl_value_get_type(item) == FL_VALUE_TYPE_INT) {
        resources.push_back(fl_value_get_int(item));
      }
    }
  }
}

}  // namespace flutter_inappwebview_plugin
