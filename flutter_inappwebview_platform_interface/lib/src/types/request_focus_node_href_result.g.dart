// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_focus_node_href_result.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the result used by the [PlatformInAppWebViewController.requestFocusNodeHref] method.
class RequestFocusNodeHrefResult {
  ///The image's src attribute.
  String? src;

  ///The anchor's text.
  String? title;

  ///The anchor's href attribute.
  WebUri? url;
  RequestFocusNodeHrefResult({this.src, this.title, this.url});

  ///Gets a possible [RequestFocusNodeHrefResult] instance from a [Map] value.
  static RequestFocusNodeHrefResult? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = RequestFocusNodeHrefResult(
      src: map['src'],
      title: map['title'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "src": src,
      "title": title,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'RequestFocusNodeHrefResult{src: $src, title: $title, url: $url}';
  }
}
