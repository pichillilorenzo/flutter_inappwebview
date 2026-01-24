import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../web_uri.dart';
import 'enum_method.dart';

part 'js_prompt_request.g.dart';

///Class that represents the request of the [PlatformWebViewCreationParams.onJsPrompt] event.
@ExchangeableObject()
class JsPromptRequest_ {
  ///The url of the page requesting the dialog.
  WebUri? url;

  ///Message to be displayed in the window.
  String? message;

  ///The default value displayed in the prompt dialog.
  String? defaultValue;

  ///Use [isMainFrame] instead.
  @Deprecated("Use isMainFrame instead")
  bool? iosIsMainFrame;

  ///Indicates whether the request was made for the main frame.
  @SupportedPlatforms(platforms: [IOSPlatform(), MacOSPlatform()])
  bool? isMainFrame;

  JsPromptRequest_({
    this.url,
    this.message,
    this.defaultValue,
    @Deprecated("Use isMainFrame instead") this.iosIsMainFrame,
    this.isMainFrame,
  });
}
