import '../in_app_webview/webview.dart';

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"origin": origin, "allow": allow, "retain": retain};
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