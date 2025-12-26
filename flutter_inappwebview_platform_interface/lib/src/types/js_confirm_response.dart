import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'js_confirm_response_action.dart';
import 'enum_method.dart';

part 'js_confirm_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsConfirm] event to control a JavaScript confirm dialog.
@ExchangeableObject()
class JsConfirmResponse_ {
  ///Message to be displayed in the window.
  String message;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the confirm dialog.
  bool handledByClient;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsConfirmResponseAction_? action;

  JsConfirmResponse_(
      {this.message = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.action = JsConfirmResponseAction_.CANCEL});
}
