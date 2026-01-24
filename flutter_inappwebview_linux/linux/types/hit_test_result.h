#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HIT_TEST_RESULT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HIT_TEST_RESULT_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/// Hit test result types matching InAppWebViewHitTestResultType in Dart
enum class HitTestResultType {
  UNKNOWN_TYPE = 0,
  PHONE_TYPE = 2,
  GEO_TYPE = 3,
  EMAIL_TYPE = 4,
  IMAGE_TYPE = 5,
  SRC_ANCHOR_TYPE = 7,
  SRC_IMAGE_ANCHOR_TYPE = 8,
  EDIT_TEXT_TYPE = 9
};

/// HitTestResult - represents the result of a hit test on the WebView
///
/// This maps to InAppWebViewHitTestResult in Dart.
/// It contains the type of element hit and optional extra information (like a URL).
class HitTestResult {
 public:
  /// Default constructor - creates an unknown type hit test result
  HitTestResult() : type_(HitTestResultType::UNKNOWN_TYPE) {}

  /// Constructor with type and optional extra data
  HitTestResult(HitTestResultType type, const std::optional<std::string>& extra = std::nullopt)
      : type_(type), extra_(extra) {}

  /// Construct from a WebKitHitTestResult pointer
  /// This extracts the relevant information from the WPE WebKit hit test result
  static HitTestResult fromWebKitHitTestResult(void* hit_test_result);

  /// Convert to FlValue map for Dart serialization
  FlValue* toFlValue() const;

  // Getters
  HitTestResultType type() const { return type_; }
  const std::optional<std::string>& extra() const { return extra_; }

 private:
  HitTestResultType type_;
  std::optional<std::string> extra_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HIT_TEST_RESULT_H_
