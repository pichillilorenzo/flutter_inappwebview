// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_scheme_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the response returned by the [WebView.onLoadResourceWithCustomScheme] event.
///It allows to load a specific resource. The resource data must be encoded to `base64`.
class CustomSchemeResponse {
  ///Data enconded to 'base64'.
  Uint8List data;

  ///Content-Type of the data, such as `image/png`.
  String contentType;

  ///Content-Encoding of the data, such as `utf-8`.
  String contentEncoding;
  CustomSchemeResponse(
      {required this.data,
      required this.contentType,
      this.contentEncoding = 'utf-8'});

  ///Gets a possible [CustomSchemeResponse] instance from a [Map] value.
  static CustomSchemeResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = CustomSchemeResponse(
      data: map['data'],
      contentType: map['contentType'],
    );
    instance.contentEncoding = map['contentEncoding'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "contentType": contentType,
      "contentEncoding": contentEncoding,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CustomSchemeResponse{data: $data, contentType: $contentType, contentEncoding: $contentEncoding}';
  }
}
