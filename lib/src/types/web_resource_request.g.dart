// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource request of the [WebView].
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
      this.method,
      this.hasGesture,
      this.isForMainFrame,
      this.isRedirect});

  ///Gets a possible [WebResourceRequest] instance from a [Map] value.
  static WebResourceRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceRequest(
      url: Uri.parse(map['url']),
      headers: map['headers']?.cast<String, String>(),
      method: map['method'],
      hasGesture: map['hasGesture'],
      isForMainFrame: map['isForMainFrame'],
      isRedirect: map['isRedirect'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "headers": headers,
      "method": method,
      "hasGesture": hasGesture,
      "isForMainFrame": isForMainFrame,
      "isRedirect": isRedirect,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceRequest{url: $url, headers: $headers, method: $method, hasGesture: $hasGesture, isForMainFrame: $isForMainFrame, isRedirect: $isRedirect}';
  }
}
