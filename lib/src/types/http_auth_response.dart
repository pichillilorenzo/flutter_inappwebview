import '../in_app_webview/webview.dart';

import 'http_auth_response_action.dart';

///Class that represents the response used by the [WebView.onReceivedHttpAuthRequest] event.
class HttpAuthResponse {
  ///Represents the username used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String username;

  ///Represents the password used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String password;

  ///Indicate if the given credentials need to be saved permanently.
  bool permanentPersistence;

  ///Indicate the [HttpAuthResponseAction] to take in response of the authentication challenge.
  HttpAuthResponseAction? action;

  HttpAuthResponse(
      {this.username = "",
        this.password = "",
        this.permanentPersistence = false,
        this.action = HttpAuthResponseAction.CANCEL});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "password": password,
      "permanentPersistence": permanentPersistence,
      "action": action?.toValue()
    };
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