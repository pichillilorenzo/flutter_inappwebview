// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launching_external_uri_scheme_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onLaunchingExternalUriScheme] event.
class LaunchingExternalUriSchemeRequest {
  ///The origin initiating the external URI scheme launch.
  WebUri? initiatingOrigin;

  ///Whether the external URI scheme request was initiated through a user gesture.
  bool? isUserInitiated;

  ///The URI with the external URI scheme to be launched.
  WebUri uri;
  LaunchingExternalUriSchemeRequest({
    this.initiatingOrigin,
    this.isUserInitiated,
    required this.uri,
  });

  ///Gets a possible [LaunchingExternalUriSchemeRequest] instance from a [Map] value.
  static LaunchingExternalUriSchemeRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = LaunchingExternalUriSchemeRequest(
      initiatingOrigin: map['initiatingOrigin'] != null
          ? WebUri(map['initiatingOrigin'])
          : null,
      isUserInitiated: map['isUserInitiated'],
      uri: WebUri(map['uri']),
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "initiatingOrigin": initiatingOrigin?.toString(),
      "isUserInitiated": isUserInitiated,
      "uri": uri.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LaunchingExternalUriSchemeRequest{initiatingOrigin: $initiatingOrigin, isUserInitiated: $isUserInitiated, uri: $uri}';
  }
}
