import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';

part 'geolocation_permission_show_prompt_response.g.dart';

///Class used by the host application to set the Geolocation permission state for an origin during the [PlatformWebViewCreationParams.onGeolocationPermissionsShowPrompt] event.
@ExchangeableObject()
class GeolocationPermissionShowPromptResponse_ {
  ///The origin for which permissions are set.
  String origin;

  ///Whether or not the origin should be allowed to use the Geolocation API.
  bool allow;

  ///Whether the permission should be retained beyond the lifetime of a page currently being displayed by a WebView
  ///The default value is `false`.
  bool retain;

  GeolocationPermissionShowPromptResponse_({
    required this.origin,
    required this.allow,
    this.retain = false,
  });
}
