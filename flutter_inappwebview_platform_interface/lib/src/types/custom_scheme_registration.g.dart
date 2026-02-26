// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_scheme_registration.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the registration of a custom scheme for [WebViewEnvironmentSettings] method.
///
///**Officially Supported Platforms/Implementations**:
///- Windows WebView2
class CustomSchemeRegistration {
  ///List of origins that are allowed to issue requests with the custom scheme, such as XHRs and subresource requests that have an Origin header.
  List<String>? allowedOrigins;

  ///Set this property to `true` if the URIs with this custom scheme will have an authority component (a host for custom schemes).
  ///Specifically, if you have a URI of the following form you should set the HasAuthorityComponent value as listed.
  bool? hasAuthorityComponent;

  ///The name of the custom scheme to register.
  String scheme;

  ///Whether the sites with this scheme will be treated as a Secure Context like an HTTPS site.
  ///This flag is only effective when [hasAuthorityComponent] is also set to `true`. `false` by default.
  bool? treatAsSecure;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  CustomSchemeRegistration({
    this.allowedOrigins,
    this.hasAuthorityComponent,
    required this.scheme,
    this.treatAsSecure,
  });

  ///Gets a possible [CustomSchemeRegistration] instance from a [Map] value.
  static CustomSchemeRegistration? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = CustomSchemeRegistration(
      allowedOrigins: map['allowedOrigins'] != null
          ? List<String>.from(map['allowedOrigins']!.cast<String>())
          : null,
      hasAuthorityComponent: map['hasAuthorityComponent'],
      scheme: map['scheme'],
      treatAsSecure: map['treatAsSecure'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowedOrigins": allowedOrigins,
      "hasAuthorityComponent": hasAuthorityComponent,
      "scheme": scheme,
      "treatAsSecure": treatAsSecure,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CustomSchemeRegistration{allowedOrigins: $allowedOrigins, hasAuthorityComponent: $hasAuthorityComponent, scheme: $scheme, treatAsSecure: $treatAsSecure}';
  }
}
