import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'http_auth_response_action.dart';
import 'enum_method.dart';

part 'http_auth_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedHttpAuthRequest] event.
@ExchangeableObject()
class HttpAuthResponse_ {
  ///Represents the username used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String username;

  ///Represents the password used for the authentication if the [action] corresponds to [HttpAuthResponseAction.PROCEED]
  String password;

  ///Indicate if the given credentials need to be saved permanently.
  bool permanentPersistence;

  ///Indicate the [HttpAuthResponseAction] to take in response of the authentication challenge.
  HttpAuthResponseAction_? action;

  HttpAuthResponse_({
    this.username = "",
    this.password = "",
    this.permanentPersistence = false,
    this.action = HttpAuthResponseAction_.CANCEL,
  });
}
