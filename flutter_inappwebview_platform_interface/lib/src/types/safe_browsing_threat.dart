import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'safe_browsing_threat.g.dart';

///Class that represents the reason the resource was caught by Safe Browsing.
@ExchangeableEnum()
class SafeBrowsingThreat_ {
  // ignore: unused_field
  final int _value;
  const SafeBrowsingThreat_._internal(this._value);

  ///The resource was blocked for an unknown reason.
  static const SAFE_BROWSING_THREAT_UNKNOWN =
      const SafeBrowsingThreat_._internal(0);

  ///The resource was blocked because it contains malware.
  static const SAFE_BROWSING_THREAT_MALWARE =
      const SafeBrowsingThreat_._internal(1);

  ///The resource was blocked because it contains deceptive content.
  static const SAFE_BROWSING_THREAT_PHISHING =
      const SafeBrowsingThreat_._internal(2);

  ///The resource was blocked because it contains unwanted software.
  static const SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE =
      const SafeBrowsingThreat_._internal(3);

  ///The resource was blocked because it may trick the user into a billing agreement.
  ///
  ///This constant is only used when `targetSdkVersion` is at least Android 29.
  ///Otherwise, [SAFE_BROWSING_THREAT_UNKNOWN] is used instead.
  static const SAFE_BROWSING_THREAT_BILLING =
      const SafeBrowsingThreat_._internal(4);
}
