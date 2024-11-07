import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../webview_environment/webview_environment_settings.dart';
import 'enum_method.dart';

part 'custom_scheme_registration.g.dart';

///Class that represents the registration of a custom scheme for [WebViewEnvironmentSettings] method.
@SupportedPlatforms(platforms: [WindowsPlatform()])
@ExchangeableObject()
class CustomSchemeRegistration_ {
  ///The name of the custom scheme to register.
  String scheme;

  ///List of origins that are allowed to issue requests with the custom scheme, such as XHRs and subresource requests that have an Origin header.
  List<String>? allowedOrigins;

  ///Whether the sites with this scheme will be treated as a Secure Context like an HTTPS site.
  ///This flag is only effective when [hasAuthorityComponent] is also set to `true`. `false` by default.
  bool? treatAsSecure;

  ///Set this property to `true` if the URIs with this custom scheme will have an authority component (a host for custom schemes).
  ///Specifically, if you have a URI of the following form you should set the HasAuthorityComponent value as listed.
  bool? hasAuthorityComponent;

  CustomSchemeRegistration_(
      {required this.scheme,
      this.allowedOrigins,
      this.treatAsSecure,
      this.hasAuthorityComponent});
}
