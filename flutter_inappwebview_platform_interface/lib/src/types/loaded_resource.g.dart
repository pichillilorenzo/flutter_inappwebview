// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loaded_resource.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a resource response of the `WebView`.
///It is used by the method [PlatformWebViewCreationParams.onLoadResource].
class LoadedResource {
  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) duration to fetch a resource.
  double? duration;

  ///A string representing the type of resource.
  String? initiatorType;

  ///Returns the [DOMHighResTimeStamp](https://developer.mozilla.org/en-US/docs/Web/API/DOMHighResTimeStamp) for the time a resource fetch started.
  double? startTime;

  ///Resource URL.
  WebUri? url;
  LoadedResource({this.duration, this.initiatorType, this.startTime, this.url});

  ///Gets a possible [LoadedResource] instance from a [Map] value.
  static LoadedResource? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = LoadedResource(
      duration: map['duration'],
      initiatorType: map['initiatorType'],
      startTime: map['startTime'],
      url: map['url'] != null ? WebUri(map['url']) : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "duration": duration,
      "initiatorType": initiatorType,
      "startTime": startTime,
      "url": url?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LoadedResource{duration: $duration, initiatorType: $initiatorType, startTime: $startTime, url: $url}';
  }
}
