import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'js_prompt_response_action.dart';
import 'enum_method.dart';

part 'js_prompt_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onJsPrompt] event to control a JavaScript prompt dialog.
@ExchangeableObject()
class JsPromptResponse_ {
  ///Message to be displayed in the window.
  String message;

  ///The default value displayed in the prompt dialog.
  String defaultValue;

  ///Title of the confirm button.
  String confirmButtonTitle;

  ///Title of the cancel button.
  String cancelButtonTitle;

  ///Whether the client will handle the prompt dialog.
  bool handledByClient;

  ///Value of the prompt dialog.
  String? value;

  ///Action used to confirm that the user hit confirm or cancel button.
  JsPromptResponseAction_? action;

  JsPromptResponse_(
      {this.message = "",
      this.defaultValue = "",
      this.handledByClient = false,
      this.confirmButtonTitle = "",
      this.cancelButtonTitle = "",
      this.value,
      this.action = JsPromptResponseAction_.CANCEL});
}
