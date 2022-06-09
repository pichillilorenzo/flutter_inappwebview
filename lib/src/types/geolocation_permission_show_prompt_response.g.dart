// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocation_permission_show_prompt_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class used by the host application to set the Geolocation permission state for an origin during the [WebView.onGeolocationPermissionsShowPrompt] event.
class GeolocationPermissionShowPromptResponse {
  ///The origin for which permissions are set.
  String origin;

  ///Whether or not the origin should be allowed to use the Geolocation API.
  bool allow;

  ///Whether the permission should be retained beyond the lifetime of a page currently being displayed by a WebView
  ///The default value is `false`.
  bool retain;
  GeolocationPermissionShowPromptResponse(
      {required this.origin, required this.allow, this.retain = false});

  ///Gets a possible [GeolocationPermissionShowPromptResponse] instance from a [Map] value.
  static GeolocationPermissionShowPromptResponse? fromMap(
      Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = GeolocationPermissionShowPromptResponse(
      origin: map['origin'],
      allow: map['allow'],
    );
    instance.retain = map['retain'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "origin": origin,
      "allow": allow,
      "retain": retain,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'GeolocationPermissionShowPromptResponse{origin: $origin, allow: $allow, retain: $retain}';
  }
}
