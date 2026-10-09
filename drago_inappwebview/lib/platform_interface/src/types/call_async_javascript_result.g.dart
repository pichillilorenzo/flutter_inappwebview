// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_async_javascript_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents either a success or a failure, including an associated value in each case for [PlatformInAppWebViewController.callAsyncJavaScript].
class CallAsyncJavaScriptResult {
  ///It contains the failure value.
  String? error;

  ///It contains the success value.
  dynamic value;
  CallAsyncJavaScriptResult({this.error, this.value});

  ///Gets a possible [CallAsyncJavaScriptResult] instance from a [Map] value.
  static CallAsyncJavaScriptResult? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CallAsyncJavaScriptResult(
      error: map['error'],
      value: map['value'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"error": error, "value": value};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CallAsyncJavaScriptResult{error: $error, value: $value}';
  }
}
