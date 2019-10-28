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

///Public class representing a resource response of the [InAppBrowser] WebView.
///It is used by the method [InAppBrowser.onLoadResource()].
class WebResourceResponse {

  ///A string representing the type of resource.
  String initiatorType;
  ///Resource URL.
  String url;
  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double startTime;
  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double duration;

  WebResourceResponse(this.initiatorType, this.url, this.startTime, this.duration);

}

///Public class representing the response returned by the [onLoadResourceCustomScheme()] event of [InAppWebView].
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  ///Data enconded to 'base64'.
  String base64data;
  ///Content-Type of the data, such as `image/png`.
  String contentType;
  ///Content-Enconding of the data, such as `utf-8`.
  String contentEnconding;

  CustomSchemeResponse(this.base64data, this.contentType, {this.contentEnconding = 'utf-8'});

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

///WebHistory class.
///
///This class contains a snapshot of the current back/forward list for a WebView.
class WebHistory {
  List<WebHistoryItem> _list;
  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem> get list => _list;
  ///Index of the current [WebHistoryItem].
  int currentIndex;

  WebHistory(this._list, this.currentIndex);
}

///WebHistoryItem class.
///
///A convenience class for accessing fields in an entry in the back/forward list of a WebView. Each WebHistoryItem is a snapshot of the requested history item.
class WebHistoryItem {
  ///Original url of this history item.
  String originalUrl;
  ///Document title of this history item.
  String title;
  ///Url of this history item.
  String url;
  ///0-based position index in the back-forward [WebHistory.list].
  int index;
  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int offset;

  WebHistoryItem(this.originalUrl, this.title, this.url, this.index, this.offset);
}

///GeolocationPermissionPromptResponse class.
///
///Class used by the host application to set the Geolocation permission state for an origin during the [onGeolocationPermissionsShowPrompt] event.
class GeolocationPermissionShowPromptResponse {
  ///The origin for which permissions are set.
  String origin;
  ///Whether or not the origin should be allowed to use the Geolocation API.
  bool allow;
  ///Whether the permission should be retained beyond the lifetime of a page currently being displayed by a WebView
  bool retain;

  GeolocationPermissionShowPromptResponse(this.origin, this.allow, this.retain);

  Map<String, dynamic> toMap() {
    return {
      "origin": origin,
      "allow": allow,
      "retain": retain
    };
  }
}

typedef onWebViewCreatedCallback = void Function(InAppWebViewController controller);
typedef onWebViewLoadStartCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadStopCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadErrorCallback = void Function(InAppWebViewController controller, String url, int code, String message);
typedef onWebViewProgressChangedCallback = void Function(InAppWebViewController controller, int progress);
typedef onWebViewConsoleMessageCallback = void Function(InAppWebViewController controller, ConsoleMessage consoleMessage);
typedef shouldOverrideUrlLoadingCallback = void Function(InAppWebViewController controller, String url);
typedef onWebViewLoadResourceCallback = void Function(InAppWebViewController controller, WebResourceResponse response);
typedef onWebViewScrollChangedCallback = void Function(InAppWebViewController controller, int x, int y);
typedef onDownloadStartCallback = void Function(InAppWebViewController controller, String url);
typedef onLoadResourceCustomSchemeCallback = Future<CustomSchemeResponse> Function(InAppWebViewController controller, String scheme, String url);
typedef onTargetBlankCallback = void Function(InAppWebViewController controller, String url);
typedef onGeolocationPermissionsShowPromptCallback = Future<GeolocationPermissionShowPromptResponse> Function(InAppWebViewController controller, String origin);