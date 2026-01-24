import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../content_blocker.dart';

part 'content_blocker_action_type.g.dart';

///Class that represents the kind of action that can be used with a [ContentBlockerTrigger].
@ExchangeableEnum()
class ContentBlockerActionType_ {
  // ignore: unused_field
  final String _value;

  const ContentBlockerActionType_._internal(this._value);

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 'block'),
      EnumIOSPlatform(value: 'block'),
      EnumMacOSPlatform(value: 'block'),
      EnumLinuxPlatform(value: 'block'),
    ],
  )
  static const BLOCK = const ContentBlockerActionType_._internal('block');

  ///Hides elements of the page based on a CSS selector.
  ///A selector field contains the selector list.
  ///Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 'css-display-none'),
      EnumIOSPlatform(value: 'css-display-none'),
      EnumMacOSPlatform(value: 'css-display-none'),
      EnumLinuxPlatform(value: 'css-display-none'),
    ],
  )
  static const CSS_DISPLAY_NONE = const ContentBlockerActionType_._internal(
    'css-display-none',
  );

  ///Changes a URL from http to https.
  ///URLs with a specified (nondefault) port and links using other protocols are unaffected.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 'make-https'),
      EnumIOSPlatform(value: 'make-https'),
      EnumMacOSPlatform(value: 'make-https'),
      EnumLinuxPlatform(value: 'make-https'),
    ],
  )
  static const MAKE_HTTPS = const ContentBlockerActionType_._internal(
    'make-https',
  );

  ///Strips cookies from the header before sending it to the server.
  ///This only blocks cookies otherwise acceptable to WebView's privacy policy.
  ///Combining with [IGNORE_PREVIOUS_RULES] doesn't override the browser’s privacy settings.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(value: 'block-cookies'),
      EnumMacOSPlatform(value: 'block-cookies'),
      EnumLinuxPlatform(value: 'block-cookies'),
    ],
  )
  static const BLOCK_COOKIES = const ContentBlockerActionType_._internal(
    'block-cookies',
  );

  ///Ignores previously triggered actions.
  @EnumSupportedPlatforms(
    platforms: [
      EnumIOSPlatform(value: 'ignore-previous-rules'),
      EnumMacOSPlatform(value: 'ignore-previous-rules'),
      EnumLinuxPlatform(value: 'ignore-previous-rules'),
    ],
  )
  static const IGNORE_PREVIOUS_RULES =
      const ContentBlockerActionType_._internal('ignore-previous-rules');
}
