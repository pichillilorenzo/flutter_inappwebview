import '../in_app_webview/webview.dart';
import 'url_authentication_challenge.dart';
import 'url_protection_space.dart';

///Class that represents the challenge of the [WebView.onReceivedClientCertRequest] event.
///It provides all the information about the challenge.
class ClientCertChallenge extends URLAuthenticationChallenge {
  ///Use [principals] instead.
  @Deprecated('Use principals instead')
  List<String>? androidPrincipals;

  ///The acceptable certificate issuers for the certificate matching the private key.
  ///
  ///**NOTE**: available only on Android.
  List<String>? principals;

  ///Use [keyTypes] instead.
  @Deprecated('Use keyTypes instead')
  List<String>? androidKeyTypes;

  ///Returns the acceptable types of asymmetric keys.
  ///
  ///**NOTE**: available only on Android.
  List<String>? keyTypes;

  ClientCertChallenge(
      {required URLProtectionSpace protectionSpace,
        @Deprecated('Use principals instead') this.androidPrincipals,
        this.principals,
        @Deprecated('Use keyTypes instead') this.androidKeyTypes,
        this.keyTypes})
      : super(protectionSpace: protectionSpace) {
    // ignore: deprecated_member_use_from_same_package
    this.principals = this.principals ?? this.androidPrincipals;
    // ignore: deprecated_member_use_from_same_package
    this.keyTypes = this.keyTypes ?? this.androidKeyTypes;
  }

  ///Gets a possible [ClientCertChallenge] instance from a [Map] value.
  static ClientCertChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ClientCertChallenge(
        protectionSpace: URLProtectionSpace.fromMap(
            map["protectionSpace"].cast<String, dynamic>())!,
        // ignore: deprecated_member_use_from_same_package
        androidPrincipals: map["principals"]?.cast<String>(),
        principals: map["principals"]?.cast<String>(),
        // ignore: deprecated_member_use_from_same_package
        androidKeyTypes: map["keyTypes"]?.cast<String>(),
        keyTypes: map["keyTypes"]?.cast<String>());
  }
}