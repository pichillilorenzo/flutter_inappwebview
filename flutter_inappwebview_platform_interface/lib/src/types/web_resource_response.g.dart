// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource response of the `WebView`.
class WebResourceResponse {
  ///The resource response's encoding. The default value is `utf-8`.
  String? contentEncoding;

  ///The resource response's MIME type, for example `text/html`.
  String? contentType;

  ///The data provided by the resource response.
  Uint8List? data;

  ///The headers for the resource response. If [headers] isn't `null`, then you need to set also [statusCode] and [reasonPhrase].
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  Map<String, String>? headers;

  ///The phrase describing the status code, for example `"OK"`. Must be non-empty.
  ///If reasonPhrase is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  String? reasonPhrase;

  ///The status code needs to be in the ranges [100, 299], [400, 599]. Causing a redirect by specifying a 3xx code is not supported.
  ///If statusCode is set, then you need to set also [headers] and [reasonPhrase]. This value cannot be `null`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it won't be used.
  int? statusCode;
  WebResourceResponse({
    this.contentEncoding = "utf-8",
    this.contentType = "",
    this.data,
    this.headers,
    this.reasonPhrase,
    this.statusCode,
  });

  ///Gets a possible [WebResourceResponse] instance from a [Map] value.
  static WebResourceResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceResponse(
      data: map['data'] != null
          ? Uint8List.fromList(map['data'].cast<int>())
          : null,
      headers: map['headers']?.cast<String, String>(),
      reasonPhrase: map['reasonPhrase'],
      statusCode: map['statusCode'],
    );
    instance.contentEncoding = map['contentEncoding'];
    instance.contentType = map['contentType'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "contentEncoding": contentEncoding,
      "contentType": contentType,
      "data": data,
      "headers": headers,
      "reasonPhrase": reasonPhrase,
      "statusCode": statusCode,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceResponse{contentEncoding: $contentEncoding, contentType: $contentType, data: $data, headers: $headers, reasonPhrase: $reasonPhrase, statusCode: $statusCode}';
  }
}
