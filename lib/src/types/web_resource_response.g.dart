// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_resource_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource response of the [WebView].
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

  ///Gets a possible [WebResourceResponse] instance from a [Map] value.
  static WebResourceResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebResourceResponse(
      data: map['data'],
      headers: map['headers']?.cast<String, String>(),
      statusCode: map['statusCode'],
      reasonPhrase: map['reasonPhrase'],
    );
    instance.contentType = map['contentType'];
    instance.contentEncoding = map['contentEncoding'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "contentType": contentType,
      "contentEncoding": contentEncoding,
      "data": data,
      "headers": headers,
      "statusCode": statusCode,
      "reasonPhrase": reasonPhrase,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebResourceResponse{contentType: $contentType, contentEncoding: $contentEncoding, data: $data, headers: $headers, statusCode: $statusCode, reasonPhrase: $reasonPhrase}';
  }
}
