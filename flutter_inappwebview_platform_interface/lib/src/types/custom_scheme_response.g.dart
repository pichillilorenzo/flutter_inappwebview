// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_scheme_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the response returned by the [PlatformWebViewCreationParams.onLoadResourceWithCustomScheme] event.
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  ///Content-Encoding of the data, such as `utf-8`.
  String contentEncoding;

  ///Content-Type of the data, such as `image/png`.
  String contentType;

  ///Data enconded to 'base64'.
  Uint8List data;

  ///HTTP headers sent with the data, such as `Content-Security-Policy`.
  ///`Content-Type` is derived from [contentType] unless it is listed here.
  ///
  ///**NOTE**: used on iOS, macOS and Windows; other platforms ignore it.
  Map<String, String>? headers;
  CustomSchemeResponse({
    this.contentEncoding = 'utf-8',
    required this.contentType,
    required this.data,
    this.headers,
  });

  ///Gets a possible [CustomSchemeResponse] instance from a [Map] value.
  static CustomSchemeResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CustomSchemeResponse(
      contentType: map['contentType'],
      data: Uint8List.fromList(map['data'].cast<int>()),
      headers: map['headers']?.cast<String, String>(),
    );
    if (map['contentEncoding'] != null) {
      instance.contentEncoding = map['contentEncoding'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "contentEncoding": contentEncoding,
      "contentType": contentType,
      "data": data,
      "headers": headers,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CustomSchemeResponse{contentEncoding: $contentEncoding, contentType: $contentType, data: $data, headers: $headers}';
  }
}
