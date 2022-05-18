import '../in_app_webview/webview.dart';
import 'url_authentication_challenge.dart';
import 'url_protection_space.dart';

///Class that represents the challenge of the [WebView.onReceivedServerTrustAuthRequest] event.
///It provides all the information about the challenge.
class ServerTrustChallenge extends URLAuthenticationChallenge {
  ServerTrustChallenge({required URLProtectionSpace protectionSpace})
      : super(protectionSpace: protectionSpace);

  ///Gets a possible [ServerTrustChallenge] instance from a [Map] value.
  static ServerTrustChallenge? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return ServerTrustChallenge(
      protectionSpace: URLProtectionSpace.fromMap(
          map["protectionSpace"].cast<String, dynamic>())!,
    );
  }
}