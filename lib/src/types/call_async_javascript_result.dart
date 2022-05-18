import '../in_app_webview/in_app_webview_controller.dart';

///Class that represents either a success or a failure, including an associated value in each case for [InAppWebViewController.callAsyncJavaScript].
class CallAsyncJavaScriptResult {
  ///It contains the success value.
  dynamic value;

  ///It contains the failure value.
  String? error;

  CallAsyncJavaScriptResult({this.value, this.error});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"value": value, "error": error};
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