import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'in_app_webview.dart' show InAppWebViewController;

var uuidGenerator = new Uuid();

typedef Future<dynamic> ListenerCallback(MethodCall call);

///This type represents a callback, added with [addJavaScriptHandler], that listens to post messages sent from JavaScript.
///
///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
///
///The JavaScript function that can be used to call the handler is `window.flutter_inappbrowser.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
///
///Also, a [JavaScriptHandlerCallback] can return json data to the JavaScript side.
///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
typedef dynamic JavaScriptHandlerCallback(List<dynamic> arguments);

///Enum representing the level of a console message.
enum ConsoleMessageLevel {
  DEBUG, ERROR, LOG, TIP, WARNING
}

///Public class representing a resource request of the [InAppBrowser] WebView.
///It is used by the method [InAppBrowser.onLoadResource()].
class WebResourceRequest {

  String url;
  Map<String, String> headers;
  String method;

  WebResourceRequest(this.url, this.headers, this.method);

}

///Public class representing a resource response of the [InAppBrowser] WebView.
///It is used by the method [InAppBrowser.onLoadResource()].
class WebResourceResponse {

  String url;
  Map<String, String> headers;
  int statusCode;
  int startTime;
  int duration;
  Uint8List data;

  WebResourceResponse(this.url, this.headers, this.statusCode, this.startTime, this.duration, this.data);

}

///Public class representing the response returned by the [onLoadResourceCustomScheme()] event of [InAppWebView].
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  String base64data;
  String contentType;
  String contentEnconding;

  CustomSchemeResponse(this.base64data, this.contentType, this.contentEnconding);

  Map<String, dynamic> toJson() {
    return {
      'content-type': this.contentType,
      'content-encoding': this.contentEnconding,
      'base64data': this.base64data
    };
  }
}

///Public class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, override the [InAppBrowser.onConsoleMessage()] function.
class ConsoleMessage {

  String sourceURL = "";
  int lineNumber = 1;
  String message = "";
  ConsoleMessageLevel messageLevel = ConsoleMessageLevel.LOG;

  ConsoleMessage(this.sourceURL, this.lineNumber, this.message, this.messageLevel);
}

typedef onWebViewCreatedCallback = void Function(InAppWebViewController controller);
typedef onWebViewLoadStartCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadStopCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadErrorCallback = void Function(InAppWebViewController controller, String url, int code, String message);
typedef onWebViewProgressChangedCallback = void Function(InAppWebViewController controller, int progress);
typedef onWebViewConsoleMessageCallback = void Function(InAppWebViewController controller, ConsoleMessage consoleMessage);
typedef shouldOverrideUrlLoadingCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadResourceCallback = void Function(InAppWebViewController controller, WebResourceResponse response, WebResourceRequest request);
typedef onWebViewScrollChangedCallback = void Function(InAppWebViewController controller, int x, int y);
typedef onDownloadStartCallback = void Function(InAppWebViewController controller, String url);
typedef onLoadResourceCustomSchemeCallback = Future<CustomSchemeResponse> Function(InAppWebViewController controller, String scheme, String url);
typedef onTargetBlankCallback = void Function(InAppWebViewController controller, String url);