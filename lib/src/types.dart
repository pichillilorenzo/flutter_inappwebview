import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'x509_certificate/x509_certificate.dart';
import 'x509_certificate/asn1_distinguished_names.dart';

import 'in_app_webview/webview.dart';
import 'in_app_webview/in_app_webview_controller.dart';
import 'http_auth_credentials_database.dart';
import 'cookie_manager.dart';
import 'web_storage/web_storage.dart';
import 'pull_to_refresh/pull_to_refresh_controller.dart';
import 'pull_to_refresh/pull_to_refresh_options.dart';
import 'util.dart';
import 'web_message/web_message_listener.dart';
import 'web_message/web_message_channel.dart';

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

///The listener for handling [WebMessageListener] events sent by a `postMessage()` on the injected JavaScript object.
typedef void OnPostMessageCallback(String? message, Uri? sourceOrigin,
    bool isMainFrame, JavaScriptReplyProxy replyProxy);

///The listener for handling [WebMessagePort] events.
///The message callback methods are called on the main thread.
typedef void WebMessageCallback(String? message);

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

  static ConsoleMessageLevel? fromValue(int? value) {
    if (value != null) {
      try {
        return ConsoleMessageLevel.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  String? initiatorType;

  ///Resource URL.
  Uri? url;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double? startTime;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double? duration;

  LoadedResource({this.initiatorType, this.url, this.startTime, this.duration});

  static LoadedResource? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return LoadedResource(
        initiatorType: map["initiatorType"],
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        startTime: map["startTime"],
        duration: map["duration"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "initiatorType": initiatorType,
      "url": url?.toString(),
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
  late Uri baseUrl;

  ///The URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///
  ///This parameter is used only on Android.
  late Uri androidHistoryUrl;

  InAppWebViewInitialData(
      {required this.data,
      this.mimeType = "text/html",
      this.encoding = "utf8",
      Uri? baseUrl,
      Uri? androidHistoryUrl}) {
    this.baseUrl = baseUrl == null ? Uri.parse("about:blank") : baseUrl;
    this.androidHistoryUrl = androidHistoryUrl == null
        ? Uri.parse("about:blank")
        : androidHistoryUrl;
  }

  Map<String, String> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl.toString(),
      "historyUrl": androidHistoryUrl.toString()
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
///**NOTE**: available only on Android.
///
///**Official Android API**: https://developer.android.com/reference/android/webkit/WebResourceRequest
class WebResourceRequest {
  ///The URL for which the resource request was made.
  Uri url;

  ///The headers associated with the request.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `null`.
  Map<String, String>? headers;

  ///The method associated with the request, for example `GET`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always "GET".
  String? method;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? hasGesture;

  ///Whether the request was made in order to fetch the main frame's document.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `true`.
  bool? isForMainFrame;

  ///Whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? isRedirect;

  WebResourceRequest(
      {required this.url,
      this.headers,
      required this.method,
      required this.hasGesture,
      required this.isForMainFrame,
      required this.isRedirect});

  static WebResourceRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return WebResourceRequest(
        url: Uri.tryParse(map["url"]) ?? Uri(),
        headers: map["headers"]?.cast<String, String>(),
        method: map["method"],
        hasGesture: map["hasGesture"],
        isForMainFrame: map["isForMainFrame"],
        isRedirect: map["isRedirect"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
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
///**NOTE**: available only on Android.
///
///**Official Android API**: https://developer.android.com/reference/android/webkit/WebResourceResponse
class WebResourceResponse {
  ///The resource response's MIME type, for example `text/html`.
  String contentType;

  ///The resource response's encoding. The default value is `utf-8`.
  String contentEncoding;

  ///The data provided by the resource response.
  Uint8List? data;

  ///The headers for the resource response. If [headers] isn't `null`, then you need to set also [statusCode] and [reasonPhrase].
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  Map<String, String>? headers;

  ///The status code needs to be in the ranges [100, 299], [400, 599]. Causing a redirect by specifying a 3xx code is not supported.
  ///If statusCode is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  int? statusCode;

  ///The phrase describing the status code, for example `"OK"`. Must be non-empty.
  ///If reasonPhrase is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  String? reasonPhrase;

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
      "headers": headers,
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

  ///Content-Encoding of the data, such as `utf-8`.
  String contentEncoding;

  CustomSchemeResponse(
      {required this.data,
      required this.contentType,
      this.contentEncoding = 'utf-8'});

  Map<String, dynamic> toMap() {
    return {
      'contentType': contentType,
      'contentEncoding': contentEncoding,
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

  static ConsoleMessage? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ConsoleMessage(
      message: map["message"],
      messageLevel: ConsoleMessageLevel.fromValue(map["messageLevel"]) ??
          ConsoleMessageLevel.LOG,
    );
  }

  Map<String, dynamic> toMap() {
    return {"message": message, "messageLevel": messageLevel.toValue()};
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
  List<WebHistoryItem>? list;

  ///Index of the current [WebHistoryItem].
  int? currentIndex;

  WebHistory({this.list, this.currentIndex});

  static WebHistory? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    List<LinkedHashMap<dynamic, dynamic>>? historyListMap =
        map["history"]?.cast<LinkedHashMap<dynamic, dynamic>>();
    int currentIndex = map["currentIndex"];

    List<WebHistoryItem> historyList = <WebHistoryItem>[];
    if (historyListMap != null) {
      for (var i = 0; i < historyListMap.length; i++) {
        var historyItem = historyListMap[i];
        historyList.add(WebHistoryItem(
            originalUrl: historyItem["originalUrl"] != null
                ? Uri.tryParse(historyItem["originalUrl"])
                : null,
            title: historyItem["title"],
            url: historyItem["url"] != null
                ? Uri.tryParse(historyItem["url"])
                : null,
            index: i,
            offset: i - currentIndex));
      }
    }

    return WebHistory(list: historyList, currentIndex: currentIndex);
  }

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
  Uri? originalUrl;

  ///Document title of this history item.
  String? title;

  ///Url of this history item.
  Uri? url;

  ///0-based position index in the back-forward [WebHistory.list].
  int? index;

  ///Position offset respect to the currentIndex of the back-forward [WebHistory.list].
  int? offset;

  WebHistoryItem(
      {this.originalUrl, this.title, this.url, this.index, this.offset});

  Map<String, dynamic> toMap() {
    return {
      "originalUrl": originalUrl?.toString(),
      "title": title,
      "url": url?.toString(),
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
  String? origin;

  ///Whether or not the origin should be allowed to use the Geolocation API.
  bool? allow;

  ///Whether the permission should be retained beyond the lifetime of a page currently being displayed by a WebView
  bool? retain;

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
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosIsMainFrame;

  JsAlertRequest({this.url, this.message, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
      "iosIsMainFrame": iosIsMainFrame
    };
  }

  static JsAlertRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsAlertRequest(
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        message: map["message"],
        iosIsMainFrame: map["iosIsMainFrame"]);
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
  JsAlertResponseAction? action;

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
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosIsMainFrame;

  JsConfirmRequest({this.url, this.message, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
      "iosIsMainFrame": iosIsMainFrame
    };
  }

  static JsConfirmRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsConfirmRequest(
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        message: map["message"],
        iosIsMainFrame: map["iosIsMainFrame"]);
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
  JsConfirmResponseAction? action;

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
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  ///The default value displayed in the prompt dialog.
  String? defaultValue;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosIsMainFrame;

  JsPromptRequest(
      {this.url, this.message, this.defaultValue, this.iosIsMainFrame});

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "message": message,
      "defaultValue": defaultValue,
      "iosIsMainFrame": iosIsMainFrame
    };
  }

  static JsPromptRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsPromptRequest(
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        message: map["message"],
        defaultValue: map["defaultValue"],
        iosIsMainFrame: map["iosIsMainFrame"]);
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
  String? value;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsPromptResponseAction? action;

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
  Uri? url;

  ///Message to be displayed in the window.
  String? message;

  JsBeforeUnloadRequest({this.url, this.message});

  static JsBeforeUnloadRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return JsBeforeUnloadRequest(
      url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
      message: map["message"],
    );
  }

  Map<String, dynamic> toMap() {
    return {"url": url?.toString(), "message": message};
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
  JsBeforeUnloadResponseAction? action;

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

  static SafeBrowsingThreat? fromValue(int? value) {
    if (value != null) {
      try {
        return SafeBrowsingThreat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }

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
  SafeBrowsingResponseAction? action;

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
  HttpAuthResponseAction? action;

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

///An iOS-specific class that represents the constants that specify how long the credential will be kept.
class IOSURLCredentialPersistence {
  final int _value;

  const IOSURLCredentialPersistence._internal(this._value);

  static final Set<IOSURLCredentialPersistence> values = [
    IOSURLCredentialPersistence.NONE,
    IOSURLCredentialPersistence.FOR_SESSION,
    IOSURLCredentialPersistence.PERMANENT,
    IOSURLCredentialPersistence.SYNCHRONIZABLE,
  ].toSet();

  static IOSURLCredentialPersistence? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSURLCredentialPersistence.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  int toValue() => _value;

  String toString() {
    switch (_value) {
      case 1:
        return "FOR_SESSION";
      case 2:
        return "PERMANENT";
      case 3:
        return "SYNCHRONIZABLE";
      case 0:
      default:
        return "NONE";
    }
  }

  ///The credential should not be stored.
  static const NONE = const IOSURLCredentialPersistence._internal(0);

  ///The credential should be stored only for this session
  static const FOR_SESSION = const IOSURLCredentialPersistence._internal(1);

  ///The credential should be stored in the keychain.
  static const PERMANENT = const IOSURLCredentialPersistence._internal(2);

  ///The credential should be stored permanently in the keychain,
  ///and in addition should be distributed to other devices based on the owning Apple ID.
  static const SYNCHRONIZABLE = const IOSURLCredentialPersistence._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an authentication credential consisting of information
///specific to the type of credential and the type of persistent storage to use, if any.
class URLCredential {
  ///The credential’s user name.
  String? username;

  ///The credential’s password.
  String? password;

  ///The intermediate certificates of the credential, if it is a client certificate credential.
  ///
  ///**NOTE**: available only on iOS.
  List<X509Certificate>? iosCertificates;

  ///The credential’s persistence setting.
  ///
  ///**NOTE**: available only on iOS.
  IOSURLCredentialPersistence? iosPersistence;

  URLCredential(
      {this.username,
      this.password,
      this.iosPersistence,
      this.iosCertificates});

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "iosCertificates": iosCertificates?.map((e) => e.toMap()).toList(),
      "iosPersistence": iosPersistence?.toValue(),
    };
  }

  static URLCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    List<X509Certificate>? iosCertificates;
    if (map["iosCertificates"] != null) {
      iosCertificates = <X509Certificate>[];
      (map["iosCertificates"].cast<Uint8List>() as List<Uint8List>)
          .forEach((data) {
        try {
          iosCertificates!.add(X509Certificate.fromData(data: data));
        } catch (e, stacktrace) {
          print(e);
          print(stacktrace);
        }
      });
    }

    return URLCredential(
      username: map["username"],
      password: map["password"],
      iosCertificates: iosCertificates,
      iosPersistence:
          IOSURLCredentialPersistence.fromValue(map["iosPersistence"]),
    );
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a challenge from a server requiring authentication from the client.
///It provides all the information about the challenge.
class URLAuthenticationChallenge {
  ///The protection space requiring authentication.
  URLProtectionSpace protectionSpace;

  URLAuthenticationChallenge({
    required this.protectionSpace,
  });

  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace.toMap(),
    };
  }

  static URLAuthenticationChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return URLAuthenticationChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map["protectionSpace"].cast<String, dynamic>())!,
    );
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
class HttpAuthenticationChallenge extends URLAuthenticationChallenge {
  ///A count of previous failed authentication attempts.
  int previousFailureCount;

  ///The proposed credential for this challenge.
  ///This method returns `null` if there is no default credential for this challenge.
  ///If you have previously attempted to authenticate and failed, this method returns the most recent failed credential.
  ///If the proposed credential is not nil and returns true when you call its hasPassword method, then the credential is ready to use as-is.
  ///If the proposed credential’s hasPassword method returns false, then the credential provides a default user name,
  ///and the client must prompt the user for a corresponding password.
  URLCredential? proposedCredential;

  ///The URL response object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use responses to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  IOSURLResponse? iosFailureResponse;

  ///The error object representing the last authentication failure.
  ///This value is `null` if the protocol doesn’t use errors to indicate an authentication failure.
  ///
  ///**NOTE**: available only on iOS.
  String? iosError;

  HttpAuthenticationChallenge({
    required this.previousFailureCount,
    required URLProtectionSpace protectionSpace,
    this.iosFailureResponse,
    this.proposedCredential,
    this.iosError,
  }) : super(protectionSpace: protectionSpace);

  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      "previousFailureCount": previousFailureCount,
      "protectionSpace": protectionSpace.toMap(),
      "proposedCredential": proposedCredential?.toMap(),
      "iosFailureResponse": iosFailureResponse?.toMap(),
      "iosError": iosError,
    });
    return map;
  }

  static HttpAuthenticationChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return HttpAuthenticationChallenge(
      previousFailureCount: map["previousFailureCount"],
      protectionSpace: URLProtectionSpace.fromMap(
          map["protectionSpace"].cast<String, dynamic>())!,
      proposedCredential: URLCredential.fromMap(
          map["proposedCredential"]?.cast<String, dynamic>()),
      iosFailureResponse: IOSURLResponse.fromMap(
          map["iosFailureResponse"]?.cast<String, dynamic>()),
      iosError: map["iosError"],
    );
  }
}

///Class that represents the challenge of the [WebView.onReceivedServerTrustAuthRequest] event.
///It provides all the information about the challenge.
class ServerTrustChallenge extends URLAuthenticationChallenge {
  ServerTrustChallenge({required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace);

  static ServerTrustChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ServerTrustChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map["protectionSpace"].cast<String, dynamic>())!,
    );
  }
}

///Class that represents the challenge of the [WebView.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**NOTE**: available only on Android.
  List<String>? androidPrincipals;

  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**NOTE**: available only on Android.
  List<String>? androidKeyTypes;

  ClientCertChallenge(
      {required URLProtectionSpace protectionSpace,
      this.androidPrincipals,
      this.androidKeyTypes})
      : super(protectionSpace: protectionSpace);

  static ClientCertChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ClientCertChallenge(
        protectionSpace: URLProtectionSpace.fromMap(
            map["protectionSpace"].cast<String, dynamic>())!,
        androidPrincipals: map["androidPrincipals"]?.cast<String>(),
        androidKeyTypes: map["androidKeyTypes"]?.cast<String>());
  }
}

///An iOS-specific Class that represents the supported proxy types.
class IOSNSURLProtectionSpaceProxyType {
  final String _value;

  const IOSNSURLProtectionSpaceProxyType._internal(this._value);

  static final Set<IOSNSURLProtectionSpaceProxyType> values = [
    IOSNSURLProtectionSpaceProxyType.NSUR_PROTECTION_SPACE_HTTP_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_HTTPS_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_FTP_PROXY,
    IOSNSURLProtectionSpaceProxyType.NSURL_PROTECTION_SPACE_SOCKS_PROXY,
  ].toSet();

  static IOSNSURLProtectionSpaceProxyType? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceProxyType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///The proxy type for HTTP proxies.
  static const NSUR_PROTECTION_SPACE_HTTP_PROXY =
      const IOSNSURLProtectionSpaceProxyType._internal(
          "NSURLProtectionSpaceHTTPProxy");

  ///The proxy type for HTTPS proxies.
  static const NSURL_PROTECTION_SPACE_HTTPS_PROXY =
      const IOSNSURLProtectionSpaceProxyType._internal(
          "NSURLProtectionSpaceHTTPSProxy");

  ///The proxy type for FTP proxies.
  static const NSURL_PROTECTION_SPACE_FTP_PROXY =
      const IOSNSURLProtectionSpaceProxyType._internal(
          "NSURLProtectionSpaceFTPProxy");

  ///The proxy type for SOCKS proxies.
  static const NSURL_PROTECTION_SPACE_SOCKS_PROXY =
      const IOSNSURLProtectionSpaceProxyType._internal(
          "NSURLProtectionSpaceSOCKSProxy");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the constants describing known values of the [URLProtectionSpace.iosAuthenticationMethod] property.
class IOSNSURLProtectionSpaceAuthenticationMethod {
  final String _value;

  const IOSNSURLProtectionSpaceAuthenticationMethod._internal(this._value);

  static final Set<IOSNSURLProtectionSpaceAuthenticationMethod> values = [
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NEGOTIATE,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_NTLM,
    IOSNSURLProtectionSpaceAuthenticationMethod
        .NSURL_AUTHENTICATION_METHOD_SERVER_TRUST,
  ].toSet();

  static IOSNSURLProtectionSpaceAuthenticationMethod? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSURLProtectionSpaceAuthenticationMethod.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///Use client certificate authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_CLIENT_CERTIFICATE =
      const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          "NSURLAuthenticationMethodClientCertificate");

  ///Negotiate whether to use Kerberos or NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NEGOTIATE =
      const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          "NSURLAuthenticationMethodNegotiate");

  ///Use NTLM authentication for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_NTLM =
      const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          "NSURLAuthenticationMethodNTLM");

  ///Perform server trust authentication (certificate validation) for this protection space.
  static const NSURL_AUTHENTICATION_METHOD_SERVER_TRUST =
      const IOSNSURLProtectionSpaceAuthenticationMethod._internal(
          "NSURLAuthenticationMethodServerTrust");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents an SSL Error.
class SslError {
  ///Android-specific primary error associated to the server SSL certificate.
  AndroidSslError? androidError;

  ///iOS-specific primary error associated to the server SSL certificate.
  IOSSslError? iosError;

  ///The message associated to the [androidError]/[iosError].
  String? message;

  SslError({this.androidError, this.iosError, this.message});

  static SslError? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return SslError(
        androidError: AndroidSslError.fromValue(map["androidError"]),
        iosError: IOSSslError.fromValue(map["iosError"]),
        message: map["message"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "androidError": androidError?.toValue(),
      "iosError": iosError?.toValue(),
      "message": message,
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
class URLProtectionSpace {
  ///The hostname of the server.
  String host;

  ///The protocol of the server - e.g. "http", "ftp", "https".
  String? protocol;

  ///A string indicating a protocol-specific subdivision of a single host.
  ///For http and https, this maps to the realm string in http authentication challenges.
  ///For many other protocols it is unused.
  String? realm;

  ///The port of the server.
  int? port;

  ///The SSL certificate used.
  SslCertificate? sslCertificate;

  ///The SSL Error associated.
  SslError? sslError;

  ///The authentication method used by the receiver.
  ///
  ///**NOTE**: available only on iOS.
  IOSNSURLProtectionSpaceAuthenticationMethod? iosAuthenticationMethod;

  ///The acceptable certificate-issuing authorities for client certificate authentication.
  ///This value is `null` if the authentication method of the protection space is not client certificate.
  ///The returned issuing authorities are encoded with Distinguished Encoding Rules (DER).
  ///
  ///**NOTE**: available only on iOS.
  List<X509Certificate>? iosDistinguishedNames;

  ///A Boolean value that indicates whether the credentials for the protection space can be sent securely.
  ///This value is `true` if the credentials for the protection space represented by the receiver can be sent securely, `false` otherwise.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosReceivesCredentialSecurely;

  ///Returns a Boolean value that indicates whether the receiver does not descend from `NSObject`.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosIsProxy;

  ///The receiver's proxy type.
  ///This value is `null` if the receiver does not represent a proxy protection space.
  ///The supported proxy types are listed in [IOSNSURLProtectionSpaceProxyType.values].
  ///
  ///**NOTE**: available only on iOS.
  IOSNSURLProtectionSpaceProxyType? iosProxyType;

  URLProtectionSpace(
      {required this.host,
      this.protocol,
      this.realm,
      this.port,
      this.sslCertificate,
      this.sslError,
      this.iosAuthenticationMethod,
      this.iosDistinguishedNames,
      this.iosReceivesCredentialSecurely,
      this.iosIsProxy,
      this.iosProxyType});

  static URLProtectionSpace? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    List<X509Certificate>? iosDistinguishedNames;
    if (map["iosDistinguishedNames"] != null) {
      iosDistinguishedNames = <X509Certificate>[];
      (map["iosDistinguishedNames"].cast<Uint8List>() as List<Uint8List>)
          .forEach((data) {
        try {
          iosDistinguishedNames!.add(X509Certificate.fromData(data: data));
        } catch (e, stacktrace) {
          print(e);
          print(stacktrace);
        }
      });
    }

    return URLProtectionSpace(
      host: map["host"],
      protocol: map["protocol"],
      realm: map["realm"],
      port: map["port"],
      sslCertificate: SslCertificate.fromMap(
          map["sslCertificate"]?.cast<String, dynamic>()),
      sslError: SslError.fromMap(map["sslError"]?.cast<String, dynamic>()),
      iosAuthenticationMethod:
          IOSNSURLProtectionSpaceAuthenticationMethod.fromValue(
              map["iosAuthenticationMethod"]),
      iosDistinguishedNames: iosDistinguishedNames,
      iosReceivesCredentialSecurely: map["iosReceivesCredentialSecurely"],
      iosIsProxy: map["iosIsProxy"],
      iosProxyType:
          IOSNSURLProtectionSpaceProxyType.fromValue(map["iosProxyType"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "host": host,
      "protocol": protocol,
      "realm": realm,
      "port": port,
      "sslCertificate": sslCertificate?.toMap(),
      "sslError": sslError?.toMap(),
      "iosAuthenticationMethod": iosAuthenticationMethod,
      "iosDistinguishedNames":
          iosDistinguishedNames?.map((e) => e.toMap()).toList(),
      "iosReceivesCredentialSecurely": iosReceivesCredentialSecurely,
      "iosIsProxy": iosIsProxy,
      "iosProxyType": iosProxyType?.toValue()
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

///Class that represents a [URLProtectionSpace] with all of its [HttpAuthCredential]s.
///It used by [HttpAuthCredentialDatabase.getAllAuthCredentials].
class URLProtectionSpaceHttpAuthCredentials {
  ///The protection space.
  URLProtectionSpace? protectionSpace;

  ///The list of all its http authentication credentials.
  List<URLCredential>? credentials;

  URLProtectionSpaceHttpAuthCredentials(
      {this.protectionSpace, this.credentials});

  static URLProtectionSpaceHttpAuthCredentials? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    List<URLCredential>? credentials;
    if (map["credentials"] != null) {
      credentials = <URLCredential>[];
      (map["credentials"].cast<Map<String, dynamic>>()
              as List<Map<String, dynamic>>)
          .forEach((element) {
        var credential = URLCredential.fromMap(element);
        if (credential != null) {
          credentials!.add(credential);
        }
      });
    }

    return URLProtectionSpaceHttpAuthCredentials(
      protectionSpace: map["protectionSpace"] != null
          ? URLProtectionSpace.fromMap(
              map["protectionSpace"]?.cast<String, dynamic>())
          : null,
      credentials: credentials,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "protectionSpace": protectionSpace?.toMap(),
      "credentials": credentials != null
          ? credentials!.map((credential) => credential.toMap()).toList()
          : null
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
  ServerTrustAuthResponseAction? action;

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
  String? certificatePassword;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  String? androidKeyStoreType;

  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction? action;

  ClientCertResponse(
      {required this.certificatePath,
      this.certificatePassword = "",
      this.androidKeyStoreType = "PKCS12",
      this.action = ClientCertResponseAction.CANCEL}) {
    if (this.action == ClientCertResponseAction.PROCEED)
      assert(certificatePath.isNotEmpty);
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

///Class that represents a favicon of a website. It is used by [InAppWebViewController.getFavicons] method.
class Favicon {
  ///The url of the favicon image.
  Uri url;

  ///The relationship between the current web page and the favicon image.
  String? rel;

  ///The width of the favicon image.
  int? width;

  ///The height of the favicon image.
  int? height;

  Favicon({required this.url, this.rel, this.width, this.height});

  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "rel": rel,
      "width": width,
      "height": height
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

///An Android-specific class used to override the way the cache is used.
class AndroidCacheMode {
  final int _value;

  const AndroidCacheMode._internal(this._value);

  static final Set<AndroidCacheMode> values = [
    AndroidCacheMode.LOAD_DEFAULT,
    AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
    AndroidCacheMode.LOAD_NO_CACHE,
    AndroidCacheMode.LOAD_CACHE_ONLY,
  ].toSet();

  static AndroidCacheMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidCacheMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An Android-specific class used to disable the action mode menu items.
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

  static AndroidActionModeMenuItem? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidActionModeMenuItem.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        // maybe coming from a Bitwise OR operator
        return AndroidActionModeMenuItem._internal(value);
      }
    }
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
        return "MENU_ITEM_NONE";
    }
    return _value.toString();
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

  AndroidActionModeMenuItem operator |(AndroidActionModeMenuItem value) =>
      AndroidActionModeMenuItem._internal(value.toValue() | _value);

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to indicate the force dark mode.
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

  static AndroidForceDark? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidForceDark.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An Android-specific class used to set the underlying layout algorithm.
class AndroidLayoutAlgorithm {
  final String _value;

  const AndroidLayoutAlgorithm._internal(this._value);

  static final Set<AndroidLayoutAlgorithm> values = [
    AndroidLayoutAlgorithm.NORMAL,
    AndroidLayoutAlgorithm.TEXT_AUTOSIZING,
    AndroidLayoutAlgorithm.NARROW_COLUMNS,
  ].toSet();

  static AndroidLayoutAlgorithm? fromValue(String? value) {
    if (value != null) {
      try {
        return AndroidLayoutAlgorithm.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An Android-specific class used to configure the WebView's behavior when a secure origin attempts to load a resource from an insecure origin.
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

  static AndroidMixedContentMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidMixedContentMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to set the level of granularity with which the user can interactively select content in the web view.
class IOSWKSelectionGranularity {
  final int _value;

  const IOSWKSelectionGranularity._internal(this._value);

  static final Set<IOSWKSelectionGranularity> values = [
    IOSWKSelectionGranularity.DYNAMIC,
    IOSWKSelectionGranularity.CHARACTER,
  ].toSet();

  static IOSWKSelectionGranularity? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKSelectionGranularity.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to specify a `dataDetectoryTypes` value that adds interactivity to web content that matches the value.
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

  static IOSWKDataDetectorTypes? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSWKDataDetectorTypes.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static IOSUIScrollViewDecelerationRate? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewDecelerationRate.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static UserPreferredContentMode? fromValue(int? value) {
    if (value != null) {
      try {
        return UserPreferredContentMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to specify the modal presentation style when presenting a view controller.
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

  static IOSUIModalPresentationStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalPresentationStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to specify the transition style when presenting a view controller.
class IOSUIModalTransitionStyle {
  final int _value;

  const IOSUIModalTransitionStyle._internal(this._value);

  static final Set<IOSUIModalTransitionStyle> values = [
    IOSUIModalTransitionStyle.COVER_VERTICAL,
    IOSUIModalTransitionStyle.FLIP_HORIZONTAL,
    IOSUIModalTransitionStyle.CROSS_DISSOLVE,
    IOSUIModalTransitionStyle.PARTIAL_CURL,
  ].toSet();

  static IOSUIModalTransitionStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIModalTransitionStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to set the custom style for the dismiss button.
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

  static IOSSafariDismissButtonStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSSafariDismissButtonStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static AjaxRequestEventType? fromValue(String? value) {
    if (value != null) {
      try {
        return AjaxRequestEventType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  AjaxRequestEventType? type;

  ///Is a Boolean flag indicating if the total work to be done, and the amount of work already done, by the underlying process is calculable.
  ///In other words, it tells if the progress is measurable or not.
  bool? lengthComputable;

  ///Is an integer representing the amount of work already performed by the underlying process.
  ///The ratio of work done can be calculated with the property and [AjaxRequestEvent.total].
  ///When downloading a resource using HTTP, this only represent the part of the content itself, not headers and other overhead.
  int? loaded;

  ///Is an integer representing the total amount of work that the underlying process is in the progress of performing.
  ///When downloading a resource using HTTP, this only represent the content itself, not headers and other overhead.
  int? total;

  AjaxRequestEvent({this.type, this.lengthComputable, this.loaded, this.total});

  static AjaxRequestEvent? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return AjaxRequestEvent(
        type: AjaxRequestEventType.fromValue(map["type"]),
        lengthComputable: map["lengthComputable"],
        loaded: map["loaded"],
        total: map["total"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "type": type?.toValue(),
      "lengthComputable": lengthComputable,
      "loaded": loaded,
      "total": total,
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

  static AjaxRequestReadyState? fromValue(int? value) {
    if (value != null) {
      try {
        return AjaxRequestReadyState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  Map<String, dynamic> _headers;
  Map<String, dynamic> _newHeaders = {};

  AjaxRequestHeaders(this._headers);

  static AjaxRequestHeaders? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return AjaxRequestHeaders(map);
  }

  ///Gets the HTTP headers of the [AjaxRequest].
  Map<String, dynamic> getHeaders() {
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

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents a JavaScript [XMLHttpRequest](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) object.
class AjaxRequest {
  ///Data passed as a parameter to the `XMLHttpRequest.send()` method.
  dynamic data;

  ///The HTTP request method of the `XMLHttpRequest` request.
  String? method;

  ///The URL of the `XMLHttpRequest` request.
  Uri? url;

  ///An optional Boolean parameter, defaulting to true, indicating whether or not the request is performed asynchronously.
  bool? isAsync;

  ///The optional user name to use for authentication purposes; by default, this is the null value.
  String? user;

  ///The optional password to use for authentication purposes; by default, this is the null value.
  String? password;

  ///The XMLHttpRequest.withCredentials property is a Boolean that indicates whether or not cross-site Access-Control requests
  ///should be made using credentials such as cookies, authorization headers or TLS client certificates.
  ///Setting withCredentials has no effect on same-site requests.
  ///In addition, this flag is also used to indicate when cookies are to be ignored in the response. The default is false.
  bool? withCredentials;

  ///The HTTP request headers.
  AjaxRequestHeaders? headers;

  ///The state of the `XMLHttpRequest` request.
  AjaxRequestReadyState? readyState;

  ///The numerical HTTP [status code](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) of the `XMLHttpRequest`'s response.
  int? status;

  ///The serialized URL of the response or the empty string if the URL is null.
  ///If the URL is returned, any URL fragment present in the URL will be stripped away.
  ///The value of responseURL will be the final URL obtained after any redirects.
  Uri? responseURL;

  ///It is an enumerated string value specifying the type of data contained in the response.
  ///It also lets the author change the [response type](https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/responseType).
  ///If an empty string is set as the value of responseType, the default value of text is used.
  String? responseType;

  ///The response's body content. The content-type depends on the [AjaxRequest.reponseType].
  dynamic response;

  ///The text received from a server following a request being sent.
  String? responseText;

  ///The HTML or XML string retrieved by the request or null if the request was unsuccessful, has not yet been sent, or if the data can't be parsed as XML or HTML.
  String? responseXML;

  ///A String containing the response's status message as returned by the HTTP server.
  ///Unlike [AjaxRequest.status] which indicates a numerical status code, this property contains the text of the response status, such as "OK" or "Not Found".
  ///If the request's readyState is in [AjaxRequestReadyState.UNSENT] or [AjaxRequestReadyState.OPENED] state, the value of statusText will be an empty string.
  ///If the server response doesn't explicitly specify a status text, statusText will assume the default value "OK".
  String? statusText;

  ///All the response headers or returns null if no response has been received. If a network error happened, an empty string is returned.
  Map<String, dynamic>? responseHeaders;

  ///Event type of the `XMLHttpRequest` request.
  AjaxRequestEvent? event;

  ///Indicates the [AjaxRequestAction] that can be used to control the `XMLHttpRequest` request.
  AjaxRequestAction? action;

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

  static AjaxRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return AjaxRequest(
        data: map["data"],
        method: map["method"],
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        isAsync: map["isAsync"],
        user: map["user"],
        password: map["password"],
        withCredentials: map["withCredentials"],
        headers:
            AjaxRequestHeaders.fromMap(map["headers"]?.cast<String, dynamic>()),
        readyState: AjaxRequestReadyState.fromValue(map["readyState"]),
        status: map["status"],
        responseURL: map["responseURL"] != null
            ? Uri.tryParse(map["responseURL"])
            : null,
        responseType: map["responseType"],
        response: map["response"],
        responseText: map["responseText"],
        responseXML: map["responseXML"],
        statusText: map["statusText"],
        responseHeaders: map["responseHeaders"]?.cast<String, dynamic>(),
        event: AjaxRequestEvent.fromMap(map["event"]?.cast<String, dynamic>()));
  }

  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "method": method,
      "url": url?.toString(),
      "isAsync": isAsync,
      "user": user,
      "password": password,
      "withCredentials": withCredentials,
      "headers": headers?.toMap(),
      "readyState": readyState?.toValue(),
      "status": status,
      "responseURL": responseURL?.toString(),
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
  String? type;

  FetchRequestCredential({this.type});

  Map<String, dynamic> toMap() {
    return {"type": type};
  }

  static FetchRequestCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return FetchRequestCredential(type: map["type"]);
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
  String? value;

  FetchRequestCredentialDefault({type, this.value}) : super(type: type);

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "value": value,
    };
  }

  static FetchRequestCredentialDefault? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestCredentialDefault(
        type: credentialsMap["type"], value: credentialsMap["value"]);
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
  String? name;

  ///Credential's federated identity protocol.
  String? protocol;

  ///Credential's federated identity provider.
  String? provider;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  Uri? iconURL;

  FetchRequestFederatedCredential(
      {type, this.id, this.name, this.protocol, this.provider, this.iconURL})
      : super(type: type);

  static FetchRequestFederatedCredential? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestFederatedCredential(
        type: credentialsMap["type"],
        id: credentialsMap["id"],
        name: credentialsMap["name"],
        protocol: credentialsMap["protocol"],
        provider: credentialsMap["provider"],
        iconURL: credentialsMap["iconURL"] != null
            ? Uri.tryParse(credentialsMap["iconURL"])
            : null);
  }

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "protocol": protocol,
      "provider": provider,
      "iconURL": iconURL?.toString()
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
  String? name;

  ///The password of the credential.
  String? password;

  ///URL pointing to an image for an icon. This image is intended for display in a credential chooser. The URL must be accessible without authentication.
  Uri? iconURL;

  FetchRequestPasswordCredential(
      {type, this.id, this.name, this.password, this.iconURL})
      : super(type: type);

  static FetchRequestPasswordCredential? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestPasswordCredential(
        type: credentialsMap["type"],
        id: credentialsMap["id"],
        name: credentialsMap["name"],
        password: credentialsMap["password"],
        iconURL: credentialsMap["iconURL"] != null
            ? Uri.tryParse(credentialsMap["iconURL"])
            : null);
  }

  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "id": id,
      "name": name,
      "password": password,
      "iconURL": iconURL?.toString()
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
  Uri? url;

  ///The HTTP request method used of the request.
  String? method;

  ///The HTTP request headers.
  Map<String, dynamic>? headers;

  ///Body of the request.
  dynamic body;

  ///The mode used by the request.
  String? mode;

  ///The request credentials used by the request.
  FetchRequestCredential? credentials;

  ///The cache mode used by the request.
  String? cache;

  ///The redirect mode used by the request.
  String? redirect;

  ///A String specifying no-referrer, client, or a URL.
  String? referrer;

  ///The value of the referer HTTP header.
  ReferrerPolicy? referrerPolicy;

  ///Contains the subresource integrity value of the request.
  String? integrity;

  ///The keepalive option used to allow the request to outlive the page.
  bool? keepalive;

  ///Indicates the [FetchRequestAction] that can be used to control the request.
  FetchRequestAction? action;

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

  static FetchRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    Map<String, dynamic>? credentialMap =
        map["credentials"]?.cast<String, dynamic>();
    FetchRequestCredential? credentials;
    if (credentialMap != null) {
      if (credentialMap["type"] == "default") {
        credentials = FetchRequestCredentialDefault.fromMap(credentialMap);
      } else if (credentialMap["type"] == "federated") {
        credentials = FetchRequestFederatedCredential.fromMap(credentialMap);
      } else if (credentialMap["type"] == "password") {
        credentials = FetchRequestPasswordCredential.fromMap(credentialMap);
      }
    }

    return FetchRequest(
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        method: map["method"],
        headers: map["headers"]?.cast<String, dynamic>(),
        body: map["body"],
        mode: map["mode"],
        credentials: credentials,
        cache: map["cache"],
        redirect: map["redirect"],
        referrer: map["referrer"],
        referrerPolicy: ReferrerPolicy.fromValue(map["referrerPolicy"]),
        integrity: map["integrity"],
        keepalive: map["keepalive"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "method": method,
      "headers": headers,
      "body": body,
      "mode": mode,
      "credentials": credentials?.toMap(),
      "cache": cache,
      "redirect": redirect,
      "referrer": referrer,
      "referrerPolicy": referrerPolicy?.toValue(),
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

  static ContentBlockerTriggerResourceType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerResourceType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static ContentBlockerTriggerLoadType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerTriggerLoadType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static ContentBlockerActionType? fromValue(String? value) {
    if (value != null) {
      try {
        return ContentBlockerActionType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  int? expiresDate;

  ///Indicates if the cookie is a session only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSessionOnly;

  ///The cookie domain.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? domain;

  ///The cookie same site policy.
  ///
  ///**NOTE**: on Android it will be always `null`.
  HTTPCookieSameSitePolicy? sameSite;

  ///Indicates if the cookie is secure or not.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isSecure;

  ///Indicates if the cookie is a http only cookie.
  ///
  ///**NOTE**: on Android it will be always `null`.
  bool? isHttpOnly;

  ///The cookie path.
  ///
  ///**NOTE**: on Android it will be always `null`.
  String? path;

  Cookie(
      {required this.name,
      required this.value,
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
  PermissionRequestResponseAction? action;

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
class NavigationActionPolicy {
  final int _value;

  const NavigationActionPolicy._internal(this._value);

  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const NavigationActionPolicy._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationActionPolicy._internal(1);

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

  static IOSWKNavigationType? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWKNavigationType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "LINK_ACTIVATED";
      case 1:
        return "FORM_SUBMITTED";
      case 2:
        return "BACK_FORWARD";
      case 3:
        return "RELOAD";
      case 4:
        return "FORM_RESUBMITTED";
      case -1:
      default:
        return "OTHER";
    }
  }
}

///An iOS-specific Class that represents the constants used to specify interaction with the cached responses.
class IOSURLRequestCachePolicy {
  final int _value;

  const IOSURLRequestCachePolicy._internal(this._value);

  static final Set<IOSURLRequestCachePolicy> values = [
    IOSURLRequestCachePolicy.USE_PROTOCOL_CACHE_POLICY,
    IOSURLRequestCachePolicy.RELOAD_IGNORING_LOCAL_CACHE_DATA,
    IOSURLRequestCachePolicy.RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA,
    IOSURLRequestCachePolicy.RETURN_CACHE_DATA_ELSE_LOAD,
    IOSURLRequestCachePolicy.RETURN_CACHE_DATA_DONT_LOAD,
    IOSURLRequestCachePolicy.RELOAD_REVALIDATING_CACHE_DATA,
  ].toSet();

  static IOSURLRequestCachePolicy? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSURLRequestCachePolicy.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "RELOAD_IGNORING_LOCAL_CACHE_DATA";
      case 2:
        return "RETURN_CACHE_DATA_ELSE_LOAD";
      case 3:
        return "RETURN_CACHE_DATA_DONT_LOAD";
      case 4:
        return "RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA";
      case 5:
        return "RELOAD_REVALIDATING_CACHE_DATA";
      case 0:
      default:
        return "USE_PROTOCOL_CACHE_POLICY";
    }
  }

  ///Use the caching logic defined in the protocol implementation, if any, for a particular URL load request.
  ///This is the default policy for URL load requests.
  static const USE_PROTOCOL_CACHE_POLICY =
      const IOSURLRequestCachePolicy._internal(0);

  ///The URL load should be loaded only from the originating source.
  ///This policy specifies that no existing cache data should be used to satisfy a URL load request.
  ///
  ///**NOTE**: Always use this policy if you are making HTTP or HTTPS byte-range requests.
  static const RELOAD_IGNORING_LOCAL_CACHE_DATA =
      const IOSURLRequestCachePolicy._internal(1);

  ///Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data.
  static const RETURN_CACHE_DATA_ELSE_LOAD =
      const IOSURLRequestCachePolicy._internal(2);

  ///Use existing cache data, regardless or age or expiration date, and fail if no cached data is available.
  ///
  ///If there is no existing data in the cache corresponding to a URL load request,
  ///no attempt is made to load the data from the originating source, and the load is considered to have failed.
  ///This constant specifies a behavior that is similar to an “offline” mode.
  static const RETURN_CACHE_DATA_DONT_LOAD =
      const IOSURLRequestCachePolicy._internal(3);

  ///Ignore local cache data, and instruct proxies and other intermediates to disregard their caches so far as the protocol allows.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA =
      const IOSURLRequestCachePolicy._internal(4);

  ///Use cache data if the origin source can validate it; otherwise, load from the origin.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_REVALIDATING_CACHE_DATA =
      const IOSURLRequestCachePolicy._internal(5);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the constants that specify how a request uses network resources.
class IOSURLRequestNetworkServiceType {
  final int _value;

  const IOSURLRequestNetworkServiceType._internal(this._value);

  static final Set<IOSURLRequestNetworkServiceType> values = [
    IOSURLRequestNetworkServiceType.DEFAULT,
    IOSURLRequestNetworkServiceType.VIDEO,
    IOSURLRequestNetworkServiceType.BACKGROUND,
    IOSURLRequestNetworkServiceType.VOICE,
    IOSURLRequestNetworkServiceType.RESPONSIVE_DATA,
    IOSURLRequestNetworkServiceType.AV_STREAMING,
    IOSURLRequestNetworkServiceType.RESPONSIVE_AV,
    IOSURLRequestNetworkServiceType.CALL_SIGNALING,
  ].toSet();

  static IOSURLRequestNetworkServiceType? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSURLRequestNetworkServiceType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 2:
        return "VIDEO";
      case 3:
        return "BACKGROUND";
      case 4:
        return "VOICE";
      case 6:
        return "RESPONSIVE_DATA";
      case 8:
        return "AV_STREAMING";
      case 9:
        return "RESPONSIVE_AV";
      case 11:
        return "CALL_SIGNALING";
      case 0:
      default:
        return "DEFAULT";
    }
  }

  ///A service type for standard network traffic.
  static const DEFAULT = const IOSURLRequestNetworkServiceType._internal(0);

  ///A service type for video traffic.
  static const VIDEO = const IOSURLRequestNetworkServiceType._internal(2);

  ///A service type for background traffic.
  ///
  ///You should specify this type if your app is performing a download that was not requested by the user—for example,
  ///prefetching content so that it will be available when the user chooses to view it.
  static const BACKGROUND = const IOSURLRequestNetworkServiceType._internal(3);

  ///A service type for voice traffic.
  static const VOICE = const IOSURLRequestNetworkServiceType._internal(4);

  ///A service type for data that the user is actively waiting for.
  ///
  ///Use this service type for interactive situations where the user is anticipating a quick response, like instant messaging or completing a purchase.
  static const RESPONSIVE_DATA =
      const IOSURLRequestNetworkServiceType._internal(6);

  ///A service type for streaming audio/video data.
  static const AV_STREAMING =
      const IOSURLRequestNetworkServiceType._internal(8);

  ///A service type for responsive (time-sensitive) audio/video data.
  static const RESPONSIVE_AV =
      const IOSURLRequestNetworkServiceType._internal(9);

  ///A service type for call signaling.
  ///
  ///Use this service type with network traffic that establishes, maintains, or tears down a VoIP call.
  static const CALL_SIGNALING =
      const IOSURLRequestNetworkServiceType._internal(11);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An object that identifies the origin of a particular resource.
///
///**NOTE**: available only on iOS 9.0+.
class IOSWKSecurityOrigin {
  ///The security origin’s host.
  String host;

  ///The security origin's port.
  int port;

  ///The security origin's protocol.
  String protocol;

  IOSWKSecurityOrigin(
      {required this.host, required this.port, required this.protocol});

  static IOSWKSecurityOrigin? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKSecurityOrigin(
        host: map["host"], port: map["port"], protocol: map["protocol"]);
  }

  Map<String, dynamic> toMap() {
    return {"host": host, "port": port, "protocol": protocol};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///An object that contains information about a frame on a webpage.
///
///**NOTE**: available only on iOS.
class IOSWKFrameInfo {
  ///A Boolean value indicating whether the frame is the web site's main frame or a subframe.
  bool isMainFrame;

  ///The frame’s current request.
  URLRequest? request;

  ///The frame’s security origin.
  IOSWKSecurityOrigin? securityOrigin;

  IOSWKFrameInfo(
      {required this.isMainFrame, required this.request, this.securityOrigin});

  static IOSWKFrameInfo? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKFrameInfo(
        isMainFrame: map["isMainFrame"],
        request: URLRequest.fromMap(map["request"]?.cast<String, dynamic>()),
        securityOrigin: IOSWKSecurityOrigin.fromMap(
            map["securityOrigin"]?.cast<String, dynamic>()));
  }

  Map<String, dynamic> toMap() {
    return {
      "isMainFrame": isMainFrame,
      "request": request?.toMap(),
      "securityOrigin": securityOrigin?.toMap()
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

///An object that contains information about an action that causes navigation to occur.
class NavigationAction {
  ///The URL request object associated with the navigation action.
  ///
  ///**NOTE for Android**: If the request is associated to the [WebView.onCreateWindow] event
  ///and the window has been created using JavaScript, [request.url] will be `null`,
  ///the [request.method] is always `GET`, and [request.headers] value is always `null`.
  ///Also, on Android < 21, the [request.method]  is always `GET` and [request.headers] value is always `null`.
  URLRequest request;

  ///Indicates whether the request was made for the main frame.
  ///
  ///**NOTE for Android**: If the request is associated to the [WebView.onCreateWindow] event, this is always `true`.
  ///Also, on Android < 21, this is always `true`.
  bool isForMainFrame;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: available only on Android. On Android < 24, this is always `false`.
  bool? androidHasGesture;

  ///Gets whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: available only on Android.
  ///If the request is associated to the [WebView.onCreateWindow] event, this is always `false`.
  ///Also, on Android < 21, this is always `false`.
  bool? androidIsRedirect;

  ///The type of action triggering the navigation.
  ///
  ///**NOTE**: available only on iOS.
  IOSWKNavigationType? iosWKNavigationType;

  ///The frame that requested the navigation.
  ///
  ///**NOTE**: available only on iOS.
  IOSWKFrameInfo? iosSourceFrame;

  ///The frame in which to display the new content.
  ///
  ///**NOTE**: available only on iOS.
  IOSWKFrameInfo? iosTargetFrame;

  NavigationAction(
      {required this.request,
      required this.isForMainFrame,
      this.androidHasGesture,
      this.androidIsRedirect,
      this.iosWKNavigationType,
      this.iosSourceFrame,
      this.iosTargetFrame});

  static NavigationAction? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return NavigationAction(
        request: URLRequest.fromMap(map["request"].cast<String, dynamic>())!,
        isForMainFrame: map["isForMainFrame"],
        androidHasGesture: map["androidHasGesture"],
        androidIsRedirect: map["androidIsRedirect"],
        iosWKNavigationType:
            IOSWKNavigationType.fromValue(map["iosWKNavigationType"]),
        iosSourceFrame: IOSWKFrameInfo.fromMap(
            map["iosSourceFrame"]?.cast<String, dynamic>()),
        iosTargetFrame: IOSWKFrameInfo.fromMap(
            map["iosTargetFrame"]?.cast<String, dynamic>()));
  }

  Map<String, dynamic> toMap() {
    return {
      "request": request.toMap(),
      "isForMainFrame": isForMainFrame,
      "androidHasGesture": androidHasGesture,
      "androidIsRedirect": androidIsRedirect,
      "iosWKNavigationType": iosWKNavigationType?.toValue(),
      "iosSourceFrame": iosSourceFrame?.toMap(),
      "iosTargetFrame": iosTargetFrame?.toMap(),
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
class CreateWindowAction extends NavigationAction {
  ///The window id. Used by [WebView] to create a new WebView.
  int windowId;

  ///Indicates if the new window should be a dialog, rather than a full-size window.
  ///
  ///**NOTE**: available only on Android.
  bool? androidIsDialog;

  ///Window features requested by the webpage.
  ///
  ///**NOTE**: available only on iOS.
  IOSWKWindowFeatures? iosWindowFeatures;

  CreateWindowAction(
      {required this.windowId,
      this.androidIsDialog,
      this.iosWindowFeatures,
      required URLRequest request,
      required bool isForMainFrame,
      bool? androidHasGesture,
      bool? androidIsRedirect,
      IOSWKNavigationType? iosWKNavigationType,
      IOSWKFrameInfo? iosSourceFrame,
      IOSWKFrameInfo? iosTargetFrame})
      : super(
            request: request,
            isForMainFrame: isForMainFrame,
            androidHasGesture: androidHasGesture,
            androidIsRedirect: androidIsRedirect,
            iosWKNavigationType: iosWKNavigationType,
            iosSourceFrame: iosSourceFrame,
            iosTargetFrame: iosTargetFrame);

  static CreateWindowAction? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return CreateWindowAction(
        windowId: map["windowId"],
        androidIsDialog: map["androidIsDialog"],
        iosWindowFeatures: IOSWKWindowFeatures.fromMap(
            map["iosWindowFeatures"]?.cast<String, dynamic>()),
        request: URLRequest.fromMap(map["request"].cast<String, dynamic>())!,
        isForMainFrame: map["isForMainFrame"],
        androidHasGesture: map["androidHasGesture"],
        androidIsRedirect: map["androidIsRedirect"],
        iosWKNavigationType:
            IOSWKNavigationType.fromValue(map["iosWKNavigationType"]),
        iosSourceFrame: IOSWKFrameInfo.fromMap(
            map["iosSourceFrame"]?.cast<String, dynamic>()),
        iosTargetFrame: IOSWKFrameInfo.fromMap(
            map["iosTargetFrame"]?.cast<String, dynamic>()));
  }

  @override
  Map<String, dynamic> toMap() {
    var createWindowActionMap = super.toMap();
    createWindowActionMap.addAll({
      "windowId": windowId,
      "androidIsDialog": androidIsDialog,
      "iosWindowFeatures": iosWindowFeatures?.toMap(),
    });
    return createWindowActionMap;
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
  String? origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int? quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int? usage;

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

  static IOSWKWebsiteDataType? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSWKWebsiteDataType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType>? dataTypes;

  IOSWKWebsiteDataRecord({this.displayName, this.dataTypes});

  Map<String, dynamic> toMap() {
    List<String> dataTypesString = [];
    if (dataTypes != null) {
      for (var dataType in dataTypes!) {
        dataTypesString.add(dataType.toValue());
      }
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

  static InAppWebViewHitTestResultType? fromValue(int? value) {
    if (value != null) {
      try {
        return InAppWebViewHitTestResultType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  InAppWebViewHitTestResultType? type;

  ///Additional type-dependant information about the result.
  String? extra;

  InAppWebViewHitTestResult({this.type, this.extra});

  Map<String, dynamic> toMap() {
    return {"type": type?.toValue(), "extra": extra};
  }

  static InAppWebViewHitTestResult? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return InAppWebViewHitTestResult(
        type: InAppWebViewHitTestResultType.fromValue(map["type"]),
        extra: map["extra"]);
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
  RendererPriority? rendererPriorityAtExit;

  RenderProcessGoneDetail(
      {required this.didCrash, this.rendererPriorityAtExit});

  static RenderProcessGoneDetail? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return RenderProcessGoneDetail(
      didCrash: map["didCrash"],
      rendererPriorityAtExit:
          RendererPriority.fromValue(map["rendererPriorityAtExit"]),
    );
  }

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

  static RendererPriority? fromValue(int? value) {
    if (value != null) {
      try {
        return RendererPriority.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  RendererPriority? rendererRequestedPriority;

  ///If true, this flag specifies that when this WebView is not visible, it will be treated as if it had requested a priority of [RendererPriority.RENDERER_PRIORITY_WAIVED].
  bool waivedWhenNotVisible;

  RendererPriorityPolicy(
      {required this.rendererRequestedPriority,
      required this.waivedWhenNotVisible});

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

  static RendererPriorityPolicy? fromMap(Map<String, dynamic>? map) {
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

///An Android-specific class used to configure the WebView's over-scroll mode.
///Setting the over-scroll mode of a WebView will have an effect only if the WebView is capable of scrolling.
class AndroidOverScrollMode {
  final int _value;

  const AndroidOverScrollMode._internal(this._value);

  static final Set<AndroidOverScrollMode> values = [
    AndroidOverScrollMode.OVER_SCROLL_ALWAYS,
    AndroidOverScrollMode.OVER_SCROLL_IF_CONTENT_SCROLLS,
    AndroidOverScrollMode.OVER_SCROLL_NEVER,
  ].toSet();

  static AndroidOverScrollMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidOverScrollMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An Android-specific class used to configure the style of the scrollbars.
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

  static AndroidScrollBarStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidScrollBarStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An Android-specific class used to configure the position of the vertical scroll bar.
class AndroidVerticalScrollbarPosition {
  final int _value;

  const AndroidVerticalScrollbarPosition._internal(this._value);

  static final Set<AndroidVerticalScrollbarPosition> values = [
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_DEFAULT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_LEFT,
    AndroidVerticalScrollbarPosition.SCROLLBAR_POSITION_RIGHT,
  ].toSet();

  static AndroidVerticalScrollbarPosition? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidVerticalScrollbarPosition.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  String? versionName;

  ///The name of this WebView package.
  String? packageName;

  AndroidWebViewPackageInfo({this.versionName, this.packageName});

  static AndroidWebViewPackageInfo? fromMap(Map<String, dynamic>? map) {
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
  Uri? url;

  ///The anchor's text.
  String? title;

  ///The image's src attribute.
  String? src;

  RequestFocusNodeHrefResult({this.url, this.title, this.src});

  Map<String, dynamic> toMap() {
    return {"url": url?.toString(), "title": title, "src": src};
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
  Uri? url;

  RequestImageRefResult({this.url});

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
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
  String? name;

  ///The meta tag content value.
  String? content;

  ///The meta tag attributes list.
  List<MetaTagAttribute>? attrs;

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
  String? name;

  ///The attribute value.
  String? value;

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

  static WebStorageType? fromValue(String? value) {
    if (value != null) {
      try {
        return WebStorageType.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static HTTPCookieSameSitePolicy? fromValue(String? value) {
    if (value != null) {
      try {
        return HTTPCookieSameSitePolicy.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static AndroidSslError? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidSslError.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

  static IOSSslError? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSSslError.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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

///An iOS-specific class used to configure how safe area insets are added to the adjusted content inset.
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

  static IOSUIScrollViewContentInsetAdjustmentBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSUIScrollViewContentInsetAdjustmentBehavior.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
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
  ///Name of the entity this certificate is issued by.
  SslCertificateDName? issuedBy;

  ///Name of the entity this certificate is issued to.
  SslCertificateDName? issuedTo;

  ///Not-after date from the validity period.
  DateTime? validNotAfterDate;

  ///Not-before date from the validity period.
  DateTime? validNotBeforeDate;

  ///The original source certificate, if available.
  X509Certificate? x509Certificate;

  SslCertificate(
      {this.issuedBy,
      this.issuedTo,
      this.validNotAfterDate,
      this.validNotBeforeDate,
      this.x509Certificate});

  static SslCertificate? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    X509Certificate? x509Certificate;
    try {
      x509Certificate = X509Certificate.fromData(data: map["x509Certificate"]);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (x509Certificate != null) {
        return SslCertificate(
          issuedBy: SslCertificateDName(
              CName: x509Certificate.issuer(
                      dn: ASN1DistinguishedNames.COMMON_NAME) ??
                  "",
              DName: x509Certificate.issuerDistinguishedName ?? "",
              OName: x509Certificate.issuer(
                      dn: ASN1DistinguishedNames.ORGANIZATION_NAME) ??
                  "",
              UName: x509Certificate.issuer(
                      dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME) ??
                  ""),
          issuedTo: SslCertificateDName(
              CName: x509Certificate.subject(
                      dn: ASN1DistinguishedNames.COMMON_NAME) ??
                  "",
              DName: x509Certificate.subjectDistinguishedName ?? "",
              OName: x509Certificate.subject(
                      dn: ASN1DistinguishedNames.ORGANIZATION_NAME) ??
                  "",
              UName: x509Certificate.subject(
                      dn: ASN1DistinguishedNames.ORGANIZATIONAL_UNIT_NAME) ??
                  ""),
          validNotAfterDate: x509Certificate.notAfter,
          validNotBeforeDate: x509Certificate.notBefore,
          x509Certificate: x509Certificate,
        );
      }
      return null;
    }

    return SslCertificate(
      issuedBy:
          SslCertificateDName.fromMap(map["issuedBy"]?.cast<String, dynamic>()),
      issuedTo:
          SslCertificateDName.fromMap(map["issuedTo"]?.cast<String, dynamic>()),
      validNotAfterDate:
          DateTime.fromMillisecondsSinceEpoch(map["validNotAfterDate"]),
      validNotBeforeDate:
          DateTime.fromMillisecondsSinceEpoch(map["validNotBeforeDate"]),
      x509Certificate: x509Certificate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "issuedBy": issuedBy?.toMap(),
      "issuedTo": issuedTo?.toMap(),
      "validNotAfterDate": validNotAfterDate?.millisecondsSinceEpoch,
      "validNotBeforeDate": validNotBeforeDate?.millisecondsSinceEpoch,
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
  String? CName;

  ///Distinguished name (normally includes CN, O, and OU names)
  // ignore: non_constant_identifier_names
  String? DName;

  ///Organization (O) component of the name
  // ignore: non_constant_identifier_names
  String? OName;

  ///Organizational Unit (OU) component of the name
  // ignore: non_constant_identifier_names
  String? UName;

  SslCertificateDName(
      // ignore: non_constant_identifier_names
      {this.CName = "",
      // ignore: non_constant_identifier_names
      this.DName = "",
      // ignore: non_constant_identifier_names
      this.OName = "",
      // ignore: non_constant_identifier_names
      this.UName = ""});

  static SslCertificateDName? fromMap(Map<String, dynamic>? map) {
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
  String? account;

  ///Authenticator specific arguments used to log in the user.
  String args;

  LoginRequest({required this.realm, this.account, required this.args});

  static LoginRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return LoginRequest(
      realm: map["realm"],
      account: map["account"],
      args: map["args"],
    );
  }

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

///Class that represents contains the constants for the times at which to inject script content into a [WebView] used by an [UserScript].
class UserScriptInjectionTime {
  final int _value;

  const UserScriptInjectionTime._internal(this._value);

  static final Set<UserScriptInjectionTime> values = [
    UserScriptInjectionTime.AT_DOCUMENT_START,
    UserScriptInjectionTime.AT_DOCUMENT_END,
  ].toSet();

  static UserScriptInjectionTime? fromValue(int? value) {
    if (value != null) {
      try {
        return UserScriptInjectionTime.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "AT_DOCUMENT_END";
      case 0:
      default:
        return "AT_DOCUMENT_START";
    }
  }

  ///**NOTE for iOS**: A constant to inject the script after the creation of the webpage’s document element, but before loading any other content.
  ///
  ///**NOTE for Android**: A constant to try to inject the script as soon as the page starts loading.
  static const AT_DOCUMENT_START = const UserScriptInjectionTime._internal(0);

  ///**NOTE for iOS**: A constant to inject the script after the document finishes loading, but before loading any other subresources.
  ///
  ///**NOTE for Android**: A constant to inject the script as soon as the page finishes loading.
  static const AT_DOCUMENT_END = const UserScriptInjectionTime._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a script that the [WebView] injects into the web page.
class UserScript {
  ///The script’s group name.
  String? groupName;

  ///The script’s source code.
  String source;

  ///The time at which to inject the script into the [WebView].
  UserScriptInjectionTime injectionTime;

  ///A Boolean value that indicates whether to inject the script into the main frame.
  ///Specify true to inject the script only into the main frame, or false to inject it into all frames.
  ///The default value is `true`.
  ///
  ///**NOTE**: available only on iOS.
  bool iosForMainFrameOnly;

  ///A scope of execution in which to evaluate the script to prevent conflicts between different scripts.
  ///For more information about content worlds, see [ContentWorld].
  late ContentWorld contentWorld;

  UserScript(
      {this.groupName,
      required this.source,
      required this.injectionTime,
      this.iosForMainFrameOnly = true,
      ContentWorld? contentWorld}) {
    this.contentWorld = contentWorld ?? ContentWorld.PAGE;
  }

  Map<String, dynamic> toMap() {
    return {
      "groupName": groupName,
      "source": source,
      "injectionTime": injectionTime.toValue(),
      "iosForMainFrameOnly": iosForMainFrameOnly,
      "contentWorld": contentWorld.toMap()
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

final _contentWorldNameRegExp = RegExp(r'[\s]');

///Class that represents an object that defines a scope of execution for JavaScript code and which you use to prevent conflicts between different scripts.
///
///**NOTE for iOS**: available on iOS 14.0+. This class represents the native [WKContentWorld](https://developer.apple.com/documentation/webkit/wkcontentworld) class.
///
///**NOTE for Android**: it will create and append an `<iframe>` HTML element with `id` attribute equals to `flutter_inappwebview_[name]`
///to the webpage's content that contains only the inline `<script>` HTML elements in order to define a new scope of execution for JavaScript code.
///Unfortunately, there isn't any other way to do it.
///There are some limitations:
///- for any [ContentWorld], except [ContentWorld.PAGE] (that is the webpage itself), if you need to access to the `window` or `document` global Object,
///you need to use `window.top` and `window.top.document` because the code runs inside an `<iframe>`;
///- also, the execution of the inline `<script>` could be blocked by the `Content-Security-Policy` header.
class ContentWorld {
  ///The name of a custom content world.
  ///It cannot contain space characters.
  final String name;

  ///Returns the custom content world with the specified name.
  ContentWorld.world({required this.name}) {
    // WINDOW-ID- is used internally by the plugin!
    assert(!this.name.startsWith("WINDOW-ID-") &&
        !this.name.contains(_contentWorldNameRegExp));
  }

  ///The default world for clients.
  // ignore: non_constant_identifier_names
  static final ContentWorld DEFAULT_CLIENT =
      ContentWorld.world(name: "defaultClient");

  ///The content world for the current webpage’s content.
  ///This property contains the content world for scripts that the current webpage executes.
  ///Be careful when manipulating variables in this content world.
  ///If you modify a variable with the same name as one the webpage uses, you may unintentionally disrupt the normal operation of that page.
  // ignore: non_constant_identifier_names
  static final ContentWorld PAGE = ContentWorld.world(name: "page");

  Map<String, dynamic> toMap() {
    return {"name": name};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents either a success or a failure, including an associated value in each case for [InAppWebViewController.callAsyncJavaScript].
class CallAsyncJavaScriptResult {
  ///It contains the success value.
  dynamic value;

  ///It contains the failure value.
  String? error;

  CallAsyncJavaScriptResult({this.value, this.error});

  Map<String, dynamic> toMap() {
    return {"value": value, "error": error};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///A class that represents a structure that contains the location and dimensions of a rectangle.
class InAppWebViewRect {
  ///
  double x;

  ///
  double y;

  ///
  double width;

  ///
  double height;

  InAppWebViewRect(
      {required this.x,
      required this.y,
      required this.width,
      required this.height}) {
    assert(this.x >= 0 && this.y >= 0 && this.width >= 0 && this.height >= 0);
  }

  Map<String, dynamic> toMap() {
    return {"x": x, "y": y, "width": width, "height": height};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the known formats a bitmap can be compressed into.
class CompressFormat {
  final String _value;

  const CompressFormat._internal(this._value);

  static final Set<CompressFormat> values = [
    CompressFormat.JPEG,
    CompressFormat.PNG,
    CompressFormat.WEBP,
    CompressFormat.WEBP_LOSSY,
    CompressFormat.WEBP_LOSSLESS,
  ].toSet();

  static CompressFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return CompressFormat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///Compress to the `PNG` format.
  ///PNG is lossless, so `quality` is ignored.
  static const PNG = const CompressFormat._internal("PNG");

  ///Compress to the `JPEG` format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  static const JPEG = const CompressFormat._internal("JPEG");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**NOTE**: available only on Android.
  static const WEBP = const CompressFormat._internal("WEBP");

  ///Compress to the `WEBP` lossy format.
  ///Quality of `0` means compress for the smallest size.
  ///`100` means compress for max visual quality.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**NOTE for Android**: available on Android 30+.
  static const WEBP_LOSSY = const CompressFormat._internal("WEBP_LOSSY");

  ///Compress to the `WEBP` lossless format.
  ///Quality refers to how much effort to put into compression.
  ///A value of `0` means to compress quickly, resulting in a relatively large file size.
  ///`100` means to spend more time compressing, resulting in a smaller file.
  ///
  ///**NOTE**: available only on Android.
  ///
  ///**NOTE for Android**: available on Android 30+.
  static const WEBP_LOSSLESS = const CompressFormat._internal("WEBP_LOSSLESS");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the configuration data to use when generating an image from a web view’s contents using [InAppWebViewController.takeScreenshot].
///
///**NOTE for iOS**: available from iOS 11.0+.
class ScreenshotConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the [WebView] object.
  InAppWebViewRect? rect;

  ///The width of the captured image, in points.
  ///Use this property to scale the generated image to the specified width.
  ///The web view maintains the aspect ratio of the captured content, but scales it to match the width you specify.
  ///
  ///The default value of this property is `null`, which returns an image whose size matches the original size of the captured rectangle.
  double? snapshotWidth;

  ///The compression format of the captured image.
  ///The default value is [CompressFormat.PNG].
  CompressFormat compressFormat;

  ///Hint to the compressor, `0-100`. The value is interpreted differently depending on the [CompressFormat].
  ///[CompressFormat.PNG] is lossless, so this value is ignored.
  int quality;

  ///A Boolean value that indicates whether to take the snapshot after incorporating any pending screen updates.
  ///The default value of this property is `true`, which causes the web view to incorporate any recent changes to the view’s content and then generate the snapshot.
  ///If you change the value to `false`, the [WebView] takes the snapshot immediately, and before incorporating any new changes.
  ///
  ///**NOTE**: available only on iOS.
  ///
  ///**NOTE for iOS**: available only on iOS. Available from iOS 13.0+.
  bool iosAfterScreenUpdates;

  ScreenshotConfiguration(
      {this.rect,
      this.snapshotWidth,
      this.compressFormat = CompressFormat.PNG,
      this.quality = 100,
      this.iosAfterScreenUpdates = true}) {
    assert(this.quality >= 0);
  }

  Map<String, dynamic> toMap() {
    return {
      "rect": rect?.toMap(),
      "snapshotWidth": snapshotWidth,
      "compressFormat": compressFormat.toValue(),
      "quality": quality,
      "iosAfterScreenUpdates": iosAfterScreenUpdates
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

///An iOS-specific class that represents the configuration data to use when generating a PDF representation of a web view’s contents.
///
///**NOTE**: available on iOS 14.0+.
class IOSWKPDFConfiguration {
  ///The portion of your web view to capture, specified as a rectangle in the view’s coordinate system.
  ///The default value of this property is `null`, which captures everything in the view’s bounds rectangle.
  ///If you specify a custom rectangle, it must lie within the bounds rectangle of the [WebView] object.
  InAppWebViewRect? rect;

  IOSWKPDFConfiguration({this.rect});

  Map<String, dynamic> toMap() {
    return {"rect": rect?.toMap()};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the known Web Archive formats used when saving a web page.
class WebArchiveFormat {
  final String _value;

  const WebArchiveFormat._internal(this._value);

  static final Set<WebArchiveFormat> values =
      [WebArchiveFormat.MHT, WebArchiveFormat.WEBARCHIVE].toSet();

  static WebArchiveFormat? fromValue(String? value) {
    if (value != null) {
      try {
        return WebArchiveFormat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///Web Archive format used only by Android.
  static const MHT = const WebArchiveFormat._internal("mht");

  ///Web Archive format used only by iOS.
  static const WEBARCHIVE = const WebArchiveFormat._internal("webarchive");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the `crossorigin` content attribute on media elements, which is a CORS settings attribute.
///It could be used with [ScriptHtmlTagAttributes] and [CSSLinkHtmlTagAttributes]
///when fetching a resource `<link>` or a `<script>` (or resources fetched by the `<script>`).
class CrossOrigin {
  final String _value;

  const CrossOrigin._internal(this._value);

  static final Set<CrossOrigin> values = [
    CrossOrigin.ANONYMOUS,
    CrossOrigin.USE_CREDENTIALS,
  ].toSet();

  static CrossOrigin? fromValue(String? value) {
    if (value != null) {
      try {
        return CrossOrigin.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///CORS requests for this element will have the credentials flag set to 'same-origin'.
  static const ANONYMOUS = const CrossOrigin._internal("anonymous");

  ///CORS requests for this element will have the credentials flag set to 'include'.
  static const USE_CREDENTIALS = const CrossOrigin._internal("use-credentials");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents a Referrer-Policy HTTP header.
///It could be used with [ScriptHtmlTagAttributes] and [CSSLinkHtmlTagAttributes]
///when fetching a resource `<link>` or a `<script>` (or resources fetched by the `<script>`).
class ReferrerPolicy {
  final String _value;

  const ReferrerPolicy._internal(this._value);

  static final Set<ReferrerPolicy> values = [
    ReferrerPolicy.NO_REFERRER,
    ReferrerPolicy.NO_REFERRER_WHEN_DOWNGRADE,
    ReferrerPolicy.ORIGIN,
    ReferrerPolicy.ORIGIN_WHEN_CROSS_ORIGIN,
    ReferrerPolicy.SAME_ORIGIN,
    ReferrerPolicy.STRICT_ORIGIN,
    ReferrerPolicy.STRICT_ORIGIN_WHEN_CROSS_ORIGIN,
    ReferrerPolicy.UNSAFE_URL,
  ].toSet();

  static ReferrerPolicy? fromValue(String? value) {
    if (value != null) {
      try {
        return ReferrerPolicy.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///The Referer header will not be sent.
  static const NO_REFERRER = const ReferrerPolicy._internal("no-referrer");

  ///The Referer header will not be sent to origins without TLS (HTTPS).
  static const NO_REFERRER_WHEN_DOWNGRADE =
      const ReferrerPolicy._internal("no-referrer-when-downgrade");

  ///The sent referrer will be limited to the origin of the referring page: its scheme, host, and port.
  static const ORIGIN = const ReferrerPolicy._internal("origin");

  ///The referrer sent to other origins will be limited to the scheme, the host, and the port.
  ///Navigations on the same origin will still include the path.
  static const ORIGIN_WHEN_CROSS_ORIGIN =
      const ReferrerPolicy._internal("origin-when-cross-origin");

  ///A referrer will be sent for same origin, but cross-origin requests will contain no referrer information.
  static const SAME_ORIGIN = const ReferrerPolicy._internal("same-origin");

  ///Only send the origin of the document as the referrer when the protocol security level stays the same (e.g. HTTPS -> HTTPS),
  ///but don't send it to a less secure destination (e.g. HTTPS -> HTTP).
  static const STRICT_ORIGIN = const ReferrerPolicy._internal("strict-origin");

  ///Send a full URL when performing a same-origin request, but only send the origin when the protocol security level stays the same (e.g.HTTPS -> HTTPS),
  ///and send no header to a less secure destination (e.g. HTTPS -> HTTP).
  static const STRICT_ORIGIN_WHEN_CROSS_ORIGIN =
      const ReferrerPolicy._internal("strict-origin-when-cross-origin");

  ///The referrer will include the origin and the path (but not the fragment, password, or username).
  ///This value is unsafe, because it leaks origins and paths from TLS-protected resources to insecure origins.
  static const UNSAFE_URL = const ReferrerPolicy._internal("unsafe-url");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the possible the `<script>` HTML attributes to be set used by [InAppWebViewController.injectJavascriptFileFromUrl].
class ScriptHtmlTagAttributes {
  ///This attribute indicates the type of script represented. The value of this attribute will be in one of the following categories.
  ///The default value is `text/javascript`.
  String type;

  ///The HTML [id] attribute is used to specify a unique id for the `<script>` HTML element.
  String? id;

  ///For classic scripts, if the [async] attribute is present,
  ///then the classic script will be fetched in parallel to parsing and evaluated as soon as it is available.
  ///
  ///For module scripts, if the [async] attribute is present then the scripts and all their dependencies will be executed in the defer queue,
  ///therefore they will get fetched in parallel to parsing and evaluated as soon as they are available.
  ///
  ///This attribute allows the elimination of parser-blocking JavaScript where the browser
  ///would have to load and evaluate scripts before continuing to parse.
  ///[defer] has a similar effect in this case.
  ///
  ///This is a boolean attribute: the presence of a boolean attribute on an element represents the true value,
  ///and the absence of the attribute represents the false value.
  bool? async;

  ///This Boolean attribute is set to indicate to a browser that the script is meant to be executed after the document has been parsed, but before firing `DOMContentLoaded`.
  ///
  ///Scripts with the [defer] attribute will prevent the `DOMContentLoaded` event from firing until the script has loaded and finished evaluating.
  ///
  ///Scripts with the [defer] attribute will execute in the order in which they appear in the document.
  ///
  ///This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse.
  ///[async] has a similar effect in this case.
  bool? defer;

  ///Normal script elements pass minimal information to the `window.onerror` for scripts which do not pass the standard CORS checks.
  ///To allow error logging for sites which use a separate domain for static media, use this attribute.
  CrossOrigin? crossOrigin;

  ///This attribute contains inline metadata that a user agent can use to verify that a fetched resource has been delivered free of unexpected manipulation.
  String? integrity;

  ///This Boolean attribute is set to indicate that the script should not be executed in browsers that support ES2015 modules — in effect,
  ///this can be used to serve fallback scripts to older browsers that do not support modular JavaScript code.
  bool? noModule;

  ///A cryptographic nonce (number used once) to whitelist scripts in a script-src Content-Security-Policy.
  ///The server must generate a unique nonce value each time it transmits a policy.
  ///It is critical to provide a nonce that cannot be guessed as bypassing a resource's policy is otherwise trivial.
  String? nonce;

  ///Indicates which referrer to send when fetching the script, or resources fetched by the script.
  ReferrerPolicy? referrerPolicy;

  ///Represents a callback function that will be called as soon as the script has been loaded successfully.
  ///
  ///**NOTE**: This callback requires the [id] property to be set.
  Function()? onLoad;

  ///Represents a callback function that will be called if an error occurred while trying to load the script.
  ///
  ///**NOTE**: This callback requires the [id] property to be set.
  Function()? onError;

  ScriptHtmlTagAttributes(
      {this.type = "text/javascript",
      this.id,
      this.async,
      this.defer,
      this.crossOrigin,
      this.integrity,
      this.noModule,
      this.nonce,
      this.referrerPolicy,
      this.onLoad,
      this.onError}) {
    if (this.onLoad != null || this.onError != null) {
      assert(this.id != null,
          'onLoad and onError callbacks require the id property to be set.');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "type": this.type,
      "id": this.id,
      "async": this.async,
      "defer": this.defer,
      "crossOrigin": this.crossOrigin?.toValue(),
      "integrity": this.integrity,
      "noModule": this.noModule,
      "nonce": this.nonce,
      "referrerPolicy": this.referrerPolicy?.toValue(),
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

///Class that represents the possible CSS stylesheet `<link>` HTML attributes to be set used by [InAppWebViewController.injectCSSFileFromUrl].
class CSSLinkHtmlTagAttributes {
  ///The HTML [id] attribute is used to specify a unique id for the `<link>` HTML element.
  String? id;

  ///This attribute specifies the media that the linked resource applies to. Its value must be a media type / media query.
  ///This attribute is mainly useful when linking to external stylesheets — it allows the user agent to pick the best adapted one for the device it runs on.
  String? media;

  ///Normal script elements pass minimal information to the `window.onerror` for scripts which do not pass the standard CORS checks.
  ///To allow error logging for sites which use a separate domain for static media, use this attribute.
  CrossOrigin? crossOrigin;

  ///This attribute contains inline metadata that a user agent can use to verify that a fetched resource has been delivered free of unexpected manipulation.
  String? integrity;

  ///Indicates which referrer to send when fetching the script, or resources fetched by the script.
  ReferrerPolicy? referrerPolicy;

  ///The [disabled] Boolean attribute indicates whether or not the described stylesheet should be loaded and applied to the document.
  ///If [disabled] is specified in the HTML when it is loaded, the stylesheet will not be loaded during page load.
  ///Instead, the stylesheet will be loaded on-demand, if and when the [disabled] attribute is changed to `false` or removed.
  ///
  ///Setting the [disabled] property in the DOM causes the stylesheet to be removed from the document's `DocumentOrShadowRoot.styleSheets` list.
  bool? disabled;

  ///Specify alternative style sheets.
  bool? alternate;

  ///The title attribute has special semantics on the `<link>` element.
  ///When used on a `<link rel="stylesheet">` it defines a preferred or an alternate stylesheet.
  ///Incorrectly using it may cause the stylesheet to be ignored.
  String? title;

  CSSLinkHtmlTagAttributes(
      {this.id,
      this.media,
      this.crossOrigin,
      this.integrity,
      this.referrerPolicy,
      this.disabled,
      this.alternate,
      this.title});

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "media": this.media,
      "crossOrigin": this.crossOrigin?.toValue(),
      "integrity": this.integrity,
      "referrerPolicy": this.referrerPolicy?.toValue(),
      "disabled": this.disabled,
      "alternate": this.alternate,
      "title": this.title,
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

class IOSURLResponse {
  ///The URL for the response.
  Uri? url;

  ///The expected length of the response’s content.
  int expectedContentLength;

  ///The MIME type of the response.
  String? mimeType;

  ///A suggested filename for the response data.
  String? suggestedFilename;

  ///The name of the text encoding provided by the response’s originating source.
  String? textEncodingName;

  ///All HTTP header fields of the response.
  Map<String, String>? headers;

  ///The response’s HTTP status code.
  int? statusCode;

  IOSURLResponse(
      {this.url,
      required this.expectedContentLength,
      this.mimeType,
      this.suggestedFilename,
      this.textEncodingName,
      this.headers,
      this.statusCode});

  static IOSURLResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSURLResponse(
        url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
        expectedContentLength: map["expectedContentLength"],
        mimeType: map["mimeType"],
        suggestedFilename: map["suggestedFilename"],
        textEncodingName: map["textEncodingName"],
        headers: map["headers"]?.cast<String, String>(),
        statusCode: map["statusCode"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "expectedContentLength": expectedContentLength,
      "mimeType": mimeType,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "headers": headers,
      "statusCode": statusCode
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

///An iOS-specific Class that represents the navigation response used by the [WebView.iosOnNavigationResponse] event.
class IOSWKNavigationResponse {
  ///The URL for the response.
  IOSURLResponse? response;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  IOSWKNavigationResponse(
      {this.response,
      required this.isForMainFrame,
      required this.canShowMIMEType});

  static IOSWKNavigationResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKNavigationResponse(
      response:
          IOSURLResponse.fromMap(map["response"]?.cast<String, dynamic>()),
      isForMainFrame: map["isForMainFrame"],
      canShowMIMEType: map["canShowMIMEType"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "response": response?.toMap(),
      "isForMainFrame": isForMainFrame,
      "canShowMIMEType": canShowMIMEType,
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

///Class that is used by [WebView.iosOnNavigationResponse] event.
///It represents the policy to pass back to the decision handler.
class IOSNavigationResponseAction {
  final int _value;

  const IOSNavigationResponseAction._internal(this._value);

  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const IOSNavigationResponseAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSNavigationResponseAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}

///Class that is used by [WebView.iosShouldAllowDeprecatedTLS] event.
///It represents the policy to pass back to the decision handler.
class IOSShouldAllowDeprecatedTLSAction {
  final int _value;

  const IOSShouldAllowDeprecatedTLSAction._internal(this._value);

  int toValue() => _value;

  ///Cancel the navigation.
  static const CANCEL = const IOSShouldAllowDeprecatedTLSAction._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const IOSShouldAllowDeprecatedTLSAction._internal(1);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "action": _value,
    };
  }
}

///A URL load request that is independent of protocol or URL scheme.
class URLRequest {
  ///The URL of the request. Setting this to `null` will load `about:blank`.
  Uri? url;

  ///The HTTP request method.
  ///
  ///**NOTE for Android**: it supports only "GET" and "POST" methods.
  String? method;

  ///The data sent as the message body of a request, such as for an HTTP POST request.
  Uint8List? body;

  ///A dictionary containing all of the HTTP header fields for a request.
  Map<String, String>? headers;

  ///A Boolean value indicating whether the request is allowed to use the built-in cellular radios to satisfy the request.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosAllowsCellularAccess;

  ///A Boolean value that indicates whether the request may use the network when the user has specified Low Data Mode.
  ///
  ///**NOTE**: available only on iOS 13.0+.
  bool? iosAllowsConstrainedNetworkAccess;

  ///A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
  ///
  ///**NOTE**: available only on iOS 13.0+.
  bool? iosAllowsExpensiveNetworkAccess;

  ///The request’s cache policy.
  ///
  ///**NOTE**: available only on iOS.
  IOSURLRequestCachePolicy? iosCachePolicy;

  ///A Boolean value indicating whether cookies will be sent with and set for this request.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosHttpShouldHandleCookies;

  ///A Boolean value indicating whether the request should transmit before the previous response is received.
  ///
  ///**NOTE**: available only on iOS.
  bool? iosHttpShouldUsePipelining;

  ///The service type associated with this request.
  ///
  ///**NOTE**: available only on iOS.
  IOSURLRequestNetworkServiceType? iosNetworkServiceType;

  ///The timeout interval of the request.
  ///
  ///**NOTE**: available only on iOS.
  double? iosTimeoutInterval;

  ///The main document URL associated with this request.
  ///This URL is used for the cookie “same domain as main document” policy.
  ///
  ///**NOTE**: available only on iOS.
  Uri? iosMainDocumentURL;

  URLRequest(
      {required this.url,
      this.method,
      this.headers,
      this.body,
      this.iosAllowsCellularAccess,
      this.iosAllowsConstrainedNetworkAccess,
      this.iosAllowsExpensiveNetworkAccess,
      this.iosCachePolicy,
      this.iosHttpShouldHandleCookies,
      this.iosHttpShouldUsePipelining,
      this.iosNetworkServiceType,
      this.iosTimeoutInterval,
      this.iosMainDocumentURL});

  static URLRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return URLRequest(
      url: map["url"] != null ? Uri.tryParse(map["url"]) : null,
      headers: map["headers"]?.cast<String, String>(),
      method: map["method"],
      body: map["body"],
      iosAllowsCellularAccess: map["iosAllowsCellularAccess"],
      iosAllowsConstrainedNetworkAccess:
          map["iosAllowsConstrainedNetworkAccess"],
      iosAllowsExpensiveNetworkAccess: map["iosAllowsExpensiveNetworkAccess"],
      iosCachePolicy: IOSURLRequestCachePolicy.fromValue(map["iosCachePolicy"]),
      iosHttpShouldHandleCookies: map["iosHttpShouldHandleCookies"],
      iosHttpShouldUsePipelining: map["iosHttpShouldUsePipelining"],
      iosNetworkServiceType: IOSURLRequestNetworkServiceType.fromValue(
          map["iosNetworkServiceType"]),
      iosTimeoutInterval: map["iosTimeoutInterval"],
      iosMainDocumentURL: map["iosMainDocumentURL"] != null
          ? Uri.tryParse(map["iosMainDocumentURL"])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "headers": headers,
      "method": method,
      "body": body,
      "iosAllowsCellularAccess": iosAllowsCellularAccess,
      "iosAllowsConstrainedNetworkAccess": iosAllowsConstrainedNetworkAccess,
      "iosAllowsExpensiveNetworkAccess": iosAllowsExpensiveNetworkAccess,
      "iosCachePolicy": iosCachePolicy?.toValue(),
      "iosHttpShouldHandleCookies": iosHttpShouldHandleCookies,
      "iosHttpShouldUsePipelining": iosHttpShouldUsePipelining,
      "iosNetworkServiceType": iosNetworkServiceType?.toValue(),
      "iosTimeoutInterval": iosTimeoutInterval,
      "iosMainDocumentURL": iosMainDocumentURL?.toString(),
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

///An iOS-specific class that specifies optional attributes for the containing window when a new web view is requested.
class IOSWKWindowFeatures {
  ///A Boolean value indicating whether the containing window should be resizable, or `null` if resizability is not specified.
  bool? allowsResizing;

  ///A Double value specifying the height of the containing window, or `null` if the height is not specified.
  double? height;

  ///A Boolean value indicating whether the menu bar should be visible, or `null` if menu bar visibility is not specified.
  bool? menuBarVisibility;

  ///A Boolean value indicating whether the status bar should be visible, or `null` if status bar visibility is not specified.
  bool? statusBarVisibility;

  ///A Boolean value indicating whether toolbars should be visible, or `null` if toolbars visibility is not specified.
  bool? toolbarsVisibility;

  ///A Double value specifying the width of the containing window, or `null` if the width is not specified.
  double? width;

  ///A Double value specifying the x-coordinate of the containing window, or `null` if the x-coordinate is not specified.
  double? x;

  ///A Double value specifying the y-coordinate of the containing window, or `null` if the y-coordinate is not specified.
  double? y;

  IOSWKWindowFeatures(
      {this.allowsResizing,
      this.height,
      this.menuBarVisibility,
      this.statusBarVisibility,
      this.toolbarsVisibility,
      this.width,
      this.x,
      this.y});

  static IOSWKWindowFeatures? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return IOSWKWindowFeatures(
        allowsResizing: map["allowsResizing"],
        height: map["height"],
        menuBarVisibility: map["menuBarVisibility"],
        statusBarVisibility: map["statusBarVisibility"],
        toolbarsVisibility: map["toolbarsVisibility"],
        width: map["width"],
        x: map["x"],
        y: map["y"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "allowsResizing": allowsResizing,
      "height": height,
      "menuBarVisibility": menuBarVisibility,
      "statusBarVisibility": statusBarVisibility,
      "toolbarsVisibility": toolbarsVisibility,
      "width": width,
      "x": x,
      "y": y,
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

///An iOS-specific class that represents a string with associated attributes
///used by the [PullToRefreshController] and [PullToRefreshOptions] classes.
class IOSNSAttributedString {
  ///The characters for the new object.
  String string;

  ///The color of the background behind the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the background area behind the text.
  ///If you do not specify this attribute, no background color is drawn.
  Color? backgroundColor;

  ///The vertical offset for the position of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the character’s offset from the baseline, in points.
  ///The default value is `0`.
  double? baselineOffset;

  ///The expansion factor of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating the log of the expansion factor to be applied to glyphs.
  ///The default value is `0`, indicating no expansion.
  double? expansion;

  ///The color of the text.
  ///
  ///The value of this attribute is a [Color] object.
  ///Use this attribute to specify the color of the text during rendering.
  ///If you do not specify this attribute, the text is rendered in black.
  Color? foregroundColor;

  ///The kerning of the text.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value specifies the number of points by which to adjust kern-pair characters.
  ///Kerning prevents unwanted space from occurring between specific characters and depends on the font.
  ///The value `0` means kerning is disabled. The default value for this attribute is `0`.
  double? kern;

  ///The ligature of the text.
  ///
  ///The value of this attribute is a number containing an integer.
  ///Ligatures cause specific character combinations to be rendered using a single custom glyph that corresponds to those characters.
  ///The value `0` indicates no ligatures. The value `1` indicates the use of the default ligatures.
  ///The value `2` indicates the use of all ligatures.
  ///The default value for this attribute is `1`. (Value `2` is unsupported on iOS.)
  int? ligature;

  ///The obliqueness of the text.
  ///
  ///The value of this attribute is a number containing a floating point value indicating skew to be applied to glyphs.
  ///The default value is `0`, indicating no skew.
  double? obliqueness;

  ///The color of the strikethrough.
  ///
  ///The value of this attribute is a [Color] object. The default value is `null`, indicating same as foreground color.
  Color? strikethroughColor;

  ///The strikethrough style of the text.
  ///
  ///This value indicates whether the text has a line through it and corresponds to one of the constants described in [IOSNSUnderlineStyle].
  ///The default value for this attribute is [IOSNSUnderlineStyle.STYLE_NONE].
  IOSNSUnderlineStyle? strikethroughStyle;

  ///The color of the stroke.
  ///
  ///The value of this parameter is a [Color] object.
  ///If it is not defined (which is the case by default), it is assumed to be the same as the value of foregroundColor;
  ///otherwise, it describes the outline color.
  Color? strokeColor;

  ///The width of the stroke.
  ///
  ///The value of this attribute is a number containing a floating-point value.
  ///This value represents the amount to change the stroke width and is specified as a percentage of the font point size.
  ///Specify `0` (the default) for no additional changes.
  ///Specify positive values to change the stroke width alone.
  ///Specify negative values to stroke and fill the text.
  ///For example, a typical value for outlined text would be `3.0`.
  double? strokeWidth;

  ///The text effect.
  ///
  ///The value of this attribute is a [IOSNSAttributedStringTextEffectStyle] object.
  ///The default value of this property is `null`, indicating no text effect.
  IOSNSAttributedStringTextEffectStyle? textEffect;

  ///The color of the underline.
  ///
  ///The value of this attribute is a [Color] object.
  ///The default value is `null`, indicating same as foreground color.
  Color? underlineColor;

  ///The underline style of the text.
  ///
  ///This value indicates whether the text is underlined and corresponds to one of the constants described in [IOSNSUnderlineStyle].
  ///The default value for this attribute is [IOSNSUnderlineStyle.STYLE_NONE].
  IOSNSUnderlineStyle? underlineStyle;

  IOSNSAttributedString({
    required this.string,
    this.backgroundColor,
    this.baselineOffset,
    this.expansion,
    this.foregroundColor,
    this.kern,
    this.ligature,
    this.obliqueness,
    this.strikethroughColor,
    this.strikethroughStyle,
    this.strokeColor,
    this.strokeWidth,
    this.textEffect,
    this.underlineColor,
    this.underlineStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      "string": this.string,
      "backgroundColor": this.backgroundColor?.toHex(),
      "baselineOffset": this.baselineOffset,
      "expansion": this.expansion,
      "foregroundColor": this.foregroundColor?.toHex(),
      "kern": this.kern,
      "ligature": this.ligature,
      "obliqueness": this.obliqueness,
      "strikethroughColor": this.strikethroughColor?.toHex(),
      "strikethroughStyle": this.strikethroughStyle?.toValue(),
      "strokeColor": this.strokeColor?.toHex(),
      "strokeWidth": this.strokeWidth,
      "textEffect": this.textEffect?.toValue(),
      "underlineColor": this.underlineColor?.toHex(),
      "underlineStyle": this.underlineStyle?.toValue(),
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

///An iOS-specific Class that represents the constants for the underline style and strikethrough style attribute keys.
class IOSNSUnderlineStyle {
  final int _value;

  const IOSNSUnderlineStyle._internal(this._value);

  static final Set<IOSNSUnderlineStyle> values = [
    IOSNSUnderlineStyle.STYLE_NONE,
    IOSNSUnderlineStyle.SINGLE,
    IOSNSUnderlineStyle.THICK,
    IOSNSUnderlineStyle.DOUBLE,
    IOSNSUnderlineStyle.PATTERN_DOT,
    IOSNSUnderlineStyle.PATTERN_DASH,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT,
    IOSNSUnderlineStyle.PATTERN_DASH_DOT_DOT,
    IOSNSUnderlineStyle.BY_WORD,
  ].toSet();

  static IOSNSUnderlineStyle? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSNSUnderlineStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SINGLE";
      case 2:
        return "THICK";
      case 9:
        return "DOUBLE";
      case 256:
        return "PATTERN_DOT";
      case 512:
        return "PATTERN_DASH";
      case 768:
        return "PATTERN_DASH_DOT";
      case 1024:
        return "PATTERN_DASH_DOT_DOT";
      case 32768:
        return "BY_WORD";
      case 0:
      default:
        return "STYLE_NONE";
    }
  }

  ///Do not draw a line.
  static const STYLE_NONE = const IOSNSUnderlineStyle._internal(0);

  ///Draw a single line.
  static const SINGLE = const IOSNSUnderlineStyle._internal(1);

  ///Draw a thick line.
  static const THICK = const IOSNSUnderlineStyle._internal(2);

  ///Draw a double line.
  static const DOUBLE = const IOSNSUnderlineStyle._internal(9);

  ///Draw a line of dots.
  static const PATTERN_DOT = const IOSNSUnderlineStyle._internal(256);

  ///Draw a line of dashes.
  static const PATTERN_DASH = const IOSNSUnderlineStyle._internal(512);

  ///Draw a line of alternating dashes and dots.
  static const PATTERN_DASH_DOT = const IOSNSUnderlineStyle._internal(768);

  ///Draw a line of alternating dashes and two dots.
  static const PATTERN_DASH_DOT_DOT = const IOSNSUnderlineStyle._internal(1024);

  ///Draw the line only beneath or through words, not whitespace.
  static const BY_WORD = const IOSNSUnderlineStyle._internal(32768);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An iOS-specific Class that represents the supported proxy types.
class IOSNSAttributedStringTextEffectStyle {
  final String _value;

  const IOSNSAttributedStringTextEffectStyle._internal(this._value);

  static final Set<IOSNSAttributedStringTextEffectStyle> values = [
    IOSNSAttributedStringTextEffectStyle.LETTERPRESS_STYLE,
  ].toSet();

  static IOSNSAttributedStringTextEffectStyle? fromValue(String? value) {
    if (value != null) {
      try {
        return IOSNSAttributedStringTextEffectStyle.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  String toValue() => _value;

  @override
  String toString() => _value;

  ///A graphical text effect that gives glyphs the appearance of letterpress printing, which involves pressing the type into the paper.
  static const LETTERPRESS_STYLE =
      const IOSNSAttributedStringTextEffectStyle._internal("letterpressStyle");

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Android-specific class representing the size of the refresh indicator.
class AndroidPullToRefreshSize {
  final int _value;

  const AndroidPullToRefreshSize._internal(this._value);

  static final Set<AndroidPullToRefreshSize> values = [
    AndroidPullToRefreshSize.DEFAULT,
    AndroidPullToRefreshSize.LARGE,
  ].toSet();

  static AndroidPullToRefreshSize? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidPullToRefreshSize.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
        return "LARGE";
      case 1:
      default:
        return "DEFAULT";
    }
  }

  ///Default size.
  static const DEFAULT = const AndroidPullToRefreshSize._internal(1);

  ///Large size.
  static const LARGE = const AndroidPullToRefreshSize._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class that represents the [WebView] native implementation to be used.
class WebViewImplementation {
  final int _value;

  const WebViewImplementation._internal(this._value);

  static final Set<WebViewImplementation> values =
      [WebViewImplementation.NATIVE].toSet();

  static WebViewImplementation? fromValue(int? value) {
    if (value != null) {
      try {
        return WebViewImplementation.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 0:
      default:
        return "NATIVE";
    }
  }

  ///Default native implementation, such as `WKWebView` for iOS and `android.webkit.WebView` for Android.
  static const NATIVE = const WebViewImplementation._internal(0);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Class representing a download request of the WebView used by the event [WebView.onDownloadStartRequest].
class DownloadStartRequest {
  ///The full url to the content that should be downloaded.
  Uri url;

  ///the user agent to be used for the download.
  String? userAgent;

  ///Content-disposition http header, if present.
  String? contentDisposition;

  ///The mimetype of the content reported by the server.
  String? mimeType;

  ///The file size reported by the server.
  int contentLength;

  ///A suggested filename to use if saving the resource to disk.
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  String? textEncodingName;

  DownloadStartRequest(
      {required this.url,
      this.userAgent,
      this.contentDisposition,
      this.mimeType,
      required this.contentLength,
      this.suggestedFilename,
      this.textEncodingName});

  static DownloadStartRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return DownloadStartRequest(
        url: Uri.tryParse(map["url"]) ?? Uri(),
        userAgent: map["userAgent"],
        contentDisposition: map["contentDisposition"],
        mimeType: map["mimeType"],
        contentLength: map["contentLength"],
        suggestedFilename: map["suggestedFilename"],
        textEncodingName: map["textEncodingName"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "userAgent": userAgent,
      "contentDisposition": contentDisposition,
      "mimeType": mimeType,
      "contentLength": contentLength,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName
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

///Android-specific class representing the share state that should be applied to the custom tab.
class CustomTabsShareState {
  final int _value;

  const CustomTabsShareState._internal(this._value);

  static final Set<CustomTabsShareState> values = [
    CustomTabsShareState.SHARE_STATE_DEFAULT,
    CustomTabsShareState.SHARE_STATE_ON,
    CustomTabsShareState.SHARE_STATE_OFF,
  ].toSet();

  static CustomTabsShareState? fromValue(int? value) {
    if (value != null) {
      try {
        return CustomTabsShareState.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SHARE_STATE_ON";
      case 2:
        return "SHARE_STATE_OFF";
      case 0:
      default:
        return "SHARE_STATE_DEFAULT";
    }
  }

  ///Applies the default share settings depending on the browser.
  static const SHARE_STATE_DEFAULT = const CustomTabsShareState._internal(0);

  ///Shows a share option in the tab.
  static const SHARE_STATE_ON = const CustomTabsShareState._internal(1);

  ///Explicitly does not show a share option in the tab.
  static const SHARE_STATE_OFF = const CustomTabsShareState._internal(2);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Android-class that represents display mode of a Trusted Web Activity.
abstract class TrustedWebActivityDisplayMode {
  Map<String, dynamic> toMap() {
    return {};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Android-class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityDefaultDisplayMode
    implements TrustedWebActivityDisplayMode {
  String _type = "DEFAULT_MODE";

  Map<String, dynamic> toMap() {
    return {"type": _type};
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Android-class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityImmersiveDisplayMode
    implements TrustedWebActivityDisplayMode {
  ///Whether the Trusted Web Activity should be in sticky immersive mode.
  bool isSticky;

  ///The constant defining how to deal with display cutouts.
  AndroidLayoutInDisplayCutoutMode layoutInDisplayCutoutMode;

  String _type = "IMMERSIVE_MODE";

  TrustedWebActivityImmersiveDisplayMode(
      {required this.isSticky, required this.layoutInDisplayCutoutMode});

  static TrustedWebActivityImmersiveDisplayMode? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return TrustedWebActivityImmersiveDisplayMode(
        isSticky: map["isSticky"],
        layoutInDisplayCutoutMode: map["layoutInDisplayCutoutMode"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "isSticky": isSticky,
      "layoutInDisplayCutoutMode": layoutInDisplayCutoutMode.toValue(),
      "type": _type
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

///Android-specific class representing the share state that should be applied to the custom tab.
///
///**NOTE**: available on Android 28+.
class AndroidLayoutInDisplayCutoutMode {
  final int _value;

  const AndroidLayoutInDisplayCutoutMode._internal(this._value);

  static final Set<AndroidLayoutInDisplayCutoutMode> values = [
    AndroidLayoutInDisplayCutoutMode.DEFAULT,
    AndroidLayoutInDisplayCutoutMode.SHORT_EDGES,
    AndroidLayoutInDisplayCutoutMode.NEVER,
    AndroidLayoutInDisplayCutoutMode.ALWAYS
  ].toSet();

  static AndroidLayoutInDisplayCutoutMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidLayoutInDisplayCutoutMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "SHORT_EDGES";
      case 2:
        return "NEVER";
      case 3:
        return "ALWAYS";
      case 0:
      default:
        return "DEFAULT";
    }
  }

  ///With this default setting, content renders into the cutout area when displayed in portrait mode, but content is letterboxed when displayed in landscape mode.
  ///
  ///**NOTE**: available on Android 28+.
  static const DEFAULT = const AndroidLayoutInDisplayCutoutMode._internal(0);

  ///Content renders into the cutout area in both portrait and landscape modes.
  ///
  ///**NOTE**: available on Android 28+.
  static const SHORT_EDGES =
      const AndroidLayoutInDisplayCutoutMode._internal(1);

  ///Content never renders into the cutout area.
  ///
  ///**NOTE**: available on Android 28+.
  static const NEVER = const AndroidLayoutInDisplayCutoutMode._internal(2);

  ///The window is always allowed to extend into the DisplayCutout areas on the all edges of the screen.
  ///
  ///**NOTE**: available on Android 30+.
  static const ALWAYS = const AndroidLayoutInDisplayCutoutMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

/// Android-specific class representing Screen Orientation Lock type value of a Trusted Web Activity:
/// https://www.w3.org/TR/screen-orientation/#screenorientation-interface
class TrustedWebActivityScreenOrientation {
  final int _value;

  const TrustedWebActivityScreenOrientation._internal(this._value);

  static final Set<TrustedWebActivityScreenOrientation> values = [
    TrustedWebActivityScreenOrientation.DEFAULT,
    TrustedWebActivityScreenOrientation.PORTRAIT_PRIMARY,
    TrustedWebActivityScreenOrientation.PORTRAIT_SECONDARY,
    TrustedWebActivityScreenOrientation.LANDSCAPE_PRIMARY,
    TrustedWebActivityScreenOrientation.LANDSCAPE_SECONDARY,
    TrustedWebActivityScreenOrientation.ANY,
    TrustedWebActivityScreenOrientation.LANDSCAPE,
    TrustedWebActivityScreenOrientation.PORTRAIT,
    TrustedWebActivityScreenOrientation.NATURAL,
  ].toSet();

  static TrustedWebActivityScreenOrientation? fromValue(int? value) {
    if (value != null) {
      try {
        return TrustedWebActivityScreenOrientation.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "PORTRAIT_PRIMARY";
      case 2:
        return "PORTRAIT_SECONDARY";
      case 3:
        return "LANDSCAPE_PRIMARY";
      case 4:
        return "LANDSCAPE_SECONDARY";
      case 5:
        return "ANY";
      case 6:
        return "LANDSCAPE";
      case 7:
        return "PORTRAIT";
      case 8:
        return "NATURAL";
      case 0:
      default:
        return "DEFAULT";
    }
  }

  /// The default screen orientation is the set of orientations to which the screen is locked when
  /// there is no current orientation lock.
  static const DEFAULT = const TrustedWebActivityScreenOrientation._internal(0);

  ///  Portrait-primary is an orientation where the screen width is less than or equal to the
  ///  screen height. If the device's natural orientation is portrait, then it is in
  ///  portrait-primary when held in that position.
  static const PORTRAIT_PRIMARY =
      const TrustedWebActivityScreenOrientation._internal(1);

  /// Portrait-secondary is an orientation where the screen width is less than or equal to the
  /// screen height. If the device's natural orientation is portrait, then it is in
  /// portrait-secondary when rotated 180° from its natural position.
  static const PORTRAIT_SECONDARY =
      const TrustedWebActivityScreenOrientation._internal(2);

  /// Landscape-primary is an orientation where the screen width is greater than the screen height.
  /// If the device's natural orientation is landscape, then it is in landscape-primary when held
  /// in that position.
  static const LANDSCAPE_PRIMARY =
      const TrustedWebActivityScreenOrientation._internal(3);

  /// Landscape-secondary is an orientation where the screen width is greater than the
  /// screen height. If the device's natural orientation is landscape, it is in
  /// landscape-secondary when rotated 180° from its natural orientation.
  static const LANDSCAPE_SECONDARY =
      const TrustedWebActivityScreenOrientation._internal(4);

  /// Any is an orientation that means the screen can be locked to any one of portrait-primary,
  /// portrait-secondary, landscape-primary and landscape-secondary.
  static const ANY = const TrustedWebActivityScreenOrientation._internal(5);

  /// Landscape is an orientation where the screen width is greater than the screen height and
  /// depending on platform convention locking the screen to landscape can represent
  /// landscape-primary, landscape-secondary or both.
  static const LANDSCAPE =
      const TrustedWebActivityScreenOrientation._internal(6);

  /// Portrait is an orientation where the screen width is less than or equal to the screen height
  /// and depending on platform convention locking the screen to portrait can represent
  /// portrait-primary, portrait-secondary or both.
  static const PORTRAIT =
      const TrustedWebActivityScreenOrientation._internal(7);

  /// Natural is an orientation that refers to either portrait-primary or landscape-primary
  /// depending on the device's usual orientation. This orientation is usually provided by
  /// the underlying operating system.
  static const NATURAL = const TrustedWebActivityScreenOrientation._internal(8);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}
