import 'dart:convert';

import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

part 'javascript_handler_callback.g.dart';

///Use [JavaScriptHandlerFunction] instead.
@Deprecated('Use JavaScriptHandlerFunction instead')
typedef dynamic JavaScriptHandlerCallback(List<dynamic> arguments);

///This type represents a callback, added with [PlatformInAppWebViewController.addJavaScriptHandler], that listens to post messages sent from JavaScript.
///
///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
///The iOS/macOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
///
///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
///
///Also, a [JavaScriptHandlerFunction] can return json data to the JavaScript side.
///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
typedef dynamic JavaScriptHandlerFunction(JavaScriptHandlerFunctionData data);

///A class that represents the data passed to a [JavaScriptHandlerFunction] added with [PlatformInAppWebViewController.addJavaScriptHandler].
@ExchangeableObject()
class JavaScriptHandlerFunctionData_ {
  List<dynamic> args;
  WebUri origin;
  bool isMainFrame;
  WebUri requestUrl;

  JavaScriptHandlerFunctionData_({
    this.args = const [],
    required this.origin,
    required this.isMainFrame,
    required this.requestUrl,
  });
}
