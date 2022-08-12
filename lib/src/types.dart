import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'X509Certificate/x509_certificate.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'in_app_browser.dart';
import 'webview.dart';
import 'webview_options.dart';
import 'in_app_webview_controller.dart';
import 'http_auth_credentials_database.dart';
import 'chrome_safari_browser.dart';
import 'cookie_manager.dart';
import 'web_storage_manager.dart';
import 'web_storage.dart';

var uuidGenerator = new Uuid();

///This type represents a callback, added with [InAppWebViewController.addJavaScriptHandler], that listens to post messages sent from JavaScript.
///
///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
///
///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args);`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
///
///Also, a [JavaScriptHandlerCallback] can return json data to the JavaScript side.
///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
typedef dynamic JavaScriptHandlerCallback(List<dynamic> arguments);

///Class representing the level of a console message.
class ConsoleMessageLevel {
  final int _value;

  const ConsoleMessageLevel._internal(this._value);

  static final Set<ConsoleMessageLevel> values = [
    ConsoleMessageLevel.TIP,
    ConsoleMessageLevel.LOG,
    ConsoleMessageLevel.WARNING,
    ConsoleMessageLevel.ERROR,
    ConsoleMessageLevel.DEBUG,
  ].toSet();

  static ConsoleMessageLevel fromValue(int value) {
    if (value != null)
      return ConsoleMessageLevel.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "TIP";
      case 2:
        return "WARNING";
      case 3:
        return "ERROR";
      case 4:
        return "DEBUG";
      case 1:
      default:
        return "LOG";
    }
  }

  static const TIP = const ConsoleMessageLevel._internal(0);
  static const LOG = const ConsoleMessageLevel._internal(1);
  static const WARNING = const ConsoleMessageLevel._internal(2);
  static const ERROR = const ConsoleMessageLevel._internal(3);
  static const DEBUG = const ConsoleMessageLevel._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class representing a resource response of the [WebView].
///It is used by the method [WebView.onLoadResource].
class LoadedResource {
  ///A string representing the type of resource.
  String initiatorType;

  ///Resource URL.
  String url;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double startTime;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double duration;

  LoadedResource({this.initiatorType, this.url, this.startTime, this.duration});

  Map<String, dynamic> toMap() {
    return {
      "initiatorType": initiatorType,
      "url": url,
      "startTime": startTime,
      "duration": duration
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Initial [data] as a content for an [WebView] instance, using [baseUrl] as the base URL for it.
class InAppWebViewInitialData {
  ///A String of data in the given encoding.
  String data;

  ///The MIME type of the data, e.g. "text/html". The default value is `"text/html"`.
  String mimeType;

  ///The encoding of the data. The default value is `"utf8"`.
  String encoding;

  ///The URL to use as the page's base URL. The default value is `about:blank`.
  String baseUrl;

  ///The URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL. This parameter is used only on Android.
  String historyUrl;

  InAppWebViewInitialData(
      {@required this.data,
      this.mimeType = "text/html",
      this.encoding = "utf8",
      this.baseUrl = "about:blank",
      this.historyUrl = "about:blank"});

  Map<String, String> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl,
      "historyUrl": historyUrl
    };
  }

  Map<String, String> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class representing a resource request of the WebView used by the event [WebView.androidShouldInterceptRequest].
///Available only on Android.
///
///**Official Android API**: https://developer.android.com/reference/android/webkit/WebResourceRequest
class WebResourceRequest {
  ///The URL for which the resource request was made.
  String url;

  ///The headers associated with the request.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it will be always `null`.
  Map<String, String> headers;

  ///The method associated with the request, for example `GET`.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it will be always "GET".
  String method;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it will be always `false`.
  bool hasGesture;

  ///Whether the request was made in order to fetch the main frame's document.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it will be always `true`.
  bool isForMainFrame;

  ///Whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it will be always `false`.
  bool isRedirect;

  WebResourceRequest(
      {@required this.url,
      this.headers,
      this.method,
      this.hasGesture,
      this.isForMainFrame,
      this.isRedirect});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "headers": headers,
      "method": method,
      "hasGesture": hasGesture,
      "isForMainFrame": isForMainFrame,
      "isRedirect": isRedirect
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class representing a resource response of the WebView used by the event [WebView.androidShouldInterceptRequest].
///Available only on Android.
///
///**Official Android API**: https://developer.android.com/reference/android/webkit/WebResourceResponse
class WebResourceResponse {
  ///The resource response's MIME type, for example `text/html`.
  String contentType;

  ///The resource response's encoding. The default value is `utf-8`.
  String contentEncoding;

  ///The data provided by the resource response.
  Uint8List data;

  ///The headers for the resource response. If [headers] isn't `null`, then you need to set also [statusCode] and [reasonPhrase].
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it won't be used.
  Map<String, String> headers;

  ///The status code needs to be in the ranges [100, 299], [400, 599]. Causing a redirect by specifying a 3xx code is not supported.
  ///If statusCode is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it won't be used.
  int statusCode;

  ///The phrase describing the status code, for example `"OK"`. Must be non-empty.
  ///If reasonPhrase is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: Available on Android 21+. For Android < 21 it won't be used.
  String reasonPhrase;

  WebResourceResponse(
      {this.contentType = "",
      this.contentEncoding = "utf-8",
      this.data,
      this.headers,
      this.statusCode,
      this.reasonPhrase});

  Map<String, dynamic> toMap() {
    return {
      "contentType": contentType,
      "contentEncoding": contentEncoding,
      "data": data,
      "statusCode": statusCode,
      "reasonPhrase": reasonPhrase
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class representing the response returned by the [WebView.onLoadResourceCustomScheme] event.
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  ///Data enconded to 'base64'.
  Uint8List data;

  ///Content-Type of the data, such as `image/png`.
  String contentType;

  ///Content-Enconding of the data, such as `utf-8`.
  String contentEnconding;

  CustomSchemeResponse(
      {@required this.data,
      @required this.contentType,
      this.contentEnconding = 'utf-8'});

  Map<String, dynamic> toMap() {
    return {
      'content-type': contentType,
      'content-encoding': contentEnconding,
      'data': data
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class representing a JavaScript console message from WebCore.
///This could be a issued by a call to one of the console logging functions (e.g. console.log('...')) or a JavaScript error on the page.
///
///To receive notifications of these messages, use the [WebView.onConsoleMessage] event.
class ConsoleMessage {
  String message;
  ConsoleMessageLevel messageLevel;

  ConsoleMessage(
      {this.message = "", this.messageLevel = ConsoleMessageLevel.LOG});

  Map<String, dynamic> toMap() {
    return {"message": message, "messageLevel": messageLevel?.toValue()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///This class contains a snapshot of the current back/forward list for a [WebView].
class WebHistory {
  ///List of all [WebHistoryItem]s.
  List<WebHistoryItem> list;

  ///Index of the current [WebHistoryItem].
  int currentIndex;

  WebHistory({this.list, this.currentIndex});

  Map<String, dynamic> toMap() {
    return {"list": list, "currentIndex": currentIndex};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///A convenience class for accessing fields in an entry in the back/forward list of a WebView. Each [WebHistoryItem] is a snapshot of the requested history item.
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

  WebHistoryItem(
      {this.originalUrl, this.title, this.url, this.index, this.offset});

  Map<String, dynamic> toMap() {
    return {
      "originalUrl": originalUrl,
      "title": title,
      "url": url,
      "index": index,
      "offset": offset
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by the host application to set the Geolocation permission state for an origin during the [WebView.androidOnGeolocationPermissionsShowPrompt] event.
class GeolocationPermissionShowPromptResponse {
  ///The origin for which permissions are set.
  String origin;

  ///Whether or not the origin should be allowed to use the Geolocation API.
  bool allow;

  ///Whether the permission should be retained beyond the lifetime of a page currently being displayed by a WebView
  bool retain;

  GeolocationPermissionShowPromptResponse(
      {this.origin, this.allow, this.retain});

  Map<String, dynamic> toMap() {
    return {"origin": origin, "allow": allow, "retain": retain};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the request of the [WebView.onJsAlert] event.
class JsAlertRequest {
  ///The url of the page requesting the dialog.
  String url;

  ///Message to be displayed in the window.
  String message;

  ///Indicates whether the request was made for the main frame. Available only on iOS.
  bool iosIsMainFrame;

  JsAlertRequest({this.url, this.message, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {"url": url, "message": message, "iosIsMainFrame": iosIsMainFrame};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [JsAlertResponse] class.
class JsAlertResponseAction {
  final int _value;

  const JsAlertResponseAction._internal(this._value);

  int toValue() => _value;

  static const CONFIRM = const JsAlertResponseAction._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.onJsAlert] event to control a JavaScript alert dialog.
class JsAlertResponse {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm button.
  JsAlertResponseAction action;

  JsAlertResponse(
      {this.message = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.action = JsAlertResponseAction.CONFIRM});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the request of the [WebView.onJsConfirm] event.
class JsConfirmRequest {
  ///The url of the page requesting the dialog.
  String url;

  ///Message to be displayed in the window.
  String message;

  ///Indicates whether the request was made for the main frame. Available only on iOS.
  bool iosIsMainFrame;

  JsConfirmRequest({this.url, this.message, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {"url": url, "message": message, "iosIsMainFrame": iosIsMainFrame};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [JsConfirmResponse] class.
class JsConfirmResponseAction {
  final int _value;

  const JsConfirmResponseAction._internal(this._value);

  int toValue() => _value;

  static const CONFIRM = const JsConfirmResponseAction._internal(0);
  static const CANCEL = const JsConfirmResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.onJsConfirm] event to control a JavaScript confirm dialog.
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

  JsConfirmResponse(
      {this.message = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.action = JsConfirmResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the request of the [WebView.onJsPrompt] event.
class JsPromptRequest {
  ///The url of the page requesting the dialog.
  String url;

  ///Message to be displayed in the window.
  String message;

  ///The default value displayed in the prompt dialog.
  String defaultValue;

  ///Indicates whether the request was made for the main frame. Available only on iOS.
  bool iosIsMainFrame;

  JsPromptRequest(
      {this.url, this.message, this.defaultValue, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "message": message,
      "defaultValue": defaultValue,
      "iosIsMainFrame": iosIsMainFrame
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [JsPromptResponse] class.
class JsPromptResponseAction {
  final int _value;

  const JsPromptResponseAction._internal(this._value);

  int toValue() => _value;

  static const CONFIRM = const JsPromptResponseAction._internal(0);
  static const CANCEL = const JsPromptResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.onJsPrompt] event to control a JavaScript prompt dialog.
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

  JsPromptResponse(
      {this.message = "",
      this.defaultValue = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.value,
      this.action = JsPromptResponseAction.CANCEL});

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

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the request of the [WebView.androidOnJsBeforeUnload] event.
class JsBeforeUnloadRequest {
  ///The url of the page requesting the dialog.
  String url;

  ///Message to be displayed in the window.
  String message;

  ///Indicates whether the request was made for the main frame. Available only on iOS.
  bool iosIsMainFrame;

  JsBeforeUnloadRequest({this.url, this.message, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {"url": url, "message": message, "iosIsMainFrame": iosIsMainFrame};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [JsBeforeUnloadResponse] class.
class JsBeforeUnloadResponseAction {
  final int _value;

  const JsBeforeUnloadResponseAction._internal(this._value);

  int toValue() => _value;

  static const CONFIRM = const JsBeforeUnloadResponseAction._internal(0);
  static const CANCEL = const JsBeforeUnloadResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.androidOnJsBeforeUnload] event to control a JavaScript alert dialog.
class JsBeforeUnloadResponse {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm button.
  JsBeforeUnloadResponseAction action;

  JsBeforeUnloadResponse(
      {this.message = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.action = JsBeforeUnloadResponseAction.CONFIRM});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "confirmButtonTitle": confirmButtonTitle,
      "cancelButtonTitle": cancelButtonTitle,
      "handledByClient": handledByClient,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the reason the resource was caught by Safe Browsing.
class SafeBrowsingThreat {
  final int _value;

  const SafeBrowsingThreat._internal(this._value);

  static final Set<SafeBrowsingThreat> values = [
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_UNKNOWN,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_MALWARE,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_PHISHING,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_BILLING,
  ].toSet();

  static SafeBrowsingThreat fromValue(int value) {
    if (value != null)
      return SafeBrowsingThreat.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  String toString() {
    switch (_value) {
      case 1:
        return "SAFE_BROWSING_THREAT_MALWARE";
      case 2:
        return "SAFE_BROWSING_THREAT_PHISHING";
      case 3:
        return "SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE";
      case 4:
        return "SAFE_BROWSING_THREAT_BILLING";
      case 0:
      default:
        return "SAFE_BROWSING_THREAT_UNKNOWN";
    }
  }

  static const SAFE_BROWSING_THREAT_UNKNOWN =
      const SafeBrowsingThreat._internal(0);
  static const SAFE_BROWSING_THREAT_MALWARE =
      const SafeBrowsingThreat._internal(1);
  static const SAFE_BROWSING_THREAT_PHISHING =
      const SafeBrowsingThreat._internal(2);
  static const SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE =
      const SafeBrowsingThreat._internal(3);
  static const SAFE_BROWSING_THREAT_BILLING =
      const SafeBrowsingThreat._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class used by [SafeBrowsingResponse] class.
class SafeBrowsingResponseAction {
  final int _value;

  const SafeBrowsingResponseAction._internal(this._value);

  int toValue() => _value;

  ///Act as if the user clicked the "back to safety" button.
  static const BACK_TO_SAFETY = const SafeBrowsingResponseAction._internal(0);

  ///Act as if the user clicked the "visit this unsafe site" button.
  static const PROCEED = const SafeBrowsingResponseAction._internal(1);

  ///Display the default interstitial.
  static const SHOW_INTERSTITIAL =
      const SafeBrowsingResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.androidOnSafeBrowsingHit] event.
///It is used to indicate an action to take when hitting a malicious URL.
class SafeBrowsingResponse {
  ///If reporting is enabled, all reports will be sent according to the privacy policy referenced by [AndroidInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  bool report;

  ///Indicate the [SafeBrowsingResponseAction] to take when hitting a malicious URL.
  SafeBrowsingResponseAction action;

  SafeBrowsingResponse(
      {this.report = true,
      this.action = SafeBrowsingResponseAction.SHOW_INTERSTITIAL});

  Map<String, dynamic> toMap() {
    return {"report": report, "action": action?.toValue()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [HttpAuthResponse] class.
class HttpAuthResponseAction {
  final int _value;

  const HttpAuthResponseAction._internal(this._value);

  int toValue() => _value;

  ///Instructs the WebView to cancel the authentication request.
  static const CANCEL = const HttpAuthResponseAction._internal(0);

  ///Instructs the WebView to proceed with the authentication with the given credentials.
  static const PROCEED = const HttpAuthResponseAction._internal(1);

  ///Uses the credentials stored for the current host.
  static const USE_SAVED_HTTP_AUTH_CREDENTIALS =
      const HttpAuthResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.onReceivedHttpAuthRequest] event.
class HttpAuthResponse {
  ///Represents the username used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String username;

  ///Represents the password used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String password;

  ///Indicate if the given credentials need to be saved permanently.
  bool permanentPersistence;

  ///Indicate the [HttpAuthResponseAction] to take in response of the authentication challenge.
  HttpAuthResponseAction action;

  HttpAuthResponse(
      {this.username = "",
      this.password = "",
      this.permanentPersistence = false,
      this.action = HttpAuthResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "permanentPersistence": permanentPersistence,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the challenge of the [WebView.onReceivedHttpAuthRequest] event.
///It provides all the information about the challenge.
class HttpAuthChallenge {
  ///A count of previous failed authentication attempts.
  int previousFailureCount;

  ///The protection space requiring authentication.
  ProtectionSpace protectionSpace;

  HttpAuthChallenge(
      {@required this.previousFailureCount, @required this.protectionSpace})
      : assert(previousFailureCount != null && protectionSpace != null);

  Map<String, dynamic> toMap() {
    return {
      "previousFailureCount": previousFailureCount,
      "protectionSpace": protectionSpace?.toMap()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a protection space requiring authentication.
class ProtectionSpace {
  ///The hostname of the server.
  String host;

  ///The protocol of the server - e.g. "http", "ftp", "https".
  String protocol;

  ///A string indicating a protocol-specific subdivision of a single host.
  ///For http and https, this maps to the realm string in http authentication challenges.
  ///For many other protocols it is unused.
  String realm;

  ///The port of the server.
  int port;

  ProtectionSpace(
      {@required this.host, @required this.protocol, this.realm, this.port})
      : assert(host != null && protocol != null);

  Map<String, dynamic> toMap() {
    return {"host": host, "protocol": protocol, "realm": realm, "port": port};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the credentials of an http authentication.
///It is used by the [HttpAuthCredentialDatabase] class.
class HttpAuthCredential {
  ///Represents the username.
  String username;

  ///Represents the password.
  String password;

  HttpAuthCredential({@required this.username, @required this.password})
      : assert(username != null && password != null);

  Map<String, dynamic> toMap() {
    return {"username": username, "password": password};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a [ProtectionSpace] with all of its [HttpAuthCredential]s.
///It used by [HttpAuthCredentialDatabase.getAllAuthCredentials].
class ProtectionSpaceHttpAuthCredentials {
  ///The protection space.
  ProtectionSpace protectionSpace;

  ///The list of all its http authentication credentials.
  List<HttpAuthCredential> credentials;

  ProtectionSpaceHttpAuthCredentials({this.protectionSpace, this.credentials});

  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace?.toMap(),
      "credentials":
          credentials?.map((credential) => credential?.toMap())?.toList()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [ServerTrustAuthResponse] class.
class ServerTrustAuthResponseAction {
  final int _value;

  const ServerTrustAuthResponseAction._internal(this._value);

  int toValue() => _value;

  ///Instructs the WebView to cancel the authentication challenge.
  static const CANCEL = const ServerTrustAuthResponseAction._internal(0);

  ///Instructs the WebView to proceed with the authentication challenge.
  static const PROCEED = const ServerTrustAuthResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///ServerTrustAuthResponse class represents the response used by the [WebView.onReceivedServerTrustAuthRequest] event.
class ServerTrustAuthResponse {
  ///Indicate the [ServerTrustAuthResponseAction] to take in response of the server trust authentication challenge.
  ServerTrustAuthResponseAction action;

  ServerTrustAuthResponse({this.action = ServerTrustAuthResponseAction.CANCEL});

  Map<String, dynamic> toMap() {
    return {"action": action?.toValue()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the challenge of the [WebView.onReceivedServerTrustAuthRequest] event.
///It provides all the information about the challenge.
class ServerTrustChallenge {
  ///The protection space requiring authentication.
  ProtectionSpace protectionSpace;

  ///Android-specific primary error associated to the server SSL certificate.
  AndroidSslError androidError;

  ///iOS-specific primary error associated to the server SSL certificate.
  IOSSslError iosError;

  ///The message associated to the [androidError]/[iosError].
  String message;

  ///The SSL certificate used for this challenge.
  SslCertificate sslCertificate;

  ServerTrustChallenge(
      {@required this.protectionSpace,
      this.androidError,
      this.iosError,
      this.message,
      this.sslCertificate})
      : assert(protectionSpace != null);

  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace?.toMap(),
      "androidError": androidError?.toValue(),
      "iosError": iosError?.toValue(),
      "message": message,
      "sslCertificate": sslCertificate?.toMap()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [ClientCertResponse] class.
class ClientCertResponseAction {
  final int _value;

  const ClientCertResponseAction._internal(this._value);

  int toValue() => _value;

  ///Cancel this request.
  static const CANCEL = const ClientCertResponseAction._internal(0);

  ///Proceed with the specified certificate.
  static const PROCEED = const ClientCertResponseAction._internal(1);

  ///Ignore the request for now.
  static const IGNORE = const ClientCertResponseAction._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.onReceivedClientCertRequest] event.
class ClientCertResponse {
  ///The file path of the certificate to use.
  String certificatePath;

  ///The certificate password.
  String certificatePassword;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  String androidKeyStoreType;

  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction action;

  ClientCertResponse(
      {this.certificatePath,
      this.certificatePassword = "",
      this.androidKeyStoreType = "PKCS12",
      this.action = ClientCertResponseAction.CANCEL}) {
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

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the challenge of the [WebView.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge {
  ///The protection space requiring authentication.
  ProtectionSpace protectionSpace;

  ClientCertChallenge({@required this.protectionSpace})
      : assert(protectionSpace != null);

  Map<String, dynamic> toMap() {
    return {"protectionSpace": protectionSpace?.toMap()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a favicon of a website. It is used by [InAppWebViewController.getFavicons] method.
class Favicon {
  ///The url of the favicon image.
  String url;

  ///The relationship between the current web page and the favicon image.
  String rel;

  ///The width of the favicon image.
  int width;

  ///The height of the favicon image.
  int height;

  Favicon({@required this.url, this.rel, this.width, this.height})
      : assert(url != null);

  Map<String, dynamic> toMap() {
    return {"url": url, "rel": rel, "width": width, "height": height};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents an Android-specific class used to override the way the cache is used.
class AndroidCacheMode {
  final int _value;

  const AndroidCacheMode._internal(this._value);

  static final Set<AndroidCacheMode> values = [
    AndroidCacheMode.LOAD_DEFAULT,
    AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
    AndroidCacheMode.LOAD_NO_CACHE,
    AndroidCacheMode.LOAD_CACHE_ONLY,
  ].toSet();

  static AndroidCacheMode fromValue(int value) {
    if (value != null)
      return AndroidCacheMode.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "LOAD_CACHE_ELSE_NETWORK";
      case 2:
        return "LOAD_NO_CACHE";
      case 3:
        return "LOAD_CACHE_ONLY";
      case -1:
      default:
        return "LOAD_DEFAULT";
    }
  }

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = const AndroidCacheMode._internal(-1);

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = const AndroidCacheMode._internal(1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = const AndroidCacheMode._internal(2);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = const AndroidCacheMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to disable the action mode menu items.
///
///**NOTE**: available on Android 24+.
class AndroidActionModeMenuItem {
  final int _value;

  const AndroidActionModeMenuItem._internal(this._value);

  static final Set<AndroidActionModeMenuItem> values = [
    AndroidActionModeMenuItem.MENU_ITEM_NONE,
    AndroidActionModeMenuItem.MENU_ITEM_SHARE,
    AndroidActionModeMenuItem.MENU_ITEM_WEB_SEARCH,
    AndroidActionModeMenuItem.MENU_ITEM_PROCESS_TEXT,
  ].toSet();

  static AndroidActionModeMenuItem fromValue(int value) {
    if (value != null)
      return AndroidActionModeMenuItem.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "MENU_ITEM_SHARE";
      case 2:
        return "MENU_ITEM_WEB_SEARCH";
      case 4:
        return "MENU_ITEM_PROCESS_TEXT";
      case 0:
      default:
        return "MENU_ITEM_NONE";
    }
  }

  ///No menu items should be disabled.
  static const MENU_ITEM_NONE = const AndroidActionModeMenuItem._internal(0);

  ///Disable menu item "Share".
  static const MENU_ITEM_SHARE = const AndroidActionModeMenuItem._internal(1);

  ///Disable menu item "Web Search".
  static const MENU_ITEM_WEB_SEARCH =
      const AndroidActionModeMenuItem._internal(2);

  ///Disable all the action mode menu items for text processing.
  static const MENU_ITEM_PROCESS_TEXT =
      const AndroidActionModeMenuItem._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to indicate the force dark mode.
///
///**NOTE**: available on Android 29+.
class AndroidForceDark {
  final int _value;

  const AndroidForceDark._internal(this._value);

  static final Set<AndroidForceDark> values = [
    AndroidForceDark.FORCE_DARK_OFF,
    AndroidForceDark.FORCE_DARK_AUTO,
    AndroidForceDark.FORCE_DARK_ON,
  ].toSet();

  static AndroidForceDark fromValue(int value) {
    if (value != null)
      return AndroidForceDark.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "FORCE_DARK_AUTO";
      case 2:
        return "FORCE_DARK_ON";
      case 0:
      default:
        return "FORCE_DARK_OFF";
    }
  }

  ///Disable force dark, irrespective of the force dark mode of the WebView parent.
  ///In this mode, WebView content will always be rendered as-is, regardless of whether native views are being automatically darkened.
  static const FORCE_DARK_OFF = const AndroidForceDark._internal(0);

  ///Enable force dark dependent on the state of the WebView parent view.
  static const FORCE_DARK_AUTO = const AndroidForceDark._internal(1);

  ///Unconditionally enable force dark. In this mode WebView content will always be rendered so as to emulate a dark theme.
  static const FORCE_DARK_ON = const AndroidForceDark._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to set the underlying layout algorithm.
class AndroidLayoutAlgorithm {
  final String _value;

  const AndroidLayoutAlgorithm._internal(this._value);

  static final Set<AndroidLayoutAlgorithm> values = [
    AndroidLayoutAlgorithm.NORMAL,
    AndroidLayoutAlgorithm.TEXT_AUTOSIZING,
    AndroidLayoutAlgorithm.NARROW_COLUMNS,
  ].toSet();

  static AndroidLayoutAlgorithm fromValue(String value) {
    if (value != null)
      return AndroidLayoutAlgorithm.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///NORMAL means no rendering changes. This is the recommended choice for maximum compatibility across different platforms and Android versions.
  static const NORMAL = const AndroidLayoutAlgorithm._internal("NORMAL");

  ///TEXT_AUTOSIZING boosts font size of paragraphs based on heuristics to make the text readable when viewing a wide-viewport layout in the overview mode.
  ///It is recommended to enable zoom support [AndroidInAppWebViewOptions.supportZoom] when using this mode.
  ///
  ///**NOTE**: available on Android 19+.
  static const TEXT_AUTOSIZING =
      const AndroidLayoutAlgorithm._internal("TEXT_AUTOSIZING");

  ///NARROW_COLUMNS makes all columns no wider than the screen if possible. Only use this for API levels prior to `Build.VERSION_CODES.KITKAT`.
  static const NARROW_COLUMNS =
      const AndroidLayoutAlgorithm._internal("NARROW_COLUMNS");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to configure the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
///
///**NOTE**: available on Android 21+.
class AndroidMixedContentMode {
  final int _value;

  const AndroidMixedContentMode._internal(this._value);

  static final Set<AndroidMixedContentMode> values = [
    AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    AndroidMixedContentMode.MIXED_CONTENT_NEVER_ALLOW,
    AndroidMixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
  ].toSet();

  static AndroidMixedContentMode fromValue(int value) {
    if (value != null)
      return AndroidMixedContentMode.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "MIXED_CONTENT_NEVER_ALLOW";
      case 2:
        return "MIXED_CONTENT_COMPATIBILITY_MODE";
      case 0:
      default:
        return "MIXED_CONTENT_ALWAYS_ALLOW";
    }
  }

  ///In this mode, the WebView will allow a secure origin to load content from any other origin, even if that origin is insecure.
  ///This is the least secure mode of operation for the WebView, and where possible apps should not set this mode.
  static const MIXED_CONTENT_ALWAYS_ALLOW =
      const AndroidMixedContentMode._internal(0);

  ///In this mode, the WebView will not allow a secure origin to load content from an insecure origin.
  ///This is the preferred and most secure mode of operation for the WebView and apps are strongly advised to use this mode.
  static const MIXED_CONTENT_NEVER_ALLOW =
      const AndroidMixedContentMode._internal(1);

  ///In this mode, the WebView will attempt to be compatible with the approach of a modern web browser with regard to mixed content.
  ///Some insecure content may be allowed to be loaded by a secure origin and other types of content will be blocked.
  ///The types of content are allowed or blocked may change release to release and are not explicitly defined.
  ///This mode is intended to be used by apps that are not in control of the content that they render but desire to operate in a reasonably secure environment.
  ///For highest security, apps are recommended to use [AndroidMixedContentMode.MIXED_CONTENT_NEVER_ALLOW].
  static const MIXED_CONTENT_COMPATIBILITY_MODE =
      const AndroidMixedContentMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to set the level of granularity with which the user can interactively select content in the web view.
class IOSWKSelectionGranularity {
  final int _value;

  const IOSWKSelectionGranularity._internal(this._value);

  static final Set<IOSWKSelectionGranularity> values = [
    IOSWKSelectionGranularity.DYNAMIC,
    IOSWKSelectionGranularity.CHARACTER,
  ].toSet();

  static IOSWKSelectionGranularity fromValue(int value) {
    if (value != null)
      return IOSWKSelectionGranularity.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "CHARACTER";
      case 0:
      default:
        return "DYNAMIC";
    }
  }

  ///Selection granularity varies automatically based on the selection.
  static const DYNAMIC = const IOSWKSelectionGranularity._internal(0);

  ///Selection endpoints can be placed at any character boundary.
  static const CHARACTER = const IOSWKSelectionGranularity._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
///
///**NOTE**: available on iOS 10.0+.
class IOSWKDataDetectorTypes {
  final String _value;

  const IOSWKDataDetectorTypes._internal(this._value);

  static final Set<IOSWKDataDetectorTypes> values = [
    IOSWKDataDetectorTypes.NONE,
    IOSWKDataDetectorTypes.PHONE_NUMBER,
    IOSWKDataDetectorTypes.LINK,
    IOSWKDataDetectorTypes.ADDRESS,
    IOSWKDataDetectorTypes.CALENDAR_EVENT,
    IOSWKDataDetectorTypes.TRACKING_NUMBER,
    IOSWKDataDetectorTypes.FLIGHT_NUMBER,
    IOSWKDataDetectorTypes.LOOKUP_SUGGESTION,
    IOSWKDataDetectorTypes.SPOTLIGHT_SUGGESTION,
    IOSWKDataDetectorTypes.ALL,
  ].toSet();

  static IOSWKDataDetectorTypes fromValue(String value) {
    if (value != null)
      return IOSWKDataDetectorTypes.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///No detection is performed.
  static const NONE = const IOSWKDataDetectorTypes._internal("NONE");

  ///Phone numbers are detected and turned into links.
  static const PHONE_NUMBER =
      const IOSWKDataDetectorTypes._internal("PHONE_NUMBER");

  ///URLs in text are detected and turned into links.
  static const LINK = const IOSWKDataDetectorTypes._internal("LINK");

  ///Addresses are detected and turned into links.
  static const ADDRESS = const IOSWKDataDetectorTypes._internal("ADDRESS");

  ///Dates and times that are in the future are detected and turned into links.
  static const CALENDAR_EVENT =
      const IOSWKDataDetectorTypes._internal("CALENDAR_EVENT");

  ///Tracking numbers are detected and turned into links.
  static const TRACKING_NUMBER =
      const IOSWKDataDetectorTypes._internal("TRACKING_NUMBER");

  ///Flight numbers are detected and turned into links.
  static const FLIGHT_NUMBER =
      const IOSWKDataDetectorTypes._internal("FLIGHT_NUMBER");

  ///Lookup suggestions are detected and turned into links.
  static const LOOKUP_SUGGESTION =
      const IOSWKDataDetectorTypes._internal("LOOKUP_SUGGESTION");

  ///Spotlight suggestions are detected and turned into links.
  static const SPOTLIGHT_SUGGESTION =
      const IOSWKDataDetectorTypes._internal("SPOTLIGHT_SUGGESTION");

  ///All of the above data types are turned into links when detected. Choosing this value will automatically include any new detection type that is added.
  static const ALL = const IOSWKDataDetectorTypes._internal("ALL");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a floating-point value that determines the rate of deceleration after the user lifts their finger.
class IOSUIScrollViewDecelerationRate {
  final String _value;

  const IOSUIScrollViewDecelerationRate._internal(this._value);

  static final Set<IOSUIScrollViewDecelerationRate> values = [
    IOSUIScrollViewDecelerationRate.NORMAL,
    IOSUIScrollViewDecelerationRate.FAST,
  ].toSet();

  static IOSUIScrollViewDecelerationRate fromValue(String value) {
    if (value != null)
      return IOSUIScrollViewDecelerationRate.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///The default deceleration rate for a scroll view: `0.998`.
  static const NORMAL =
      const IOSUIScrollViewDecelerationRate._internal("NORMAL");

  ///A fast deceleration rate for a scroll view: `0.99`.
  static const FAST = const IOSUIScrollViewDecelerationRate._internal("FAST");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the content mode to prefer when loading and rendering a webpage.
class UserPreferredContentMode {
  final int _value;

  const UserPreferredContentMode._internal(this._value);

  static final Set<UserPreferredContentMode> values = [
    UserPreferredContentMode.RECOMMENDED,
    UserPreferredContentMode.MOBILE,
    UserPreferredContentMode.DESKTOP,
  ].toSet();

  static UserPreferredContentMode fromValue(int value) {
    if (value != null)
      return UserPreferredContentMode.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "MOBILE";
      case 2:
        return "DESKTOP";
      case 0:
      default:
        return "RECOMMENDED";
    }
  }

  ///The recommended content mode for the current platform.
  static const RECOMMENDED = const UserPreferredContentMode._internal(0);

  ///Represents content targeting mobile browsers.
  static const MOBILE = const UserPreferredContentMode._internal(1);

  ///Represents content targeting desktop browsers.
  static const DESKTOP = const UserPreferredContentMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to specify the modal presentation style when presenting a view controller.
class IOSUIModalPresentationStyle {
  final int _value;

  const IOSUIModalPresentationStyle._internal(this._value);

  static final Set<IOSUIModalPresentationStyle> values = [
    IOSUIModalPresentationStyle.FULL_SCREEN,
    IOSUIModalPresentationStyle.PAGE_SHEET,
    IOSUIModalPresentationStyle.FORM_SHEET,
    IOSUIModalPresentationStyle.CURRENT_CONTEXT,
    IOSUIModalPresentationStyle.CUSTOM,
    IOSUIModalPresentationStyle.OVER_FULL_SCREEN,
    IOSUIModalPresentationStyle.OVER_CURRENT_CONTEXT,
    IOSUIModalPresentationStyle.POPOVER,
    IOSUIModalPresentationStyle.NONE,
    IOSUIModalPresentationStyle.AUTOMATIC,
  ].toSet();

  static IOSUIModalPresentationStyle fromValue(int value) {
    if (value != null)
      return IOSUIModalPresentationStyle.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "PAGE_SHEET";
      case 2:
        return "FORM_SHEET";
      case 3:
        return "CURRENT_CONTEXT";
      case 4:
        return "CUSTOM";
      case 5:
        return "OVER_FULL_SCREEN";
      case 6:
        return "OVER_CURRENT_CONTEXT";
      case 7:
        return "POPOVER";
      case 8:
        return "NONE";
      case 9:
        return "AUTOMATIC";
      case 0:
      default:
        return "FULL_SCREEN";
    }
  }

  ///A presentation style in which the presented view covers the screen.
  static const FULL_SCREEN = const IOSUIModalPresentationStyle._internal(0);

  ///A presentation style that partially covers the underlying content.
  static const PAGE_SHEET = const IOSUIModalPresentationStyle._internal(1);

  ///A presentation style that displays the content centered in the screen.
  static const FORM_SHEET = const IOSUIModalPresentationStyle._internal(2);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const CURRENT_CONTEXT = const IOSUIModalPresentationStyle._internal(3);

  ///A custom view presentation style that is managed by a custom presentation controller and one or more custom animator objects.
  static const CUSTOM = const IOSUIModalPresentationStyle._internal(4);

  ///A view presentation style in which the presented view covers the screen.
  static const OVER_FULL_SCREEN =
      const IOSUIModalPresentationStyle._internal(5);

  ///A presentation style where the content is displayed over another view controller’s content.
  static const OVER_CURRENT_CONTEXT =
      const IOSUIModalPresentationStyle._internal(6);

  ///A presentation style where the content is displayed in a popover view.
  static const POPOVER = const IOSUIModalPresentationStyle._internal(7);

  ///A presentation style that indicates no adaptations should be made.
  static const NONE = const IOSUIModalPresentationStyle._internal(8);

  ///The default presentation style chosen by the system.
  ///
  ///**NOTE**: available on iOS 13.0+.
  static const AUTOMATIC = const IOSUIModalPresentationStyle._internal(9);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to specify the transition style when presenting a view controller.
class IOSUIModalTransitionStyle {
  final int _value;

  const IOSUIModalTransitionStyle._internal(this._value);

  static final Set<IOSUIModalTransitionStyle> values = [
    IOSUIModalTransitionStyle.COVER_VERTICAL,
    IOSUIModalTransitionStyle.FLIP_HORIZONTAL,
    IOSUIModalTransitionStyle.CROSS_DISSOLVE,
    IOSUIModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  static IOSUIModalTransitionStyle fromValue(int value) {
    if (value != null)
      return IOSUIModalTransitionStyle.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "FLIP_HORIZONTAL";
      case 2:
        return "CROSS_DISSOLVE";
      case 3:
        return "PARTIAL_CURL";
      case 0:
      default:
        return "COVER_VERTICAL";
    }
  }

  ///When the view controller is presented, its view slides up from the bottom of the screen.
  ///On dismissal, the view slides back down. This is the default transition style.
  static const COVER_VERTICAL = const IOSUIModalTransitionStyle._internal(0);

  ///When the view controller is presented, the current view initiates a horizontal 3D flip from right-to-left,
  ///resulting in the revealing of the new view as if it were on the back of the previous view.
  ///On dismissal, the flip occurs from left-to-right, returning to the original view.
  static const FLIP_HORIZONTAL = const IOSUIModalTransitionStyle._internal(1);

  ///When the view controller is presented, the current view fades out while the new view fades in at the same time.
  ///On dismissal, a similar type of cross-fade is used to return to the original view.
  static const CROSS_DISSOLVE = const IOSUIModalTransitionStyle._internal(2);

  ///When the view controller is presented, one corner of the current view curls up to reveal the presented view underneath.
  ///On dismissal, the curled up page unfurls itself back on top of the presented view.
  ///A view controller presented using this transition is itself prevented from presenting any additional view controllers.
  static const PARTIAL_CURL = const IOSUIModalTransitionStyle._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to set the custom style for the dismiss button.
///
///**NOTE**: available on iOS 11.0+.
class IOSSafariDismissButtonStyle {
  final int _value;

  const IOSSafariDismissButtonStyle._internal(this._value);

  static final Set<IOSSafariDismissButtonStyle> values = [
    IOSSafariDismissButtonStyle.DONE,
    IOSSafariDismissButtonStyle.CLOSE,
    IOSSafariDismissButtonStyle.CANCEL,
  ].toSet();

  static IOSSafariDismissButtonStyle fromValue(int value) {
    if (value != null)
      return IOSSafariDismissButtonStyle.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "CLOSE";
      case 2:
        return "CANCEL";
      case 0:
      default:
        return "DONE";
    }
  }

  ///Makes the button title the localized string "Done".
  static const DONE = const IOSSafariDismissButtonStyle._internal(0);

  ///Makes the button title the localized string "Close".
  static const CLOSE = const IOSSafariDismissButtonStyle._internal(1);

  ///Makes the button title the localized string "Cancel".
  static const CANCEL = const IOSSafariDismissButtonStyle._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the options that can be used for a [WebView].
class InAppWebViewGroupOptions {
  ///Cross-platform options.
  InAppWebViewOptions crossPlatform;

  ///Android-specific options.
  AndroidInAppWebViewOptions android;

  ///iOS-specific options.
  IOSInAppWebViewOptions ios;

  InAppWebViewGroupOptions({this.crossPlatform, this.android, this.ios}) {
    this.crossPlatform = this.crossPlatform ?? InAppWebViewOptions();
    this.android = this.android ?? AndroidInAppWebViewOptions();
    this.ios = this.ios ?? IOSInAppWebViewOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    options.addAll(this.crossPlatform?.toMap() ?? {});
    if (Platform.isAndroid)
      options.addAll(this.android?.toMap() ?? {});
    else if (Platform.isIOS) options.addAll(this.ios?.toMap() ?? {});

    return options;
  }

  static InAppWebViewGroupOptions fromMap(Map<String, dynamic> options) {
    InAppWebViewGroupOptions inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();

    inAppWebViewGroupOptions.crossPlatform =
        InAppWebViewOptions.fromMap(options);
    if (Platform.isAndroid)
      inAppWebViewGroupOptions.android =
          AndroidInAppWebViewOptions.fromMap(options);
    else if (Platform.isIOS)
      inAppWebViewGroupOptions.ios = IOSInAppWebViewOptions.fromMap(options);

    return inAppWebViewGroupOptions;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  InAppWebViewGroupOptions copy() {
    return InAppWebViewGroupOptions.fromMap(this.toMap());
  }
}

///Class that represents the options that can be used for an [InAppBrowser] WebView.
class InAppBrowserClassOptions {
  ///Cross-platform options.
  InAppBrowserOptions crossPlatform;

  ///Android-specific options.
  AndroidInAppBrowserOptions android;

  ///iOS-specific options.
  IOSInAppBrowserOptions ios;

  ///WebView options.
  InAppWebViewGroupOptions inAppWebViewGroupOptions;

  InAppBrowserClassOptions(
      {this.crossPlatform,
      this.android,
      this.ios,
      this.inAppWebViewGroupOptions}) {
    this.crossPlatform = this.crossPlatform ?? InAppBrowserOptions();
    this.android = this.android ?? AndroidInAppBrowserOptions();
    this.ios = this.ios ?? IOSInAppBrowserOptions();
    this.inAppWebViewGroupOptions =
        this.inAppWebViewGroupOptions ?? InAppWebViewGroupOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};

    options.addAll(this.crossPlatform?.toMap() ?? {});
    options.addAll(this.inAppWebViewGroupOptions?.crossPlatform?.toMap() ?? {});
    if (Platform.isAndroid) {
      options.addAll(this.android?.toMap() ?? {});
      options.addAll(this.inAppWebViewGroupOptions?.android?.toMap() ?? {});
    } else if (Platform.isIOS) {
      options.addAll(this.ios?.toMap() ?? {});
      options.addAll(this.inAppWebViewGroupOptions?.ios?.toMap() ?? {});
    }

    return options;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static InAppBrowserClassOptions fromMap(Map<String, dynamic> options) {
    InAppBrowserClassOptions inAppBrowserClassOptions =
        InAppBrowserClassOptions();

    inAppBrowserClassOptions.crossPlatform =
        InAppBrowserOptions.fromMap(options);
    inAppBrowserClassOptions.inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();
    inAppBrowserClassOptions.inAppWebViewGroupOptions.crossPlatform =
        InAppWebViewOptions.fromMap(options);
    if (Platform.isAndroid) {
      inAppBrowserClassOptions.android =
          AndroidInAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewGroupOptions.android =
          AndroidInAppWebViewOptions.fromMap(options);
    } else if (Platform.isIOS) {
      inAppBrowserClassOptions.ios = IOSInAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewGroupOptions.ios =
          IOSInAppWebViewOptions.fromMap(options);
    }

    return inAppBrowserClassOptions;
  }

  InAppBrowserClassOptions copy() {
    return InAppBrowserClassOptions.fromMap(this.toMap());
  }
}

///Class that represents the options that can be used for an [ChromeSafariBrowser] window.
class ChromeSafariBrowserClassOptions {
  ///Android-specific options.
  AndroidChromeCustomTabsOptions android;

  ///iOS-specific options.
  IOSSafariOptions ios;

  ChromeSafariBrowserClassOptions({this.android, this.ios}) {
    this.android = this.android ?? AndroidChromeCustomTabsOptions();
    this.ios = this.ios ?? IOSSafariOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    if (Platform.isAndroid)
      options.addAll(this.android?.toMap() ?? {});
    else if (Platform.isIOS) options.addAll(this.ios?.toMap() ?? {});

    return options;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [AjaxRequest] class.
class AjaxRequestAction {
  final int _value;

  const AjaxRequestAction._internal(this._value);

  int toValue() => _value;

  ///Aborts the current [AjaxRequest].
  static const ABORT = const AjaxRequestAction._internal(0);

  ///Proceeds with the current [AjaxRequest].
  static const PROCEED = const AjaxRequestAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [AjaxRequestEvent] class.
class AjaxRequestEventType {
  final String _value;

  const AjaxRequestEventType._internal(this._value);

  static final Set<AjaxRequestEventType> values = [
    AjaxRequestEventType.LOADSTART,
    AjaxRequestEventType.LOAD,
    AjaxRequestEventType.LOADEND,
    AjaxRequestEventType.PROGRESS,
    AjaxRequestEventType.ERROR,
    AjaxRequestEventType.ABORT,
    AjaxRequestEventType.TIMEOUT,
  ].toSet();

  static AjaxRequestEventType fromValue(String value) {
    if (value != null)
      return AjaxRequestEventType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  String toString() => _value;

  ///The LOADSTART event is fired when a request has started to load data.
  static const LOADSTART = const AjaxRequestEventType._internal("loadstart");

  ///The LOAD event is fired when an `XMLHttpRequest` transaction completes successfully.
  static const LOAD = const AjaxRequestEventType._internal("load");

  ///The LOADEND event is fired when a request has completed, whether successfully (after [AjaxRequestEventType.LOAD]) or
  ///unsuccessfully (after [AjaxRequestEventType.ABORT] or [AjaxRequestEventType.ERROR]).
  static const LOADEND = const AjaxRequestEventType._internal("loadend");

  ///The PROGRESS event is fired periodically when a request receives more data.
  static const PROGRESS = const AjaxRequestEventType._internal("progress");

  ///The ERROR event is fired when the request encountered an error.
  static const ERROR = const AjaxRequestEventType._internal("error");

  ///The ABORT event is fired when a request has been aborted.
  static const ABORT = const AjaxRequestEventType._internal("abort");

  ///The TIMEOUT event is fired when progression is terminated due to preset time expiring.
  static const TIMEOUT = const AjaxRequestEventType._internal("timeout");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class used by [AjaxRequest] class. It represents events measuring progress of an [AjaxRequest].
class AjaxRequestEvent {
  ///Event type.
  AjaxRequestEventType type;

  ///Is a Boolean flag indicating if the total work to be done, and the amount of work already done, by the underlying process is calculable.
  ///In other words, it tells if the progress is measurable or not.
  bool lengthComputable;

  ///Is an integer representing the amount of work already performed by the underlying process.
  ///The ratio of work done can be calculated with the property and [AjaxRequestEvent.total].
  ///When downloading a resource using HTTP, this only represent the part of the content itself, not headers and other overhead.
  int loaded;

  ///Is an integer representing the total amount of work that the underlying process is in the progress of performing.
  ///When downloading a resource using HTTP, this only represent the content itself, not headers and other overhead.
  int total;

  AjaxRequestEvent({this.type, this.lengthComputable, this.loaded, this.total});
}

///Class used by [AjaxRequest] class. It represents the state of an [AjaxRequest].
class AjaxRequestReadyState {
  final int _value;

  const AjaxRequestReadyState._internal(this._value);

  static final Set<AjaxRequestReadyState> values = [
    AjaxRequestReadyState.UNSENT,
    AjaxRequestReadyState.OPENED,
    AjaxRequestReadyState.HEADERS_RECEIVED,
    AjaxRequestReadyState.LOADING,
    AjaxRequestReadyState.DONE,
  ].toSet();

  static AjaxRequestReadyState fromValue(int value) {
    if (value != null)
      return AjaxRequestReadyState.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "OPENED";
      case 2:
        return "HEADERS_RECEIVED";
      case 3:
        return "LOADING";
      case 4:
        return "DONE";
      case 0:
      default:
        return "UNSENT";
    }
  }

  ///Client has been created. `XMLHttpRequest.open()` not called yet.
  static const UNSENT = const AjaxRequestReadyState._internal(0);

  ///`XMLHttpRequest.open()` has been called.
  static const OPENED = const AjaxRequestReadyState._internal(1);

  ///`XMLHttpRequest.send()` has been called, and [AjaxRequest.headers] and [AjaxRequest.status] are available.
  static const HEADERS_RECEIVED = const AjaxRequestReadyState._internal(2);

  ///Downloading; [AjaxRequest.responseText] holds partial data.
  static const LOADING = const AjaxRequestReadyState._internal(3);

  ///The operation is complete.
  static const DONE = const AjaxRequestReadyState._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the HTTP headers of an [AjaxRequest].
class AjaxRequestHeaders {
  Map<dynamic, dynamic> _headers;
  Map<String, dynamic> _newHeaders = {};

  AjaxRequestHeaders(this._headers);

  ///Gets the HTTP headers of the [AjaxRequest].
  Map<dynamic, dynamic> getHeaders() {
    return this._headers;
  }

  ///Sets/updates an HTTP header of the [AjaxRequest]. If there is already an existing [header] with the same name, the values are merged into one single request header.
  ///For security reasons, some headers can only be controlled by the user agent.
  ///These headers include the [forbidden header names](https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_header_name)
  ///and [forbidden response header names](https://developer.mozilla.org/en-US/docs/Glossary/Forbidden_response_header_name).
  void setRequestHeader(String header, String value) {
    _newHeaders[header] = value;
  }

  Map<String, dynamic> toMap() {
    return _newHeaders;
  }
}

///Class that represents a JavaScript [XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) object.
class AjaxRequest {
  ///Data passed as a parameter to the `XMLHttpRequest.send()` method.
  dynamic data;

  ///The HTTP request method of the `XMLHttpRequest` request.
  String method;

  ///The URL of the `XMLHttpRequest` request.
  String url;

  ///An optional Boolean parameter, defaulting to true, indicating whether or not the request is performed asynchronously.
  bool isAsync;

  ///The optional user name to use for authentication purposes; by default, this is the null value.
  String user;

  ///The optional password to use for authentication purposes; by default, this is the null value.
  String password;

  ///The XMLHttpRequest.withCredentials property is a Boolean that indicates whether or not cross-site Access-Control requests
  ///should be made using credentials such as cookies, authorization headers or TLS client certificates.
  ///Setting withCredentials has no effect on same-site requests.
  ///In addition, this flag is also used to indicate when cookies are to be ignored in the response. The default is false.
  bool withCredentials;

  ///The HTTP request headers.
  AjaxRequestHeaders headers;

  ///The state of the `XMLHttpRequest` request.
  AjaxRequestReadyState readyState;

  ///The numerical HTTP [status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) of the `XMLHttpRequest`'s response.
  int status;

  ///The serialized URL of the response or the empty string if the URL is null.
  ///If the URL is returned, any URL fragment present in the URL will be stripped away.
  ///The value of responseURL will be the final URL obtained after any redirects.
  String responseURL;

  ///It is an enumerated string value specifying the type of data contained in the response.
  ///It also lets the author change the [response type](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/responseType).
  ///If an empty string is set as the value of responseType, the default value of text is used.
  String responseType;

  ///The response's body content. The content-type depends on the [AjaxRequest.reponseType].
  dynamic response;

  ///The text received from a server following a request being sent.
  String responseText;

  ///The HTML or XML string retrieved by the request or null if the request was unsuccessful, has not yet been sent, or if the data can't be parsed as XML or HTML.
  String responseXML;

  ///A String containing the response's status message as returned by the HTTP server.
  ///Unlike [AjaxRequest.status] which indicates a numerical status code, this property contains the text of the response status, such as "OK" or "Not Found".
  ///If the request's readyState is in [AjaxRequestReadyState.UNSENT] or [AjaxRequestReadyState.OPENED] state, the value of statusText will be an empty string.
  ///If the server response doesn't explicitly specify a status text, statusText will assume the default value "OK".
  String statusText;

  ///All the response headers or returns null if no response has been received. If a network error happened, an empty string is returned.
  Map<dynamic, dynamic> responseHeaders;

  ///Event type of the `XMLHttpRequest` request.
  AjaxRequestEvent event;

  ///Indicates the [AjaxRequestAction] that can be used to control the `XMLHttpRequest` request.
  AjaxRequestAction action;

  AjaxRequest(
      {this.data,
      this.method,
      this.url,
      this.isAsync,
      this.user,
      this.password,
      this.withCredentials,
      this.headers,
      this.readyState,
      this.status,
      this.responseURL,
      this.responseType,
      this.response,
      this.responseText,
      this.responseXML,
      this.statusText,
      this.responseHeaders,
      this.event,
      this.action = AjaxRequestAction.PROCEED});

  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "method": method,
      "url": url,
      "isAsync": isAsync,
      "user": user,
      "password": password,
      "withCredentials": withCredentials,
      "headers": headers?.toMap(),
      "readyState": readyState?.toValue(),
      "status": status,
      "responseURL": responseURL,
      "responseType": responseType,
      "response": response,
      "responseText": responseText,
      "responseXML": responseXML,
      "statusText": statusText,
      "responseHeaders": responseHeaders,
      "action": action?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [FetchRequest] class.
class FetchRequestAction {
  final int _value;

  const FetchRequestAction._internal(this._value);

  int toValue() => _value;

  ///Aborts the fetch request.
  static const ABORT = const FetchRequestAction._internal(0);

  ///Proceeds with the fetch request.
  static const PROCEED = const FetchRequestAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that is an interface for [FetchRequestCredentialDefault], [FetchRequestFederatedCredential] and [FetchRequestPasswordCredential] classes.
class FetchRequestCredential {
  ///Type of credentials.
  String type;

  FetchRequestCredential({this.type});

  Map<String, dynamic> toMap() {
    return {"type": type};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the default credentials used by an [FetchRequest].
class FetchRequestCredentialDefault extends FetchRequestCredential {
  ///The value of the credentials.
  String value;

  FetchRequestCredentialDefault({type, this.value}) : super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "value": value,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a [FederatedCredential](https://developer.mozilla.org/en-US/docs/Web/API/FederatedCredential) type of credentials.
class FetchRequestFederatedCredential extends FetchRequestCredential {
  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String name;

  ///Credential's federated identity protocol.
  String protocol;

  ///Credential's federated identity provider.
  String provider;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  String iconURL;

  FetchRequestFederatedCredential(
      {type, this.id, this.name, this.protocol, this.provider, this.iconURL})
      : super(type: type);

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

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a [PasswordCredential](https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential) type of credentials.
class FetchRequestPasswordCredential extends FetchRequestCredential {
  ///Credential's identifier.
  dynamic id;

  ///The name associated with a credential. It should be a human-readable, public name.
  String name;

  ///The password of the credential.
  String password;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  String iconURL;

  FetchRequestPasswordCredential(
      {type, this.id, this.name, this.password, this.iconURL})
      : super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "password": password,
      "iconURL": iconURL
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a HTTP request created with JavaScript using the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch).
class FetchRequest {
  ///The URL of the request.
  String url;

  ///The HTTP request method used of the request.
  String method;

  ///The HTTP request headers.
  Map<String, dynamic> headers;

  ///Body of the request.
  Uint8List body;

  ///The mode used by the request.
  String mode;

  ///The request credentials used by the request.
  FetchRequestCredential credentials;

  ///The cache mode used by the request.
  String cache;

  ///The redirect mode used by the request.
  String redirect;

  ///A String specifying no-referrer, client, or a URL.
  String referrer;

  ///The value of the referer HTTP header.
  String referrerPolicy;

  ///Contains the subresource integrity value of the request.
  String integrity;

  ///The keepalive option used to allow the request to outlive the page.
  bool keepalive;

  ///Indicates the [FetchRequestAction] that can be used to control the request.
  FetchRequestAction action;

  FetchRequest(
      {this.url,
      this.method,
      this.headers,
      this.body,
      this.mode,
      this.credentials,
      this.cache,
      this.redirect,
      this.referrer,
      this.referrerPolicy,
      this.integrity,
      this.keepalive,
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

  @override
  String toString() {
    return toMap().toString();
  }

  static FetchRequestCredential fromMap(credentialsMap) {
    if (credentialsMap != null) {
      if (credentialsMap["type"] == "default") {
        return FetchRequestCredentialDefault(
            type: credentialsMap["type"], value: credentialsMap["value"]);
      } else if (credentialsMap["type"] == "federated") {
        return FetchRequestFederatedCredential(
            type: credentialsMap["type"],
            id: credentialsMap["id"],
            name: credentialsMap["name"],
            protocol: credentialsMap["protocol"],
            provider: credentialsMap["provider"],
            iconURL: credentialsMap["iconURL"]);
      } else if (credentialsMap["type"] == "password") {
        return FetchRequestPasswordCredential(
            type: credentialsMap["type"],
            id: credentialsMap["id"],
            name: credentialsMap["name"],
            password: credentialsMap["password"],
            iconURL: credentialsMap["iconURL"]);
      }
    }
    return null;
  }
}

///Class that represents the possible resource type defined for a [ContentBlockerTrigger].
class ContentBlockerTriggerResourceType {
  final String _value;

  const ContentBlockerTriggerResourceType._internal(this._value);

  static final Set<ContentBlockerTriggerResourceType> values = [
    ContentBlockerTriggerResourceType.DOCUMENT,
    ContentBlockerTriggerResourceType.IMAGE,
    ContentBlockerTriggerResourceType.STYLE_SHEET,
    ContentBlockerTriggerResourceType.SCRIPT,
    ContentBlockerTriggerResourceType.FONT,
    ContentBlockerTriggerResourceType.MEDIA,
    ContentBlockerTriggerResourceType.SVG_DOCUMENT,
    ContentBlockerTriggerResourceType.RAW,
  ].toSet();

  static ContentBlockerTriggerResourceType fromValue(String value) {
    if (value != null)
      return ContentBlockerTriggerResourceType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  static const DOCUMENT =
      const ContentBlockerTriggerResourceType._internal('document');
  static const IMAGE =
      const ContentBlockerTriggerResourceType._internal('image');
  static const STYLE_SHEET =
      const ContentBlockerTriggerResourceType._internal('style-sheet');
  static const SCRIPT =
      const ContentBlockerTriggerResourceType._internal('script');
  static const FONT = const ContentBlockerTriggerResourceType._internal('font');
  static const MEDIA =
      const ContentBlockerTriggerResourceType._internal('media');
  static const SVG_DOCUMENT =
      const ContentBlockerTriggerResourceType._internal('svg-document');

  ///Any untyped load
  static const RAW = const ContentBlockerTriggerResourceType._internal('raw');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the possible load type for a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadType {
  final String _value;

  const ContentBlockerTriggerLoadType._internal(this._value);

  static final Set<ContentBlockerTriggerLoadType> values = [
    ContentBlockerTriggerLoadType.FIRST_PARTY,
    ContentBlockerTriggerLoadType.THIRD_PARTY,
  ].toSet();

  static ContentBlockerTriggerLoadType fromValue(String value) {
    if (value != null)
      return ContentBlockerTriggerLoadType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY =
      const ContentBlockerTriggerLoadType._internal('first-party');

  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY =
      const ContentBlockerTriggerLoadType._internal('third-party');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
class ContentBlockerActionType {
  final String _value;

  const ContentBlockerActionType._internal(this._value);

  static final Set<ContentBlockerActionType> values = [
    ContentBlockerActionType.BLOCK,
    ContentBlockerActionType.CSS_DISPLAY_NONE,
    ContentBlockerActionType.MAKE_HTTPS,
  ].toSet();

  static ContentBlockerActionType fromValue(String value) {
    if (value != null)
      return ContentBlockerActionType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  static const BLOCK = const ContentBlockerActionType._internal('block');

  ///Hides elements of the page based on a CSS selector. A selector field contains the selector list. Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  static const CSS_DISPLAY_NONE =
      const ContentBlockerActionType._internal('css-display-none');

  ///Changes a URL from http to https. URLs with a specified (nondefault) port and links using other protocols are unaffected.
  static const MAKE_HTTPS =
      const ContentBlockerActionType._internal('make-https');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a cookie returned by the [CookieManager].
class Cookie {
  ///The cookie name.
  String name;

  ///The cookie value.
  dynamic value;

  ///The cookie expiration date in milliseconds.
  ///
  ///**NOTE**: on Android it will be always `null`.
  int expiresDate;

  ///Indicates if the cookie is a session only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool isSessionOnly;

  ///The cookie domain.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String domain;

  ///The cookie same site policy.
  ///
  ///**NOTE**: on Android it will be always `null`.
  HTTPCookieSameSitePolicy sameSite;

  ///Indicates if the cookie is secure or not.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool isSecure;

  ///Indicates if the cookie is a http only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool isHttpOnly;

  ///The cookie path.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String path;

  Cookie(
      {@required this.name,
      @required this.value,
      this.expiresDate,
      this.isSessionOnly,
      this.domain,
      this.sameSite,
      this.isSecure,
      this.isHttpOnly,
      this.path});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "value": value,
      "expiresDate": expiresDate,
      "isSessionOnly": isSessionOnly,
      "domain": domain,
      "sameSite": sameSite?.toValue(),
      "isSecure": isSecure,
      "isHttpOnly": isHttpOnly,
      "path": path
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [PermissionRequestResponse] class.
class PermissionRequestResponseAction {
  final int _value;

  const PermissionRequestResponseAction._internal(this._value);

  int toValue() => _value;

  ///Denies the request.
  static const DENY = const PermissionRequestResponseAction._internal(0);

  ///Grants origin the permission to access the given resources.
  static const GRANT = const PermissionRequestResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the response used by the [WebView.androidOnPermissionRequest] event.
class PermissionRequestResponse {
  ///Resources granted to be accessed by origin.
  List<String> resources;

  ///Indicate the [PermissionRequestResponseAction] to take in response of a permission request.
  PermissionRequestResponseAction action;

  PermissionRequestResponse(
      {this.resources = const [],
      this.action = PermissionRequestResponseAction.DENY});

  Map<String, dynamic> toMap() {
    return {"resources": resources, "action": action?.toValue()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that is used by [WebView.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
class ShouldOverrideUrlLoadingAction {
  final int _value;

  const ShouldOverrideUrlLoadingAction._internal(this._value);

  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const ShouldOverrideUrlLoadingAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const ShouldOverrideUrlLoadingAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}

///Class that represents the type of action triggering a navigation on iOS for the [WebView.shouldOverrideUrlLoading] event.
class IOSWKNavigationType {
  final int _value;

  const IOSWKNavigationType._internal(this._value);

  static final Set<IOSWKNavigationType> values = [
    IOSWKNavigationType.LINK_ACTIVATED,
    IOSWKNavigationType.FORM_SUBMITTED,
    IOSWKNavigationType.BACK_FORWARD,
    IOSWKNavigationType.RELOAD,
    IOSWKNavigationType.FORM_RESUBMITTED,
    IOSWKNavigationType.OTHER,
  ].toSet();

  static IOSWKNavigationType fromValue(int value) {
    if (value != null)
      return IOSWKNavigationType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  ///A link with an href attribute was activated by the user.
  static const LINK_ACTIVATED = const IOSWKNavigationType._internal(0);

  ///A form was submitted.
  static const FORM_SUBMITTED = const IOSWKNavigationType._internal(1);

  ///An item from the back-forward list was requested.
  static const BACK_FORWARD = const IOSWKNavigationType._internal(2);

  ///The webpage was reloaded.
  static const RELOAD = const IOSWKNavigationType._internal(3);

  ///A form was resubmitted (for example by going back, going forward, or reloading).
  static const FORM_RESUBMITTED = const IOSWKNavigationType._internal(4);

  ///Navigation is taking place for some other reason.
  static const OTHER = const IOSWKNavigationType._internal(-1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the navigation request used by the [WebView.shouldOverrideUrlLoading] event.
class ShouldOverrideUrlLoadingRequest {
  ///Represents the url of the navigation request.
  String url;

  ///Represents the method of the navigation request. On Android < 21, this value is always `GET`.
  String method;

  ///Represents the headers of the navigation request. On Android < 21, this is always `null`.
  Map<String, String> headers;

  ///Indicates whether the request was made for the main frame. On Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///Available only on Android. On Android < 24, this is always `false`.
  bool androidHasGesture;

  ///Gets whether the request was a result of a server-side redirect. Available only on Android. On Android < 21, this is always `false`.
  bool androidIsRedirect;

  ///The type of action triggering the navigation. Available only on iOS.
  IOSWKNavigationType iosWKNavigationType;

  ShouldOverrideUrlLoadingRequest(
      {this.url,
      this.method,
      this.headers,
      this.isForMainFrame,
      this.androidHasGesture,
      this.androidIsRedirect,
      this.iosWKNavigationType});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
      "headers": headers,
      "method": method,
      "isForMainFrame": isForMainFrame,
      "androidHasGesture": androidHasGesture,
      "androidIsRedirect": androidIsRedirect,
      "iosWKNavigationType": iosWKNavigationType?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the navigation request used by the [WebView.onCreateWindow] event.
class CreateWindowRequest {
  ///The URL of the request.
  ///
  ///**NOTE**: On Android, if the window has been created using JavaScript, this will be `null`.
  String url;

  ///The window id. Used by [WebView] to create a new WebView.
  int windowId;

  ///Indicates if the new window should be a dialog, rather than a full-size window. Available only on Android.
  bool androidIsDialog;

  ///Indicates if the request was initiated by a user gesture, such as the user clicking a link. Available only on Android.
  bool androidIsUserGesture;

  ///The type of action triggering the navigation. Available only on iOS.
  IOSWKNavigationType iosWKNavigationType;

  ///Whether the request was made in order to fetch the main frame's document. Available only on iOS.
  bool iosIsForMainFrame;

  CreateWindowRequest(
      {this.url,
      this.windowId,
      this.androidIsDialog,
      this.androidIsUserGesture,
      this.iosWKNavigationType,
      this.iosIsForMainFrame});

  Map<String, dynamic> toMap() {
    return {
      "androidIsDialog": androidIsDialog,
      "androidIsUserGesture": androidIsUserGesture,
      "iosWKNavigationType": iosWKNavigationType?.toValue(),
      "iosUrl": url,
      "windowId": windowId
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that encapsulates information about the amount of storage currently used by an origin for the JavaScript storage APIs.
///An origin comprises the host, scheme and port of a URI. See [AndroidWebStorageManager] for details.
class AndroidWebStorageOrigin {
  ///The string representation of this origin.
  String origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int usage;

  AndroidWebStorageOrigin({this.origin, this.quota, this.usage});

  Map<String, dynamic> toMap() {
    return {"origin": origin, "quota": quota, "usage": usage};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a website data type.
///
///**NOTE**: available on iOS 9.0+.
class IOSWKWebsiteDataType {
  final String _value;

  const IOSWKWebsiteDataType._internal(this._value);

  static final Set<IOSWKWebsiteDataType> values = [
    IOSWKWebsiteDataType.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations,
  ].toSet();

  static IOSWKWebsiteDataType fromValue(String value) {
    if (value != null)
      return IOSWKWebsiteDataType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///On-disk Fetch caches.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeFetchCache =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeFetchCache");

  ///On-disk caches.
  static const WKWebsiteDataTypeDiskCache =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeDiskCache");

  ///In-memory caches.
  static const WKWebsiteDataTypeMemoryCache =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeMemoryCache");

  ///HTML offline web application caches.
  static const WKWebsiteDataTypeOfflineWebApplicationCache =
      const IOSWKWebsiteDataType._internal(
          "WKWebsiteDataTypeOfflineWebApplicationCache");

  ///Cookies.
  static const WKWebsiteDataTypeCookies =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeCookies");

  ///HTML session storage.
  static const WKWebsiteDataTypeSessionStorage =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeSessionStorage");

  ///HTML local storage.
  static const WKWebsiteDataTypeLocalStorage =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeLocalStorage");

  ///WebSQL databases.
  static const WKWebsiteDataTypeWebSQLDatabases =
      const IOSWKWebsiteDataType._internal("WKWebsiteDataTypeWebSQLDatabases");

  ///IndexedDB databases.
  static const WKWebsiteDataTypeIndexedDBDatabases =
      const IOSWKWebsiteDataType._internal(
          "WKWebsiteDataTypeIndexedDBDatabases");

  ///Service worker registrations.
  ///
  ///**NOTE**: available on iOS 11.3+.
  static const WKWebsiteDataTypeServiceWorkerRegistrations =
      const IOSWKWebsiteDataType._internal(
          "WKWebsiteDataTypeServiceWorkerRegistrations");

  ///Returns a set of all available website data types.
  // ignore: non_constant_identifier_names
  static final Set<IOSWKWebsiteDataType> ALL = [
    IOSWKWebsiteDataType.WKWebsiteDataTypeFetchCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeDiskCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeMemoryCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeOfflineWebApplicationCache,
    IOSWKWebsiteDataType.WKWebsiteDataTypeCookies,
    IOSWKWebsiteDataType.WKWebsiteDataTypeSessionStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeLocalStorage,
    IOSWKWebsiteDataType.WKWebsiteDataTypeWebSQLDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeIndexedDBDatabases,
    IOSWKWebsiteDataType.WKWebsiteDataTypeServiceWorkerRegistrations
  ].toSet();

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents website data, grouped by domain name using the public suffix list.
///
///**NOTE**: available on iOS 9.0+.
class IOSWKWebsiteDataRecord {
  ///The display name for the data record. This is usually the domain name.
  String displayName;

  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType> dataTypes;

  IOSWKWebsiteDataRecord({this.displayName, this.dataTypes});

  Map<String, dynamic> toMap() {
    List<String> dataTypesString = [];
    for (var dataType in dataTypes) {
      dataTypesString.add(dataType.toValue());
    }

    return {"displayName": displayName, "dataTypes": dataTypesString};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class representing the [InAppWebViewHitTestResult] type.
class InAppWebViewHitTestResultType {
  final int _value;

  const InAppWebViewHitTestResultType._internal(this._value);

  static final Set<InAppWebViewHitTestResultType> values = [
    InAppWebViewHitTestResultType.UNKNOWN_TYPE,
    InAppWebViewHitTestResultType.PHONE_TYPE,
    InAppWebViewHitTestResultType.GEO_TYPE,
    InAppWebViewHitTestResultType.EMAIL_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.EDIT_TEXT_TYPE,
  ].toSet();

  static InAppWebViewHitTestResultType fromValue(int value) {
    if (value != null)
      return InAppWebViewHitTestResultType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 2:
        return "PHONE_TYPE";
      case 3:
        return "GEO_TYPE";
      case 4:
        return "EMAIL_TYPE";
      case 5:
        return "IMAGE_TYPE";
      case 7:
        return "SRC_ANCHOR_TYPE";
      case 8:
        return "SRC_IMAGE_ANCHOR_TYPE";
      case 9:
        return "EDIT_TEXT_TYPE";
      case 0:
      default:
        return "UNKNOWN_TYPE";
    }
  }

  ///Default [InAppWebViewHitTestResult], where the target is unknown.
  static const UNKNOWN_TYPE = const InAppWebViewHitTestResultType._internal(0);

  ///[InAppWebViewHitTestResult] for hitting a phone number.
  static const PHONE_TYPE = const InAppWebViewHitTestResultType._internal(2);

  ///[InAppWebViewHitTestResult] for hitting a map address.
  static const GEO_TYPE = const InAppWebViewHitTestResultType._internal(3);

  ///[InAppWebViewHitTestResult] for hitting an email address.
  static const EMAIL_TYPE = const InAppWebViewHitTestResultType._internal(4);

  ///[InAppWebViewHitTestResult] for hitting an HTML::img tag.
  static const IMAGE_TYPE = const InAppWebViewHitTestResultType._internal(5);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http.
  static const SRC_ANCHOR_TYPE =
      const InAppWebViewHitTestResultType._internal(7);

  ///[InAppWebViewHitTestResult] for hitting a HTML::a tag with src=http + HTML::img.
  static const SRC_IMAGE_ANCHOR_TYPE =
      const InAppWebViewHitTestResultType._internal(8);

  ///[InAppWebViewHitTestResult] for hitting an edit text area.
  static const EDIT_TEXT_TYPE =
      const InAppWebViewHitTestResultType._internal(9);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the hit result for hitting an HTML elements.
class InAppWebViewHitTestResult {
  ///The type of the hit test result.
  InAppWebViewHitTestResultType type;

  ///Additional type-dependant information about the result.
  String extra;

  InAppWebViewHitTestResult({this.type, this.extra});

  Map<String, dynamic> toMap() {
    return {"type": type?.toValue(), "extra": extra};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the action to take used by the [WebView.androidOnRenderProcessUnresponsive] and [WebView.androidOnRenderProcessResponsive] event
///to terminate the Android [WebViewRenderProcess](https://developer.android.com/reference/android/webkit/WebViewRenderProcess).
class WebViewRenderProcessAction {
  final int _value;

  const WebViewRenderProcessAction._internal(this._value);

  int toValue() => _value;

  ///Cause this renderer to terminate.
  static const TERMINATE = const WebViewRenderProcessAction._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {"action": _value};
  }
}

///Class that provides more specific information about why the render process exited.
///It is used by the [WebView.androidOnRenderProcessGone] event.
class RenderProcessGoneDetail {
  ///Indicates whether the render process was observed to crash, or whether it was killed by the system.
  ///
  ///If the render process was killed, this is most likely caused by the system being low on memory.
  bool didCrash;

  /// Returns the renderer priority that was set at the time that the renderer exited. This may be greater than the priority that
  /// any individual [WebView] requested using [].
  RendererPriority rendererPriorityAtExit;

  RenderProcessGoneDetail({this.didCrash, this.rendererPriorityAtExit});

  Map<String, dynamic> toMap() {
    return {
      "didCrash": didCrash,
      "rendererPriorityAtExit": rendererPriorityAtExit?.toValue()
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [RendererPriorityPolicy] class.
class RendererPriority {
  final int _value;

  const RendererPriority._internal(this._value);

  static final Set<RendererPriority> values = [
    RendererPriority.RENDERER_PRIORITY_WAIVED,
    RendererPriority.RENDERER_PRIORITY_BOUND,
    RendererPriority.RENDERER_PRIORITY_IMPORTANT,
  ].toSet();

  static RendererPriority fromValue(int value) {
    if (value != null)
      return RendererPriority.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "RENDERER_PRIORITY_WAIVED";
      case 1:
        return "RENDERER_PRIORITY_BOUND";
      case 2:
      default:
        return "RENDERER_PRIORITY_IMPORTANT";
    }
  }

  ///The renderer associated with this WebView is bound with Android `Context#BIND_WAIVE_PRIORITY`.
  ///At this priority level WebView renderers will be strong targets for out of memory killing.
  static const RENDERER_PRIORITY_WAIVED = const RendererPriority._internal(0);

  ///The renderer associated with this WebView is bound with the default priority for services.
  static const RENDERER_PRIORITY_BOUND = const RendererPriority._internal(1);

  ///The renderer associated with this WebView is bound with Android `Context#BIND_IMPORTANT`.
  static const RENDERER_PRIORITY_IMPORTANT =
      const RendererPriority._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the priority policy will be used to determine whether an out of process renderer should be considered to be a target for OOM killing.
///When a WebView is destroyed it will cease to be considerered when calculating the renderer priority.
///Once no WebViews remain associated with the renderer, the priority of the renderer will be reduced to [RendererPriority.RENDERER_PRIORITY_WAIVED].
///The default policy is to set the priority to [RendererPriority.RENDERER_PRIORITY_IMPORTANT] regardless of visibility,
///and this should not be changed unless the caller also handles renderer crashes with [WebView.androidOnRenderProcessGone].
///Any other setting will result in WebView renderers being killed by the system more aggressively than the application.
class RendererPriorityPolicy {
  ///The minimum priority at which this WebView desires the renderer process to be bound.
  RendererPriority rendererRequestedPriority;

  ///If true, this flag specifies that when this WebView is not visible, it will be treated as if it had requested a priority of [RendererPriority.RENDERER_PRIORITY_WAIVED].
  bool waivedWhenNotVisible;

  RendererPriorityPolicy(
      {@required this.rendererRequestedPriority,
      @required this.waivedWhenNotVisible});

  Map<String, dynamic> toMap() {
    return {
      "rendererRequestedPriority": rendererRequestedPriority?.toValue(),
      "waivedWhenNotVisible": waivedWhenNotVisible
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static RendererPriorityPolicy fromMap(Map<String, dynamic> map) {
    return map != null
        ? RendererPriorityPolicy(
            rendererRequestedPriority:
                RendererPriority.fromValue(map["rendererRequestedPriority"]),
            waivedWhenNotVisible: map["waivedWhenNotVisible"])
        : null;
  }
}

///Class that represents the action to take used by the [WebView.androidOnFormResubmission] event.
class FormResubmissionAction {
  final int _value;

  const FormResubmissionAction._internal(this._value);

  int toValue() => _value;

  ///Resend data
  static const RESEND = const FormResubmissionAction._internal(0);

  ///Don't resend data
  static const DONT_RESEND = const FormResubmissionAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {"action": _value};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents an Android-specific class used to configure the WebView's over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
class AndroidOverScrollMode {
  final int _value;

  const AndroidOverScrollMode._internal(this._value);

  static final Set<AndroidOverScrollMode> values = [
    AndroidOverScrollMode.OVER_SCROLL_ALWAYS,
    AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    AndroidOverScrollMode.OVER_SCROLL_NEVER,
  ].toSet();

  static AndroidOverScrollMode fromValue(int value) {
    if (value != null)
      return AndroidOverScrollMode.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "OVER_SCROLL_IF_CONTENT_SCROLLS";
      case 2:
        return "OVER_SCROLL_NEVER";
      case 0:
      default:
        return "OVER_SCROLL_ALWAYS";
    }
  }

  ///Always allow a user to over-scroll this view, provided it is a view that can scroll.
  static const OVER_SCROLL_ALWAYS = const AndroidOverScrollMode._internal(0);

  ///Allow a user to over-scroll this view only if the content is large enough to meaningfully scroll, provided it is a view that can scroll.
  static const OVER_SCROLL_IF_CONTENT_SCROLLS =
      const AndroidOverScrollMode._internal(1);

  ///Never allow a user to over-scroll this view.
  static const OVER_SCROLL_NEVER = const AndroidOverScrollMode._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to configure the style of the scrollbars.
///The scrollbars can be overlaid or inset.
///When inset, they add to the padding of the view. And the scrollbars can be drawn inside the padding area or on the edge of the view.
///For example, if a view has a background drawable and you want to draw the scrollbars inside the padding specified by the drawable,
///you can use [AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET].
///If you want them to appear at the edge of the view, ignoring the padding,
///then you can use [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY] or [AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET].
class AndroidScrollBarStyle {
  final int _value;

  const AndroidScrollBarStyle._internal(this._value);

  static final Set<AndroidScrollBarStyle> values = [
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_OVERLAY,
    AndroidScrollBarStyle.SCROLLBARS_INSIDE_INSET,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY,
    AndroidScrollBarStyle.SCROLLBARS_OUTSIDE_INSET,
  ].toSet();

  static AndroidScrollBarStyle fromValue(int value) {
    if (value != null)
      return AndroidScrollBarStyle.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 16777216:
        return "SCROLLBARS_INSIDE_INSET";
      case 33554432:
        return "SCROLLBARS_OUTSIDE_OVERLAY";
      case 50331648:
        return "SCROLLBARS_OUTSIDE_INSET";
      case 0:
      default:
        return "SCROLLBARS_INSIDE_OVERLAY";
    }
  }

  ///The scrollbar style to display the scrollbars inside the content area, without increasing the padding.
  ///The scrollbars will be overlaid with translucency on the view's content.
  static const SCROLLBARS_INSIDE_OVERLAY =
      const AndroidScrollBarStyle._internal(0);

  ///The scrollbar style to display the scrollbars inside the padded area, increasing the padding of the view.
  ///The scrollbars will not overlap the content area of the view.
  static const SCROLLBARS_INSIDE_INSET =
      const AndroidScrollBarStyle._internal(16777216);

  ///The scrollbar style to display the scrollbars at the edge of the view, without increasing the padding.
  ///The scrollbars will be overlaid with translucency.
  static const SCROLLBARS_OUTSIDE_OVERLAY =
      const AndroidScrollBarStyle._internal(33554432);

  ///The scrollbar style to display the scrollbars at the edge of the view, increasing the padding of the view.
  ///The scrollbars will only overlap the background, if any.
  static const SCROLLBARS_OUTSIDE_INSET =
      const AndroidScrollBarStyle._internal(50331648);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android-specific class used to configure the position of the vertical scroll bar.
class AndroidVerticalScrollbarPosition {
  final int _value;

  const AndroidVerticalScrollbarPosition._internal(this._value);

  static final Set<AndroidVerticalScrollbarPosition> values = [
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  static AndroidVerticalScrollbarPosition fromValue(int value) {
    if (value != null)
      return AndroidVerticalScrollbarPosition.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SCROLLBAR_POSITION_LEFT";
      case 2:
        return "SCROLLBAR_POSITION_RIGHT";
      case 0:
      default:
        return "SCROLLBAR_POSITION_DEFAULT";
    }
  }

  ///Position the scroll bar at the default position as determined by the system.
  static const SCROLLBAR_POSITION_DEFAULT =
      const AndroidVerticalScrollbarPosition._internal(0);

  ///Position the scroll bar along the left edge.
  static const SCROLLBAR_POSITION_LEFT =
      const AndroidVerticalScrollbarPosition._internal(1);

  ///Position the scroll bar along the right edge.
  static const SCROLLBAR_POSITION_RIGHT =
      const AndroidVerticalScrollbarPosition._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an Android WebView package info.
class AndroidWebViewPackageInfo {
  ///The version name of this WebView package.
  String versionName;

  ///The name of this WebView package.
  String packageName;

  AndroidWebViewPackageInfo({this.versionName, this.packageName});

  static AndroidWebViewPackageInfo fromMap(Map<String, dynamic> map) {
    return map != null
        ? AndroidWebViewPackageInfo(
            versionName: map["versionName"], packageName: map["packageName"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {"versionName": versionName, "packageName": packageName};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the result used by the [InAppWebViewController.requestFocusNodeHref] method.
class RequestFocusNodeHrefResult {
  ///The anchor's href attribute.
  String url;

  ///The anchor's text.
  String title;

  ///The image's src attribute.
  String src;

  RequestFocusNodeHrefResult({this.url, this.title, this.src});

  Map<String, dynamic> toMap() {
    return {"url": url, "title": title, "src": src};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the result used by the [InAppWebViewController.requestImageRef] method.
class RequestImageRefResult {
  ///The image's url.
  String url;

  RequestImageRefResult({this.url});

  Map<String, dynamic> toMap() {
    return {
      "url": url,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a `<meta>` HTML tag. It is used by the [InAppWebViewController.getMetaTags] method.
class MetaTag {
  ///The meta tag name value.
  String name;

  ///The meta tag content value.
  String content;

  ///The meta tag attributes list.
  List<MetaTagAttribute> attrs;

  MetaTag({this.name, this.content, this.attrs});

  Map<String, dynamic> toMap() {
    return {"name": name, "content": content, "attrs": attrs};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents an attribute of a `<meta>` HTML tag. It is used by the [MetaTag] class.
class MetaTagAttribute {
  ///The attribute name.
  String name;

  ///The attribute value.
  String value;

  MetaTagAttribute({this.name, this.value});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "value": value,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the type of Web Storage: `localStorage` or `sessionStorage`.
///Used by the [Storage] class.
class WebStorageType {
  final String _value;

  const WebStorageType._internal(this._value);

  static final Set<WebStorageType> values = [
    WebStorageType.LOCAL_STORAGE,
    WebStorageType.SESSION_STORAGE,
  ].toSet();

  static WebStorageType fromValue(String value) {
    if (value != null)
      return WebStorageType.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///`window.localStorage`: same as [SESSION_STORAGE], but persists even when the browser is closed and reopened.
  static const LOCAL_STORAGE = const WebStorageType._internal("localStorage");

  ///`window.sessionStorage`: maintains a separate storage area for each given origin that's available for the duration
  ///of the page session (as long as the browser is open, including page reloads and restores).
  static const SESSION_STORAGE =
      const WebStorageType._internal("sessionStorage");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the same site policy of a cookie. Used by the [Cookie] class.
class HTTPCookieSameSitePolicy {
  final String _value;

  const HTTPCookieSameSitePolicy._internal(this._value);

  static final Set<HTTPCookieSameSitePolicy> values = [
    HTTPCookieSameSitePolicy.LAX,
    HTTPCookieSameSitePolicy.STRICT,
    HTTPCookieSameSitePolicy.NONE,
  ].toSet();

  static HTTPCookieSameSitePolicy fromValue(String value) {
    if (value != null)
      return HTTPCookieSameSitePolicy.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///SameSite=Lax;
  ///
  ///Cookies are allowed to be sent with top-level navigations and will be sent along with GET
  ///request initiated by third party website. This is the default value in modern browsers.
  static const LAX = const HTTPCookieSameSitePolicy._internal("Lax");

  ///SameSite=Strict;
  ///
  ///Cookies will only be sent in a first-party context and not be sent along with requests initiated by third party websites.
  static const STRICT = const HTTPCookieSameSitePolicy._internal("Strict");

  ///SameSite=None;
  ///
  ///Cookies will be sent in all contexts, i.e sending cross-origin is allowed.
  ///`None` requires the `Secure` attribute in latest browser versions.
  static const NONE = const HTTPCookieSameSitePolicy._internal("None");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the Android-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
class AndroidSslError {
  final int _value;

  const AndroidSslError._internal(this._value);

  static final Set<AndroidSslError> values = [
    AndroidSslError.SSL_NOTYETVALID,
    AndroidSslError.SSL_EXPIRED,
    AndroidSslError.SSL_IDMISMATCH,
    AndroidSslError.SSL_UNTRUSTED,
    AndroidSslError.SSL_DATE_INVALID,
    AndroidSslError.SSL_INVALID,
  ].toSet();

  static AndroidSslError fromValue(int value) {
    if (value != null)
      return AndroidSslError.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SSL_EXPIRED";
      case 2:
        return "SSL_IDMISMATCH";
      case 3:
        return "SSL_UNTRUSTED";
      case 4:
        return "SSL_DATE_INVALID";
      case 5:
        return "SSL_INVALID";
      case 0:
      default:
        return "SSL_NOTYETVALID";
    }
  }

  ///The certificate is not yet valid
  static const SSL_NOTYETVALID = const AndroidSslError._internal(0);

  ///The certificate has expired
  static const SSL_EXPIRED = const AndroidSslError._internal(1);

  ///Hostname mismatch
  static const SSL_IDMISMATCH = const AndroidSslError._internal(2);

  ///The certificate authority is not trusted
  static const SSL_UNTRUSTED = const AndroidSslError._internal(3);

  ///The date of the certificate is invalid
  static const SSL_DATE_INVALID = const AndroidSslError._internal(4);

  ///A generic error occurred
  static const SSL_INVALID = const AndroidSslError._internal(5);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the iOS-specific primary error associated to the server SSL certificate.
///Used by the [ServerTrustChallenge] class.
class IOSSslError {
  final int _value;

  const IOSSslError._internal(this._value);

  static final Set<IOSSslError> values = [
    IOSSslError.INVALID,
    IOSSslError.DENY,
    IOSSslError.UNSPECIFIED,
    IOSSslError.RECOVERABLE_TRUST_FAILURE,
    IOSSslError.FATAL_TRUST_FAILURE,
    IOSSslError.OTHER_ERROR,
  ].toSet();

  static IOSSslError fromValue(int value) {
    if (value != null)
      return IOSSslError.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 3:
        return "DENY";
      case 4:
        return "UNSPECIFIED";
      case 5:
        return "RECOVERABLE_TRUST_FAILURE";
      case 6:
        return "FATAL_TRUST_FAILURE";
      case 7:
        return "OTHER_ERROR";
      case 0:
      default:
        return "INVALID";
    }
  }

  ///Indicates an invalid setting or result.
  static const INVALID = const IOSSslError._internal(0);

  ///Indicates a user-configured deny; do not proceed.
  static const DENY = const IOSSslError._internal(3);

  ///Indicates the evaluation succeeded and the certificate is implicitly trusted, but user intent was not explicitly specified.
  static const UNSPECIFIED = const IOSSslError._internal(4);

  ///Indicates a trust policy failure which can be overridden by the user.
  static const RECOVERABLE_TRUST_FAILURE = const IOSSslError._internal(5);

  ///Indicates a trust failure which cannot be overridden by the user.
  static const FATAL_TRUST_FAILURE = const IOSSslError._internal(6);

  ///Indicates a failure other than that of trust evaluation.
  static const OTHER_ERROR = const IOSSslError._internal(7);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an iOS-specific class used to configure how safe area insets are added to the adjusted content inset.
///
///**NOTE**: available on iOS 11.0+.
class IOSUIScrollViewContentInsetAdjustmentBehavior {
  final int _value;

  const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(this._value);

  static final Set<IOSUIScrollViewContentInsetAdjustmentBehavior> values = [
    IOSUIScrollViewContentInsetAdjustmentBehavior.AUTOMATIC,
    IOSUIScrollViewContentInsetAdjustmentBehavior.SCROLLABLE_AXES,
    IOSUIScrollViewContentInsetAdjustmentBehavior.NEVER,
    IOSUIScrollViewContentInsetAdjustmentBehavior.ALWAYS,
  ].toSet();

  static IOSUIScrollViewContentInsetAdjustmentBehavior fromValue(int value) {
    if (value != null)
      return IOSUIScrollViewContentInsetAdjustmentBehavior.values.firstWhere(
          (element) => element.toValue() == value,
          orElse: () => null);
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SCROLLABLE_AXES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "AUTOMATIC";
    }
  }

  ///Automatically adjust the scroll view insets.
  static const AUTOMATIC =
      const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(0);

  ///Adjust the insets only in the scrollable directions.
  static const SCROLLABLE_AXES =
      const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(1);

  ///Do not adjust the scroll view insets.
  static const NEVER =
      const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(2);

  ///Always include the safe area insets in the content adjustment.
  static const ALWAYS =
      const IOSUIScrollViewContentInsetAdjustmentBehavior._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///SSL certificate info (certificate details) class.
class SslCertificate {
  ///Name of the entity this certificate is issued by
  SslCertificateDName issuedBy;

  ///Name of the entity this certificate is issued to
  SslCertificateDName issuedTo;

  ///Not-after date from the validity period
  DateTime validNotAfterDate;

  ///Not-before date from the validity period
  DateTime validNotBeforeDate;

  ///The original source certificate, if available.
  X509Certificate x509Certificate;

  SslCertificate(
      {this.issuedBy,
      this.issuedTo,
      this.validNotAfterDate,
      this.validNotBeforeDate,
      this.x509Certificate});

  static SslCertificate fromMap(Map<String, dynamic> map) {
    X509Certificate x509Certificate;
    try {
      x509Certificate = X509Certificate.fromData(data: map["x509Certificate"]);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }

    return map != null
        ? SslCertificate(
            issuedBy: SslCertificateDName.fromMap(
                map["issuedBy"]?.cast<String, dynamic>()),
            issuedTo: SslCertificateDName.fromMap(
                map["issuedTo"]?.cast<String, dynamic>()),
            validNotAfterDate:
                DateTime.fromMillisecondsSinceEpoch(map["validNotAfterDate"]),
            validNotBeforeDate:
                DateTime.fromMillisecondsSinceEpoch(map["validNotBeforeDate"]),
            x509Certificate: x509Certificate,
          )
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "issuedBy": issuedBy?.toMap(),
      "issuedTo": issuedTo?.toMap(),
      "validNotAfterDate": validNotAfterDate.millisecondsSinceEpoch,
      "validNotBeforeDate": validNotBeforeDate.millisecondsSinceEpoch,
      "x509Certificate": x509Certificate?.toMap(),
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Distinguished name helper class. Used by [SslCertificate].
class SslCertificateDName {
  ///Common-name (CN) component of the name
  // ignore: non_constant_identifier_names
  String CName;

  ///Distinguished name (normally includes CN, O, and OU names)
  // ignore: non_constant_identifier_names
  String DName;

  ///Organization (O) component of the name
  // ignore: non_constant_identifier_names
  String OName;

  ///Organizational Unit (OU) component of the name
  // ignore: non_constant_identifier_names
  String UName;

  SslCertificateDName(
      // ignore: non_constant_identifier_names
      {this.CName = "",
      // ignore: non_constant_identifier_names
      this.DName = "",
      // ignore: non_constant_identifier_names
      this.OName = "",
      // ignore: non_constant_identifier_names
      this.UName = ""});

  static SslCertificateDName fromMap(Map<String, dynamic> map) {
    return map != null
        ? SslCertificateDName(
            CName: map["CName"] ?? "",
            DName: map["DName"] ?? "",
            OName: map["OName"] ?? "",
            UName: map["UName"] ?? "",
          )
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "CName": CName,
      "DName": DName,
      "OName": OName,
      "UName": UName,
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class used by [WebView.androidOnReceivedLoginRequest] event.
class LoginRequest {
  ///The account realm used to look up accounts.
  String realm;

  ///An optional account. If not `null`, the account should be checked against accounts on the device.
  ///If it is a valid account, it should be used to log in the user. This value may be `null`.
  String account;

  ///Authenticator specific arguments used to log in the user.
  String args;

  LoginRequest({this.realm, this.account, this.args});

  Map<String, dynamic> toMap() {
    return {"realm": realm, "account": account, "args": args};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
