// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_async_javascript_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents either a success or a failure, including an associated value in each case for [InAppWebViewController.callAsyncJavaScript].
class CallAsyncJavaScriptResult {
  ///It contains the success value.
  dynamic value;

  ///It contains the failure value.
  String? error;
  CallAsyncJavaScriptResult({this.value, this.error});

  ///Gets a possible [CallAsyncJavaScriptResult] instance from a [Map] value.
  static CallAsyncJavaScriptResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = CallAsyncJavaScriptResult(
      value: map['value'],
      error: map['error'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "value": value,
      "error": error,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CallAsyncJavaScriptResult{value: $value, error: $error}';
  }
}
