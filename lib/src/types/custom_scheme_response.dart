import 'dart:typed_data';

import '../in_app_webview/webview.dart';

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'contentType': contentType,
      'contentEncoding': contentEncoding,
      'data': data
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}