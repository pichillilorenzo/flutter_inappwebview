import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'js_alert_response_action.dart';
import 'enum_method.dart';

part 'js_alert_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsAlert] event to control a JavaScript alert dialog.
@ExchangeableObject()
class JsAlertResponse_ {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Whether the client will handle the alert dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm button.
  JsAlertResponseAction_? action;

  JsAlertResponse_(
      {this.message = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.action = JsAlertResponseAction_.CONFIRM});
}
