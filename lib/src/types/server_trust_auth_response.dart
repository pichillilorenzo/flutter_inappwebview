import '../in_app_webview/webview.dart';

import 'server_trust_auth_response_action.dart';

///Class that represents the response used by the [WebView.onReceivedServerTrustAuthRequest] event.
class ServerTrustAuthResponse {
  ///Indicate the [ServerTrustAuthResponseAction] to take in response of the server trust authentication challenge.
  ServerTrustAuthResponseAction? action;

  ServerTrustAuthResponse({this.action = ServerTrustAuthResponseAction.CANCEL});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"action": action?.toValue()};
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