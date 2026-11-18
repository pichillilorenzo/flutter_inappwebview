// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launching_external_uri_scheme_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onLaunchingExternalUriScheme] event.
class LaunchingExternalUriSchemeResponse {
  ///Set to `true` to cancel the external URI scheme launch.
  bool cancel;
  LaunchingExternalUriSchemeResponse({required this.cancel});

  ///Gets a possible [LaunchingExternalUriSchemeResponse] instance from a [Map] value.
  static LaunchingExternalUriSchemeResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = LaunchingExternalUriSchemeResponse(cancel: map['cancel']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"cancel": cancel};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LaunchingExternalUriSchemeResponse{cancel: $cancel}';
  }
}
