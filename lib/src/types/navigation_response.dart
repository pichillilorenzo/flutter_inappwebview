import '../in_app_webview/webview.dart';
import 'url_response.dart';

///Class that represents the navigation response used by the [WebView.onNavigationResponse] event.
class NavigationResponse {
  ///The URL for the response.
  URLResponse? response;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  NavigationResponse(
      {this.response,
        required this.isForMainFrame,
        required this.canShowMIMEType});

  ///Gets a possible [NavigationResponse] instance from a [Map] value.
  static NavigationResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return NavigationResponse(
      response: URLResponse.fromMap(map["response"]?.cast<String, dynamic>()),
      isForMainFrame: map["isForMainFrame"],
      canShowMIMEType: map["canShowMIMEType"],
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "response": response?.toMap(),
      "isForMainFrame": isForMainFrame,
      "canShowMIMEType": canShowMIMEType,
    };
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

///An iOS-specific Class that represents the navigation response used by the [WebView.onNavigationResponse] event.
///Use [NavigationResponse] instead.
@Deprecated("Use NavigationResponse instead")
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

  ///Gets a possible [IOSWKNavigationResponse] instance from a [Map] value.
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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "response": response?.toMap(),
      "isForMainFrame": isForMainFrame,
      "canShowMIMEType": canShowMIMEType,
    };
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