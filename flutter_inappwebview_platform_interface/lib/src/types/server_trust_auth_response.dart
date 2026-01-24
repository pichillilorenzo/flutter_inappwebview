import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'server_trust_auth_response_action.dart';
import 'enum_method.dart';

part 'server_trust_auth_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest] event.
@ExchangeableObject()
class ServerTrustAuthResponse_ {
  ///Indicate the [ServerTrustAuthResponseAction] to take in response of the server trust authentication challenge.
  ServerTrustAuthResponseAction_? action;

  ServerTrustAuthResponse_({
    this.action = ServerTrustAuthResponseAction_.CANCEL,
  });
}
