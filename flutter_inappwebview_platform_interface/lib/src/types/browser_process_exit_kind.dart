import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../webview_environment/platform_webview_environment.dart';

part 'browser_process_exit_kind.g.dart';

///The kind of browser process exit that has occurred.
@ExchangeableEnum(bitwiseOrOperator: true)
class BrowserProcessExitKind_ {
  // ignore: unused_field
  final int _value;
  const BrowserProcessExitKind_._internal(this._value);

  ///Indicates that the browser process ended normally.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 0)])
  static const NORMAL = BrowserProcessExitKind_._internal(0);

  ///Indicates that the browser process ended unexpectedly.
  ///A [PlatformWebViewCreationParams.onProcessFailed] event will also be
  ///raised to listening WebViews from the [PlatformWebViewEnvironment] associated to the failed process.
  @EnumSupportedPlatforms(platforms: [EnumWindowsPlatform(value: 1)])
  static const FAILED = BrowserProcessExitKind_._internal(1);
}
