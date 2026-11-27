// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the navigation response used by the [PlatformWebViewCreationParams.onNavigationResponse] event.
class NavigationResponse {
  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///The URL for the response.
  URLResponse? response;
  NavigationResponse({
    required this.canShowMIMEType,
    required this.isForMainFrame,
    this.response,
  });

  ///Gets a possible [NavigationResponse] instance from a [Map] value.
  static NavigationResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = NavigationResponse(
      canShowMIMEType: map['canShowMIMEType'],
      isForMainFrame: map['isForMainFrame'],
      response: URLResponse.fromMap(
        map['response']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "canShowMIMEType": canShowMIMEType,
      "isForMainFrame": isForMainFrame,
      "response": response?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'NavigationResponse{canShowMIMEType: $canShowMIMEType, isForMainFrame: $isForMainFrame, response: $response}';
  }
}

///An iOS-specific Class that represents the navigation response used by the [PlatformWebViewCreationParams.onNavigationResponse] event.
///Use [NavigationResponse] instead.
@Deprecated('Use NavigationResponse instead')
class IOSWKNavigationResponse {
  ///A Boolean value that indicates whether WebKit is capable of displaying the response’s MIME type natively.
  bool canShowMIMEType;

  ///A Boolean value that indicates whether the response targets the web view’s main frame.
  bool isForMainFrame;

  ///The URL for the response.
  IOSURLResponse? response;
  IOSWKNavigationResponse({
    required this.canShowMIMEType,
    required this.isForMainFrame,
    this.response,
  });

  ///Gets a possible [IOSWKNavigationResponse] instance from a [Map] value.
  static IOSWKNavigationResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKNavigationResponse(
      canShowMIMEType: map['canShowMIMEType'],
      isForMainFrame: map['isForMainFrame'],
      response: IOSURLResponse.fromMap(
        map['response']?.cast<String, dynamic>(),
        enumMethod: enumMethod,
      ),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "canShowMIMEType": canShowMIMEType,
      "isForMainFrame": isForMainFrame,
      "response": response?.toMap(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKNavigationResponse{canShowMIMEType: $canShowMIMEType, isForMainFrame: $isForMainFrame, response: $response}';
  }
}
