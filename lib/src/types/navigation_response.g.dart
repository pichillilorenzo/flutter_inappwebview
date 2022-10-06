// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

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
    final instance = NavigationResponse(
      response: URLResponse.fromMap(map['response']?.cast<String, dynamic>()),
      isForMainFrame: map['isForMainFrame'],
      canShowMIMEType: map['canShowMIMEType'],
    );
    return instance;
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
    return toMap();
  }

  @override
  String toString() {
    return 'NavigationResponse{response: $response, isForMainFrame: $isForMainFrame, canShowMIMEType: $canShowMIMEType}';
  }
}

///An iOS-specific Class that represents the navigation response used by the [WebView.onNavigationResponse] event.
///Use [NavigationResponse] instead.
@Deprecated('Use NavigationResponse instead')
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
    final instance = IOSWKNavigationResponse(
      response:
          IOSURLResponse.fromMap(map['response']?.cast<String, dynamic>()),
      isForMainFrame: map['isForMainFrame'],
      canShowMIMEType: map['canShowMIMEType'],
    );
    return instance;
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
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKNavigationResponse{response: $response, isForMainFrame: $isForMainFrame, canShowMIMEType: $canShowMIMEType}';
  }
}
