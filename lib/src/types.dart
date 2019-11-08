import 'dart:async';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import 'webview_options.dart';

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
    if (value != null && value >= 0 && value <= 4)
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
class LoadedResource {

  ///A string representing the type of resource.
  String initiatorType;
  ///Resource URL.
  String url;
  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double startTime;
  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double duration;

  LoadedResource(this.initiatorType, this.url, this.startTime, this.duration);

}

///Initial [data] as a content for an [InAppWebView] instance, using [baseUrl] as the base URL for it.
///The [mimeType] property specifies the format of the data.
///The [encoding] property specifies the encoding of the data.
class InAppWebViewInitialData {
  String data;
  String mimeType;
  String encoding;
  String baseUrl;

  InAppWebViewInitialData(this.data, {this.mimeType = "text/html", this.encoding = "utf8", this.baseUrl = "about:blank"});

  Map<String, String> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl
    };
  }
}

/*
///Public class representing a resource request of the WebView.
///It is used by the event [shouldInterceptRequest()].
class WebResourceRequest {

  String url;
  Map<String, String> headers;
  String method;

  WebResourceRequest({@required this.url, @required this.headers, @required this.method});

}

///Public class representing a resource response of the WebView.
///It is used by the event [shouldInterceptRequest()].
class WebResourceResponse {
  String contentType;
  String contentEncoding;
  Uint8List data;

  WebResourceResponse({@required this.contentType, this.contentEncoding = "utf-8", @required this.data}): assert(contentType != null && contentEncoding != null && data != null);

  Map<String, dynamic> toMap() {
    return {
      "contentType": contentType,
      "contentEncoding": contentEncoding,
      "data": data
    };
  }
}*/

///Public class representing the response returned by the [onLoadResourceCustomScheme()] event.
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  ///Data enconded to 'base64'.
  Uint8List data;
  ///Content-Type of the data, such as `image/png`.
  String contentType;
  ///Content-Enconding of the data, such as `utf-8`.
  String contentEnconding;

  CustomSchemeResponse(this.data, this.contentType, {this.contentEnconding = 'utf-8'});

  Map<String, dynamic> toJson() {
    return {
      'content-type': this.contentType,
      'content-encoding': this.contentEnconding,
      'data': this.data
    };
  }
}

///Public class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, use the [onConsoleMessage] event.
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

///JsAlertResponseAction class used by [JsAlertResponse] class.
class JsAlertResponseAction {
  final int _value;
  const JsAlertResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsAlertResponseAction._internal(0);
}

///JsAlertResponse class represents the response used by the [onJsAlert] event to control a JavaScript alert dialog.
class JsAlertResponse {
  ///Message to be displayed in the window.
  String message;
  ///Title of the confirm button.
  String confirmButtonTitle;
  ///Whether the client will handle the alert dialog.
  bool handledByClient;
  ///Action used to confirm that the user hit confirm button.
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

///JsConfirmResponseAction class used by [JsConfirmResponse] class.
class JsConfirmResponseAction {
  final int _value;
  const JsConfirmResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsConfirmResponseAction._internal(0);
  static const CANCEL = const JsConfirmResponseAction._internal(1);
}

///JsConfirmResponse class represents the response used by the [onJsConfirm] event to control a JavaScript confirm dialog.
class JsConfirmResponse {
  ///Message to be displayed in the window.
  String message;
  ///Title of the confirm button.
  String confirmButtonTitle;
  ///Title of the cancel button.
  String cancelButtonTitle;
  ///Whether the client will handle the confirm dialog.
  bool handledByClient;
  ///Action used to confirm that the user hit confirm or cancel button.
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

///JsPromptResponseAction class used by [JsPromptResponse] class.
class JsPromptResponseAction {
  final int _value;
  const JsPromptResponseAction._internal(this._value);
  toValue() => _value;

  static const CONFIRM = const JsPromptResponseAction._internal(0);
  static const CANCEL = const JsPromptResponseAction._internal(1);
}

///JsPromptResponse class represents the response used by the [onJsPrompt] event to control a JavaScript prompt dialog.
class JsPromptResponse {
  ///Message to be displayed in the window.
  String message;
  ///The default value displayed in the prompt dialog.
  String defaultValue;
  ///Title of the confirm button.
  String confirmButtonTitle;
  ///Title of the cancel button.
  String cancelButtonTitle;
  ///Whether the client will handle the prompt dialog.
  bool handledByClient;
  ///Value of the prompt dialog.
  String value;
  ///Action used to confirm that the user hit confirm or cancel button.
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

///
class SafeBrowsingThreat {
  final int _value;
  const SafeBrowsingThreat._internal(this._value);
  static SafeBrowsingThreat fromValue(int value) {
    if (value != null && value >= 0 && value <= 4)
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

///SafeBrowsingResponseAction class used by [SafeBrowsingResponse] class.
class SafeBrowsingResponseAction {
  final int _value;
  const SafeBrowsingResponseAction._internal(this._value);
  toValue() => _value;

  static const BACK_TO_SAFETY = const SafeBrowsingResponseAction._internal(0);
  static const PROCEED = const SafeBrowsingResponseAction._internal(1);
  static const SHOW_INTERSTITIAL = const SafeBrowsingResponseAction._internal(2);
}

///
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

///
class HttpAuthResponseAction {
  final int _value;
  const HttpAuthResponseAction._internal(this._value);
  toValue() => _value;

  static const CANCEL = const HttpAuthResponseAction._internal(0);
  static const PROCEED = const HttpAuthResponseAction._internal(1);
  static const USE_SAVED_HTTP_AUTH_CREDENTIALS = const HttpAuthResponseAction._internal(2);
}

///
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

///
class HttpAuthChallenge {
  int previousFailureCount;
  ProtectionSpace protectionSpace;

  HttpAuthChallenge({@required this.previousFailureCount, @required this.protectionSpace}): assert(previousFailureCount != null && protectionSpace != null);
}

///
class ProtectionSpace {
  String host;
  String protocol;
  String realm;
  int port;

  ProtectionSpace({@required this.host, @required this.protocol, this.realm, this.port}): assert(host != null && protocol != null);
}

///
class HttpAuthCredential {
  String username;
  String password;

  HttpAuthCredential({@required this.username, @required this.password}): assert(username != null && password != null);
}

///
class ServerTrustAuthResponseAction {
  final int _value;
  const ServerTrustAuthResponseAction._internal(this._value);
  toValue() => _value;

  static const CANCEL = const ServerTrustAuthResponseAction._internal(0);
  static const PROCEED = const ServerTrustAuthResponseAction._internal(1);
}

///
class ServerTrustAuthResponse {
  ServerTrustAuthResponseAction action;

  ServerTrustAuthResponse({this.action = ServerTrustAuthResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "action": action?.toValue()
    };
  }
}

///
class ServerTrustChallenge {
  ProtectionSpace protectionSpace;
  int error;
  String message;
  Uint8List serverCertificate;

  ServerTrustChallenge({@required this.protectionSpace, @required this.error, this.message, this.serverCertificate}): assert(protectionSpace != null && error != null);
}

///
class ClientCertResponseAction {
  final int _value;
  const ClientCertResponseAction._internal(this._value);
  toValue() => _value;

  static const CANCEL = const ClientCertResponseAction._internal(0);
  static const PROCEED = const ClientCertResponseAction._internal(1);
  static const IGNORE = const ClientCertResponseAction._internal(2);
}

///
class ClientCertResponse {
  String certificatePath;
  String certificatePassword;
  String androidKeyStoreType;
  ClientCertResponseAction action;

  ClientCertResponse({this.certificatePath, this.certificatePassword = "", this.androidKeyStoreType = "PKCS12", this.action = ClientCertResponseAction.CANCEL}) {
    if (this.action == ClientCertResponseAction.PROCEED)
      assert(certificatePath != null && certificatePath.isNotEmpty);
  }

  Map<String, dynamic> toMap() {
    return {
      "certificatePath": certificatePath,
      "certificatePassword": certificatePassword,
      "androidKeyStoreType": androidKeyStoreType,
      "action": action?.toValue()
    };
  }
}

///
class ClientCertChallenge {
  ProtectionSpace protectionSpace;

  ClientCertChallenge({@required this.protectionSpace}): assert(protectionSpace != null);
}

///
class Favicon {
  String url;
  String rel;
  int width;
  int height;

  Favicon({@required this.url, this.rel, this.width, this.height}): assert(url != null);

  String toString() {
    return "url: $url, rel: $rel, width: $width, height: $height";
  }
}

///
class AndroidInAppWebViewCacheMode {
  final int _value;
  const AndroidInAppWebViewCacheMode._internal(this._value);
  static AndroidInAppWebViewCacheMode fromValue(int value) {
    if (value != null && value >= 0 && value <= 3)
      return AndroidInAppWebViewCacheMode._internal(value);
    return null;
  }
  toValue() => _value;

  static const LOAD_DEFAULT = const AndroidInAppWebViewCacheMode._internal(-1);
  static const LOAD_CACHE_ELSE_NETWORK = const AndroidInAppWebViewCacheMode._internal(1);
  static const LOAD_NO_CACHE = const AndroidInAppWebViewCacheMode._internal(2);
  static const LOAD_CACHE_ONLY = const AndroidInAppWebViewCacheMode._internal(3);
}

///
class AndroidInAppWebViewModeMenuItem {
  final int _value;
  const AndroidInAppWebViewModeMenuItem._internal(this._value);
  static AndroidInAppWebViewModeMenuItem fromValue(int value) {
    if (value != null && value >= 0 && value <= 4)
      return AndroidInAppWebViewModeMenuItem._internal(value);
    return null;
  }
  toValue() => _value;

  static const MENU_ITEM_NONE = const AndroidInAppWebViewModeMenuItem._internal(0);
  static const MENU_ITEM_SHARE = const AndroidInAppWebViewModeMenuItem._internal(1);
  static const MENU_ITEM_WEB_SEARCH = const AndroidInAppWebViewModeMenuItem._internal(2);
  static const MENU_ITEM_PROCESS_TEXT = const AndroidInAppWebViewModeMenuItem._internal(4);
}

///
class AndroidInAppWebViewForceDark {
  final int _value;
  const AndroidInAppWebViewForceDark._internal(this._value);
  static AndroidInAppWebViewForceDark fromValue(int value) {
    if (value != null && value >= 0 && value <= 2)
      return AndroidInAppWebViewForceDark._internal(value);
    return null;
  }
  toValue() => _value;

  static const FORCE_DARK_OFF = const AndroidInAppWebViewForceDark._internal(0);
  static const FORCE_DARK_AUTO = const AndroidInAppWebViewForceDark._internal(1);
  static const FORCE_DARK_ON = const AndroidInAppWebViewForceDark._internal(2);
}

///
class AndroidInAppWebViewLayoutAlgorithm {
  final String _value;
  const AndroidInAppWebViewLayoutAlgorithm._internal(this._value);
  static AndroidInAppWebViewLayoutAlgorithm fromValue(String value) {
    return (["NORMAL", "TEXT_AUTOSIZING"].contains(value)) ? AndroidInAppWebViewLayoutAlgorithm._internal(value) : null;
  }
  toValue() => _value;

  static const NORMAL = const AndroidInAppWebViewLayoutAlgorithm._internal("NORMAL");
  static const TEXT_AUTOSIZING = const AndroidInAppWebViewLayoutAlgorithm._internal("TEXT_AUTOSIZING");
}

///
class AndroidInAppWebViewMixedContentMode {
  final int _value;
  const AndroidInAppWebViewMixedContentMode._internal(this._value);
  static AndroidInAppWebViewMixedContentMode fromValue(int value) {
    if (value != null && value >= 0 && value <= 2)
      return AndroidInAppWebViewMixedContentMode._internal(value);
    return null;
  }
  toValue() => _value;

  static const MIXED_CONTENT_ALWAYS_ALLOW = const AndroidInAppWebViewMixedContentMode._internal(0);
  static const MIXED_CONTENT_NEVER_ALLOW = const AndroidInAppWebViewMixedContentMode._internal(1);
  static const MIXED_CONTENT_COMPATIBILITY_MODE = const AndroidInAppWebViewMixedContentMode._internal(2);
}

///
class IosInAppWebViewSelectionGranularity {
  final int _value;
  const IosInAppWebViewSelectionGranularity._internal(this._value);
  static IosInAppWebViewSelectionGranularity fromValue(int value) {
    if (value != null && value >= 0 && value <= 1)
      return IosInAppWebViewSelectionGranularity._internal(value);
    return null;
  }
  toValue() => _value;

  static const CHARACTER = const IosInAppWebViewSelectionGranularity._internal(0);
  static const DYNAMIC = const IosInAppWebViewSelectionGranularity._internal(1);
}

///
class IosInAppWebViewDataDetectorTypes {
  final String _value;
  const IosInAppWebViewDataDetectorTypes._internal(this._value);
  static IosInAppWebViewDataDetectorTypes fromValue(String value) {
    return (["NONE", "PHONE_NUMBER", "LINK", "ADDRESS", "CALENDAR_EVENT", "TRACKING_NUMBER",
      "TRACKING_NUMBER", "FLIGHT_NUMBER", "LOOKUP_SUGGESTION", "SPOTLIGHT_SUGGESTION", "ALL"].contains(value)) ? IosInAppWebViewDataDetectorTypes._internal(value) : null;
  }
  toValue() => _value;

  static const NONE = const IosInAppWebViewDataDetectorTypes._internal("NONE");
  static const PHONE_NUMBER = const IosInAppWebViewDataDetectorTypes._internal("PHONE_NUMBER");
  static const LINK = const IosInAppWebViewDataDetectorTypes._internal("LINK");
  static const ADDRESS = const IosInAppWebViewDataDetectorTypes._internal("ADDRESS");
  static const CALENDAR_EVENT = const IosInAppWebViewDataDetectorTypes._internal("CALENDAR_EVENT");
  static const TRACKING_NUMBER = const IosInAppWebViewDataDetectorTypes._internal("TRACKING_NUMBER");
  static const FLIGHT_NUMBER = const IosInAppWebViewDataDetectorTypes._internal("FLIGHT_NUMBER");
  static const LOOKUP_SUGGESTION = const IosInAppWebViewDataDetectorTypes._internal("LOOKUP_SUGGESTION");
  static const SPOTLIGHT_SUGGESTION = const IosInAppWebViewDataDetectorTypes._internal("SPOTLIGHT_SUGGESTION");
  static const ALL = const IosInAppWebViewDataDetectorTypes._internal("ALL");
}

///
class InAppWebViewUserPreferredContentMode {
  final int _value;
  const InAppWebViewUserPreferredContentMode._internal(this._value);
  static InAppWebViewUserPreferredContentMode fromValue(int value) {
    if (value != null && value >= 0 && value <= 2)
      return InAppWebViewUserPreferredContentMode._internal(value);
    return null;
  }
  toValue() => _value;

  static const RECOMMENDED = const InAppWebViewUserPreferredContentMode._internal(0);
  static const MOBILE = const InAppWebViewUserPreferredContentMode._internal(1);
  static const DESKTOP = const InAppWebViewUserPreferredContentMode._internal(2);
}

///
class IosWebViewOptionsPresentationStyle {
  final int _value;
  const IosWebViewOptionsPresentationStyle._internal(this._value);
  static IosWebViewOptionsPresentationStyle fromValue(int value) {
    if (value != null && value >= 0 && value <= 9)
      return IosWebViewOptionsPresentationStyle._internal(value);
    return null;
  }
  toValue() => _value;

  static const FULL_SCREEN = const IosWebViewOptionsPresentationStyle._internal(0);
  static const PAGE_SHEET = const IosWebViewOptionsPresentationStyle._internal(1);
  static const FORM_SHEET = const IosWebViewOptionsPresentationStyle._internal(2);
  static const CURRENT_CONTEXT = const IosWebViewOptionsPresentationStyle._internal(3);
  static const CUSTOM = const IosWebViewOptionsPresentationStyle._internal(4);
  static const OVER_FULL_SCREEN = const IosWebViewOptionsPresentationStyle._internal(5);
  static const OVER_CURRENT_CONTEXT = const IosWebViewOptionsPresentationStyle._internal(6);
  static const POPOVER = const IosWebViewOptionsPresentationStyle._internal(7);
  static const NONE = const IosWebViewOptionsPresentationStyle._internal(8);
  static const AUTOMATIC = const IosWebViewOptionsPresentationStyle._internal(9);
}

///
class IosWebViewOptionsTransitionStyle {
  final int _value;
  const IosWebViewOptionsTransitionStyle._internal(this._value);
  static IosWebViewOptionsTransitionStyle fromValue(int value) {
    if (value != null && value >= 0 && value <= 3)
      return IosWebViewOptionsTransitionStyle._internal(value);
    return null;
  }
  toValue() => _value;

  static const COVER_VERTICAL = const IosWebViewOptionsTransitionStyle._internal(0);
  static const FLIP_HORIZONTAL = const IosWebViewOptionsTransitionStyle._internal(1);
  static const CROSS_DISSOLVE = const IosWebViewOptionsTransitionStyle._internal(2);
  static const PARTIAL_CURL = const IosWebViewOptionsTransitionStyle._internal(3);
}

///
class IosSafariOptionsDismissButtonStyle {
  final int _value;
  const IosSafariOptionsDismissButtonStyle._internal(this._value);
  static IosSafariOptionsDismissButtonStyle fromValue(int value) {
    if (value != null && value >= 0 && value <= 2)
      return IosSafariOptionsDismissButtonStyle._internal(value);
    return null;
  }
  toValue() => _value;

  static const DONE = const IosSafariOptionsDismissButtonStyle._internal(0);
  static const CLOSE = const IosSafariOptionsDismissButtonStyle._internal(1);
  static const CANCEL = const IosSafariOptionsDismissButtonStyle._internal(2);
}

///
class InAppWebViewWidgetOptions {
  InAppWebViewOptions inAppWebViewOptions;
  AndroidInAppWebViewOptions androidInAppWebViewOptions;
  IosInAppWebViewOptions iosInAppWebViewOptions;

  InAppWebViewWidgetOptions({this.inAppWebViewOptions, this.androidInAppWebViewOptions, this.iosInAppWebViewOptions});
}

///
class InAppBrowserClassOptions {
  InAppBrowserOptions inAppBrowserOptions;
  AndroidInAppBrowserOptions androidInAppBrowserOptions;
  IosInAppBrowserOptions iosInAppBrowserOptions;
  InAppWebViewWidgetOptions inAppWebViewWidgetOptions;

  InAppBrowserClassOptions({this.inAppBrowserOptions, this.androidInAppBrowserOptions, this.iosInAppBrowserOptions, this.inAppWebViewWidgetOptions});
}

///
class ChromeSafariBrowserClassOptions {
  AndroidChromeCustomTabsOptions androidChromeCustomTabsOptions;
  IosSafariOptions iosSafariOptions;

  ChromeSafariBrowserClassOptions({this.androidChromeCustomTabsOptions, this.iosSafariOptions});
}

///
class AjaxRequestAction {
  final int _value;
  const AjaxRequestAction._internal(this._value);
  toValue() => _value;

  static const ABORT = const AjaxRequestAction._internal(0);
  static const PROCEED = const AjaxRequestAction._internal(1);

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }
}

///
class AjaxRequestEventType {
  final String _value;
  const AjaxRequestEventType._internal(this._value);
  static AjaxRequestEventType fromValue(String value) {
    return (["loadstart", "load", "loadend", "progress", "error", "abort"].contains(value)) ? AjaxRequestEventType._internal(value) : null;
  }
  toValue() => _value;
  String toString() => _value;

  static const LOADSTART = const AjaxRequestEventType._internal("loadstart");
  static const LOAD = const AjaxRequestEventType._internal("load");
  static const LOADEND = const AjaxRequestEventType._internal("loadend");
  static const PROGRESS = const AjaxRequestEventType._internal("progress");
  static const ERROR = const AjaxRequestEventType._internal("error");
  static const ABORT = const AjaxRequestEventType._internal("abort");
}

///
class AjaxRequestEvent {
  AjaxRequestEventType type;
  int loaded;
  bool lengthComputable;

  AjaxRequestEvent({this.type, this.loaded, this.lengthComputable});
}

///
class AjaxRequestReadyState {
  final int _value;
  const AjaxRequestReadyState._internal(this._value);
  static AjaxRequestReadyState fromValue(int value) {
    if (value != null && value >= 0 && value <= 4)
      return AjaxRequestReadyState._internal(value);
    return null;
  }
  toValue() => _value;
  String toString() => _value.toString();

  static const UNSENT = const AjaxRequestReadyState._internal(0);
  static const OPENED = const AjaxRequestReadyState._internal(1);
  static const HEADERS_RECEIVED = const AjaxRequestReadyState._internal(2);
  static const LOADING = const AjaxRequestReadyState._internal(3);
  static const DONE = const AjaxRequestReadyState._internal(4);
}

///
class AjaxRequest {
  dynamic data;
  String method;
  String url;
  bool isAsync;
  String user;
  String password;
  bool withCredentials;
  Map<dynamic, dynamic> headers;
  AjaxRequestReadyState readyState;
  int status;
  String responseURL;
  String responseType;
  String responseText;
  String statusText;
  Map<dynamic, dynamic> responseHeaders;
  AjaxRequestEvent event;
  AjaxRequestAction action;

  AjaxRequest({this.data, this.method, this.url, this.isAsync, this.user, this.password,
    this.withCredentials, this.headers, this.readyState, this.status, this.responseURL, this.responseType,
    this.responseText, this.statusText, this.responseHeaders, this.event, this.action = AjaxRequestAction.PROCEED});

  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "method": method,
      "url": url,
      "isAsync": isAsync,
      "user": user,
      "password": password,
      "withCredentials": withCredentials,
      "headers": headers,
      "readyState": readyState?.toValue(),
      "status": status,
      "responseURL": responseURL,
      "responseType": responseType,
      "responseText": responseText,
      "statusText": statusText,
      "responseHeaders": responseHeaders,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }
}

///
class FetchRequestAction {
  final int _value;
  const FetchRequestAction._internal(this._value);
  toValue() => _value;

  static const ABORT = const FetchRequestAction._internal(0);
  static const PROCEED = const FetchRequestAction._internal(1);
}

///
class FetchRequestCredential {
  String type;

  FetchRequestCredential({this.type});

  Map<String, dynamic> toMap() {
    return {
      "type": type
    };
  }
}

///
class FetchRequestCredentialDefault extends FetchRequestCredential {
  String value;

  FetchRequestCredentialDefault({type, this.value}): super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "value": value,
    };
  }
}

///
class FetchRequestFederatedCredential extends FetchRequestCredential {
  dynamic id;
  String name;
  String protocol;
  String provider;
  String iconURL;

  FetchRequestFederatedCredential({type, this.id, this.name, this.protocol, this.provider, this.iconURL}): super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "protocol": protocol,
      "provider": provider,
      "iconURL": iconURL
    };
  }
}

///
class FetchRequestPasswordCredential extends FetchRequestCredential {
  dynamic id;
  String name;
  String password;
  String iconURL;

  FetchRequestPasswordCredential({type, this.id, this.name, this.password, this.iconURL}): super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "password": password,
      "iconURL": iconURL
    };
  }
}

///
class FetchRequest {
  String url;
  String method;
  Map<String, dynamic> headers;
  Uint8List body;
  String mode;
  FetchRequestCredential credentials;
  String cache;
  String redirect;
  String referrer;
  String referrerPolicy;
  String integrity;
  bool keepalive;
  FetchRequestAction action;

  FetchRequest({this.url, this.method, this.headers, this.body, this.mode, this.credentials,
    this.cache, this.redirect, this.referrer, this.referrerPolicy, this.integrity, this.keepalive,
    this.action = FetchRequestAction.PROCEED});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "method": method,
      "headers": headers,
      "body": body,
      "mode": mode,
      "credentials": credentials?.toMap(),
      "cache": cache,
      "redirect": redirect,
      "referrer": referrer,
      "referrerPolicy": referrerPolicy,
      "integrity": integrity,
      "keepalive": keepalive,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  static FetchRequestCredential createFetchRequestCredentialFromMap(credentialsMap) {
    if (credentialsMap != null) {
      if (credentialsMap["type"] == "default") {
        return FetchRequestCredentialDefault(type: credentialsMap["type"], value: credentialsMap["value"]);
      } else if (credentialsMap["type"] == "federated") {
        return FetchRequestFederatedCredential(type: credentialsMap["type"], id: credentialsMap["id"], name: credentialsMap["name"],
            protocol: credentialsMap["protocol"], provider: credentialsMap["provider"], iconURL: credentialsMap["iconURL"]);
      } else if (credentialsMap["type"] == "password") {
        return FetchRequestPasswordCredential(type: credentialsMap["type"], id: credentialsMap["id"], name: credentialsMap["name"],
            password: credentialsMap["password"], iconURL: credentialsMap["iconURL"]);
      }
    }
    return null;
  }
}