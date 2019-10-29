import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'in_app_webview.dart';

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

///Class representing the level of a console message.
class ConsoleMessageLevel {
  final int _value;
  const ConsoleMessageLevel._internal(this._value);
  static ConsoleMessageLevel fromValue(int value) {
    if (value >= 0 && value <= 4)
      return ConsoleMessageLevel._internal(value);
    return null;
  }
  toValue() => _value;

  static const TIP = const ConsoleMessageLevel._internal(0);
  static const LOG = const ConsoleMessageLevel._internal(1);
  static const WARNING = const ConsoleMessageLevel._internal(2);
  static const ERROR = const ConsoleMessageLevel._internal(3);
  static const DEBUG = const ConsoleMessageLevel._internal(4);
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


class JsAlertResponseAction {
  final int _value;
  const JsAlertResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsAlertResponseAction._internal(0);
}

class JsAlertResponse {
  String message;
  String confirmButtonTitle;
  bool handledByClient;
  JsAlertResponseAction action;

  JsAlertResponse({this.message = "", this.handledByClient = false, this.confirmButtonTitle = "", this.action = JsAlertResponseAction.CONFIRM});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
    };
  }
}

class JsConfirmResponseAction {
  final int _value;
  const JsConfirmResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsConfirmResponseAction._internal(0);
  static const CANCEL = const JsConfirmResponseAction._internal(1);
}

class JsConfirmResponse {
  String message;
  String confirmButtonTitle;
  String cancelButtonTitle;
  bool handledByClient;
  JsConfirmResponseAction action;

  JsConfirmResponse({this.message = "", this.handledByClient = false, this.confirmButtonTitle = "", this.cancelButtonTitle = "", this.action = JsConfirmResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
    };
  }
}

class JsPromptResponseAction {
  final int _value;
  const JsPromptResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsPromptResponseAction._internal(0);
  static const CANCEL = const JsPromptResponseAction._internal(1);
}

class JsPromptResponse {
  String message;
  String defaultValue;
  String confirmButtonTitle;
  String cancelButtonTitle;
  bool handledByClient;
  String value;
  JsPromptResponseAction action;

  JsPromptResponse({this.message = "", this.defaultValue = "", this.handledByClient = false, this.confirmButtonTitle = "", this.cancelButtonTitle = "", this.value, this.action = JsPromptResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "defaultValue": defaultValue,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "value": value,
      "action": action?.toValue()
    };
  }
}

class SafeBrowsingThreat {
  final int _value;
  const SafeBrowsingThreat._internal(this._value);
  static SafeBrowsingThreat fromValue(int value) {
    if (value >= 0 && value <= 4)
      return SafeBrowsingThreat._internal(value);
    return null;
  }
  toValue() => _value;

  static const SAFE_BROWSING_THREAT_UNKNOWN = const SafeBrowsingThreat._internal(0);
  static const SAFE_BROWSING_THREAT_MALWARE = const SafeBrowsingThreat._internal(1);
  static const SAFE_BROWSING_THREAT_PHISHING = const SafeBrowsingThreat._internal(2);
  static const SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE = const SafeBrowsingThreat._internal(3);
  static const SAFE_BROWSING_THREAT_BILLING = const SafeBrowsingThreat._internal(4);
}

class SafeBrowsingResponseAction {
  final int _value;
  const SafeBrowsingResponseAction._internal(this._value);
  toValue() => _value;

  static const BACK_TO_SAFETY = const SafeBrowsingResponseAction._internal(0);
  static const PROCEED = const SafeBrowsingResponseAction._internal(1);
  static const SHOW_INTERSTITIAL = const SafeBrowsingResponseAction._internal(2);
}
class SafeBrowsingResponse {
  bool report;
  SafeBrowsingResponseAction action;

  SafeBrowsingResponse({this.report = true, this.action = SafeBrowsingResponseAction.SHOW_INTERSTITIAL});

  Map<String, dynamic> toMap() {
    return {
      "report": report,
      "action": action?.toValue()
    };
  }
}

class HttpAuthResponseAction {
  final int _value;
  const HttpAuthResponseAction._internal(this._value);
  toValue() => _value;

  static const CANCEL = const HttpAuthResponseAction._internal(0);
  static const PROCEED = const HttpAuthResponseAction._internal(1);
  static const USE_HTTP_AUTH_USERNAME_PASSWORD = const HttpAuthResponseAction._internal(2);
}

class HttpAuthResponse {
  String username;
  String password;
  bool permanentPersistence;
  HttpAuthResponseAction action;

  HttpAuthResponse({this.username = "", this.password = "", this.permanentPersistence = false, this.action = HttpAuthResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "permanentPersistence": permanentPersistence,
      "action": action?.toValue()
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
typedef onJsAlertCallback = Future<JsAlertResponse> Function(InAppWebViewController controller, String message);
typedef onJsConfirmCallback = Future<JsConfirmResponse> Function(InAppWebViewController controller, String message);
typedef onJsPromptCallback = Future<JsPromptResponse> Function(InAppWebViewController controller, String message, String defaultValue);
typedef onSafeBrowsingHitCallback = Future<SafeBrowsingResponse> Function(InAppWebViewController controller, String url, SafeBrowsingThreat threatType);
typedef onReceivedHttpAuthRequestCallback = Future<HttpAuthResponse> Function(InAppWebViewController controller, String url, String realm);