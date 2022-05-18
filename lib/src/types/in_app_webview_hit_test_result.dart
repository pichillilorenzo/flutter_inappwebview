import 'in_app_webview_hit_test_result_type.dart';

///Class that represents the hit result for hitting an HTML elements.
class InAppWebViewHitTestResult {
  ///The type of the hit test result.
  InAppWebViewHitTestResultType? type;

  ///Additional type-dependant information about the result.
  String? extra;

  InAppWebViewHitTestResult({this.type, this.extra});

  ///Gets a possible [InAppWebViewHitTestResult] instance from a [Map] value.
  static InAppWebViewHitTestResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return InAppWebViewHitTestResult(
        type: InAppWebViewHitTestResultType.fromValue(map["type"]),
        extra: map["extra"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"type": type?.toValue(), "extra": extra};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}