#include "hit_test_result.h"

#include <wpe/webkit.h>

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

HitTestResult HitTestResult::fromWebKitHitTestResult(void* hit_test_result_ptr) {
  if (hit_test_result_ptr == nullptr) {
    return HitTestResult(HitTestResultType::UNKNOWN_TYPE);
  }

  auto* hit_test_result = static_cast<WebKitHitTestResult*>(hit_test_result_ptr);

  // Determine the type based on WebKit hit test result context
  // Priority matters: link+image = SRC_IMAGE_ANCHOR_TYPE, otherwise check each type
  if (webkit_hit_test_result_context_is_link(hit_test_result) &&
      webkit_hit_test_result_context_is_image(hit_test_result)) {
    // Image that is also a link
    const char* uri = webkit_hit_test_result_get_link_uri(hit_test_result);
    return HitTestResult(HitTestResultType::SRC_IMAGE_ANCHOR_TYPE,
                         uri ? std::optional<std::string>(uri) : std::nullopt);
  } else if (webkit_hit_test_result_context_is_link(hit_test_result)) {
    const char* uri = webkit_hit_test_result_get_link_uri(hit_test_result);
    return HitTestResult(HitTestResultType::SRC_ANCHOR_TYPE,
                         uri ? std::optional<std::string>(uri) : std::nullopt);
  } else if (webkit_hit_test_result_context_is_image(hit_test_result)) {
    const char* uri = webkit_hit_test_result_get_image_uri(hit_test_result);
    return HitTestResult(HitTestResultType::IMAGE_TYPE,
                         uri ? std::optional<std::string>(uri) : std::nullopt);
  } else if (webkit_hit_test_result_context_is_media(hit_test_result)) {
    // Media elements (video/audio) - use IMAGE_TYPE as there's no specific media type
    const char* uri = webkit_hit_test_result_get_media_uri(hit_test_result);
    return HitTestResult(HitTestResultType::IMAGE_TYPE,
                         uri ? std::optional<std::string>(uri) : std::nullopt);
  } else if (webkit_hit_test_result_context_is_editable(hit_test_result)) {
    return HitTestResult(HitTestResultType::EDIT_TEXT_TYPE);
  }

  // Default: unknown type
  return HitTestResult(HitTestResultType::UNKNOWN_TYPE);
}

FlValue* HitTestResult::toFlValue() const {
  // Convert type enum to the integer value expected by Dart
  int64_t type_value = static_cast<int64_t>(type_);

  return to_fl_map({
      {"type", make_fl_value(type_value)},
      {"extra", make_fl_value(extra_)},
  });
}

}  // namespace flutter_inappwebview_plugin
