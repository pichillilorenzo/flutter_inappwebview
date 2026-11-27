// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favicon_changed_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onFaviconChanged] event.
class FaviconChangedRequest {
  ///The favicon bytes for the current page, if available.
  Uint8List? icon;

  ///The favicon URL for the current page, if available.
  WebUri? url;
  FaviconChangedRequest({this.icon, this.url});

  ///Gets a possible [FaviconChangedRequest] instance from a [Map] value.
  static FaviconChangedRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = FaviconChangedRequest(
      icon: map['icon'] != null
          ? Uint8List.fromList(map['icon'].cast<int>())
          : null,
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"icon": icon, "url": url?.toString()};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'FaviconChangedRequest{icon: $icon, url: $url}';
  }
}
