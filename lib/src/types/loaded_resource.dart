import '../in_app_webview/webview.dart';

///Class representing a resource response of the [WebView].
///It is used by the method [WebView.onLoadResource].
class LoadedResource {
  ///A string representing the type of resource.
  String? initiatorType;

  ///Resource URL.
  Uri? url;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double? startTime;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double? duration;

  LoadedResource({this.initiatorType, this.url, this.startTime, this.duration});

  ///Gets a possible [LoadedResource] instance from a [Map] value.
  static LoadedResource? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return LoadedResource(
        initiatorType: map["initiatorType"],
        url: map["url"] != null ? Uri.parse(map["url"]) : null,
        startTime: map["startTime"],
        duration: map["duration"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "initiatorType": initiatorType,
      "url": url?.toString(),
      "startTime": startTime,
      "duration": duration
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