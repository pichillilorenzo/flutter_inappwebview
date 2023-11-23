import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'user_script_injection_time.dart';
import 'content_world.dart';
import '../platform_webview_feature.dart';

part 'user_script.g.dart';

///Class that represents a script that the `WebView` injects into the web page.
@ExchangeableObject()
class UserScript_ {
  ///The script’s group name.
  String? groupName;

  ///The script’s source code.
  String source;

  ///The time at which to inject the script into the `WebView`.
  UserScriptInjectionTime_ injectionTime;

  ///Use [forMainFrameOnly] instead.
  @Deprecated("Use forMainFrameOnly instead")
  bool? iosForMainFrameOnly;

  ///A Boolean value that indicates whether to inject the script into the main frame.
  ///Specify true to inject the script only into the main frame, or false to inject it into all frames.
  ///The default value is `true`.
  ///
  ///**NOTE**: available only on iOS and MacOS.
  bool forMainFrameOnly;

  ///A set of matching rules for the allowed origins.
  ///
  ///**NOTE**: available only on Android and only if [WebViewFeature.DOCUMENT_START_SCRIPT] feature is supported.
  late Set<String> allowedOriginRules;

  ///A scope of execution in which to evaluate the script to prevent conflicts between different scripts.
  ///For more information about content worlds, see [ContentWorld].
  late ContentWorld contentWorld;

  @ExchangeableObjectConstructor()
  UserScript_(
      {this.groupName,
      required this.source,
      required this.injectionTime,
      @Deprecated("Use forMainFrameOnly instead") this.iosForMainFrameOnly,
      this.forMainFrameOnly = true,
      Set<String>? allowedOriginRules,
      ContentWorld? contentWorld}) {
    this.allowedOriginRules =
        allowedOriginRules != null ? allowedOriginRules : Set.from(["*"]);
    this.contentWorld = contentWorld ?? ContentWorld.PAGE;
    // ignore: deprecated_member_use_from_same_package
    this.forMainFrameOnly = this.iosForMainFrameOnly != null
        // ignore: deprecated_member_use_from_same_package
        ? this.iosForMainFrameOnly!
        : this.forMainFrameOnly;
  }
}
