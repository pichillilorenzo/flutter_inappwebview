// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_hit_test_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the hit result for hitting an HTML elements.
class InAppWebViewHitTestResult {
  ///Additional type-dependant information about the result.
  String? extra;

  ///The type of the hit test result.
  InAppWebViewHitTestResultType? type;
  InAppWebViewHitTestResult({this.extra, this.type});

  ///Gets a possible [InAppWebViewHitTestResult] instance from a [Map] value.
  static InAppWebViewHitTestResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewHitTestResult(
      extra: map['extra'],
      type: InAppWebViewHitTestResultType.fromNativeValue(map['type']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "extra": extra,
      "type": type?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppWebViewHitTestResult{extra: $extra, type: $type}';
  }
}
