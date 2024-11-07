// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
class URLResponse {
  ///The expected length of the response’s content.
  int expectedContentLength;

  ///All HTTP header fields of the response.
  Map<String, String>? headers;

  ///The MIME type of the response.
  String? mimeType;

  ///The response’s HTTP status code.
  int? statusCode;

  ///A suggested filename for the response data.
  String? suggestedFilename;

  ///The name of the text encoding provided by the response’s originating source.
  String? textEncodingName;

  ///The URL for the response.
  WebUri? url;
  URLResponse(
      {required this.expectedContentLength,
      this.headers,
      this.mimeType,
      this.statusCode,
      this.suggestedFilename,
      this.textEncodingName,
      this.url});

  ///Gets a possible [URLResponse] instance from a [Map] value.
  static URLResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = URLResponse(
      expectedContentLength: map['expectedContentLength'],
      headers: map['headers']?.cast<String, String>(),
      mimeType: map['mimeType'],
      statusCode: map['statusCode'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "expectedContentLength": expectedContentLength,
      "headers": headers,
      "mimeType": mimeType,
      "statusCode": statusCode,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'URLResponse{expectedContentLength: $expectedContentLength, headers: $headers, mimeType: $mimeType, statusCode: $statusCode, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, url: $url}';
  }
}

///Use [URLResponse] instead.
@Deprecated('Use URLResponse instead')
class IOSURLResponse {
  ///The expected length of the response’s content.
  int expectedContentLength;

  ///All HTTP header fields of the response.
  Map<String, String>? headers;

  ///The MIME type of the response.
  String? mimeType;

  ///The response’s HTTP status code.
  int? statusCode;

  ///A suggested filename for the response data.
  String? suggestedFilename;

  ///The name of the text encoding provided by the response’s originating source.
  String? textEncodingName;

  ///The URL for the response.
  Uri? url;
  IOSURLResponse(
      {required this.expectedContentLength,
      this.headers,
      this.mimeType,
      this.statusCode,
      this.suggestedFilename,
      this.textEncodingName,
      this.url});

  ///Gets a possible [IOSURLResponse] instance from a [Map] value.
  static IOSURLResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = IOSURLResponse(
      expectedContentLength: map['expectedContentLength'],
      headers: map['headers']?.cast<String, String>(),
      mimeType: map['mimeType'],
      statusCode: map['statusCode'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      url: map['url'] != null ? Uri.tryParse(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "expectedContentLength": expectedContentLength,
      "headers": headers,
      "mimeType": mimeType,
      "statusCode": statusCode,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSURLResponse{expectedContentLength: $expectedContentLength, headers: $headers, mimeType: $mimeType, statusCode: $statusCode, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, url: $url}';
  }
}
