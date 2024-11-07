// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_image_ref_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the result used by the [PlatformInAppWebViewController.requestImageRef] method.
class RequestImageRefResult {
  ///The image's url.
  WebUri? url;
  RequestImageRefResult({this.url});

  ///Gets a possible [RequestImageRefResult] instance from a [Map] value.
  static RequestImageRefResult? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = RequestImageRefResult(
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'RequestImageRefResult{url: $url}';
  }
}
