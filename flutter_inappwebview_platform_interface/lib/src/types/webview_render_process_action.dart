import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'webview_render_process_action.g.dart';

///Class that represents the action to take used by the [PlatformWebViewCreationParams.onRenderProcessUnresponsive] and [PlatformWebViewCreationParams.onRenderProcessResponsive] event
///to terminate the Android [WebViewRenderProcess](https://developer.android.com/reference/android/webkit/WebViewRenderProcess).
@ExchangeableEnum()
class WebViewRenderProcessAction_ {
  // ignore: unused_field
  final int _value;
  const WebViewRenderProcessAction_._internal(this._value);

  ///Cause this renderer to terminate.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform()])
  static const TERMINATE = const WebViewRenderProcessAction_._internal(0);
}
