// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_hit_test_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
    final instance = InAppWebViewHitTestResult(
      type: InAppWebViewHitTestResultType.fromNativeValue(map['type']),
      extra: map['extra'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type?.toNativeValue(),
      "extra": extra,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppWebViewHitTestResult{type: $type, extra: $extra}';
  }
}
