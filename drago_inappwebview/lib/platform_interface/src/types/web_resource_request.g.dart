// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource request of the `WebView`.
class WebResourceRequest {
  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? hasGesture;

  ///The headers associated with the request.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `null`.
  Map<String, String>? headers;

  ///Whether the request was made in order to fetch the main frame's document.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `true`.
  bool? isForMainFrame;

  ///Whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? isRedirect;

  ///The method associated with the request, for example `GET`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always "GET".
  String? method;

  ///The URL for which the resource request was made.
  WebUri url;
  WebResourceRequest({
    this.hasGesture,
    this.headers,
    this.isForMainFrame,
    this.isRedirect,
    this.method,
    required this.url,
  });

  ///Gets a possible [WebResourceRequest] instance from a [Map] value.
  static WebResourceRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceRequest(
      hasGesture: map['hasGesture'],
      headers: map['headers']?.cast<String, String>(),
      isForMainFrame: map['isForMainFrame'],
      isRedirect: map['isRedirect'],
      method: map['method'],
      url: WebUri(map['url']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "hasGesture": hasGesture,
      "headers": headers,
      "isForMainFrame": isForMainFrame,
      "isRedirect": isRedirect,
      "method": method,
      "url": url.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceRequest{hasGesture: $hasGesture, headers: $headers, isForMainFrame: $isForMainFrame, isRedirect: $isRedirect, method: $method, url: $url}';
  }
}
