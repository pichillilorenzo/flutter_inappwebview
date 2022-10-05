// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
class URLResponse {
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
  URLResponse(
      {this.url,
      required this.expectedContentLength,
      this.mimeType,
      this.suggestedFilename,
      this.textEncodingName,
      this.headers,
      this.statusCode});

  ///Gets a possible [URLResponse] instance from a [Map] value.
  static URLResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = URLResponse(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      expectedContentLength: map['expectedContentLength'],
      mimeType: map['mimeType'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      headers: map['headers']?.cast<String, String>(),
      statusCode: map['statusCode'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "expectedContentLength": expectedContentLength,
      "mimeType": mimeType,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "headers": headers,
      "statusCode": statusCode,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLResponse{url: $url, expectedContentLength: $expectedContentLength, mimeType: $mimeType, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, headers: $headers, statusCode: $statusCode}';
  }
}

///Use [URLResponse] instead.
@Deprecated('Use URLResponse instead')
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

  ///Gets a possible [IOSURLResponse] instance from a [Map] value.
  static IOSURLResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = IOSURLResponse(
      url: map['url'] != null ? Uri.parse(map['url']) : null,
      expectedContentLength: map['expectedContentLength'],
      mimeType: map['mimeType'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      headers: map['headers']?.cast<String, String>(),
      statusCode: map['statusCode'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url?.toString(),
      "expectedContentLength": expectedContentLength,
      "mimeType": mimeType,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "headers": headers,
      "statusCode": statusCode,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSURLResponse{url: $url, expectedContentLength: $expectedContentLength, mimeType: $mimeType, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, headers: $headers, statusCode: $statusCode}';
  }
}
