///Class that represents the reason the resource was caught by Safe Browsing.
class SafeBrowsingThreat {
  final int _value;

  const SafeBrowsingThreat._internal(this._value);

  ///Set of all values of [SafeBrowsingThreat].
  static final Set<SafeBrowsingThreat> values = [
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_UNKNOWN,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_MALWARE,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_PHISHING,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE,
    SafeBrowsingThreat.SAFE_BROWSING_THREAT_BILLING,
  ].toSet();

  ///Gets a possible [SafeBrowsingThreat] instance from an [int] value.
  static SafeBrowsingThreat? fromValue(int? value) {
    if (value != null) {
      try {
        return SafeBrowsingThreat.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  String toString() {
    switch (_value) {
      case 1:
        return "SAFE_BROWSING_THREAT_MALWARE";
      case 2:
        return "SAFE_BROWSING_THREAT_PHISHING";
      case 3:
        return "SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE";
      case 4:
        return "SAFE_BROWSING_THREAT_BILLING";
      case 0:
      default:
        return "SAFE_BROWSING_THREAT_UNKNOWN";
    }
  }

  ///The resource was blocked for an unknown reason.
  static const SAFE_BROWSING_THREAT_UNKNOWN =
  const SafeBrowsingThreat._internal(0);

  ///The resource was blocked because it contains malware.
  static const SAFE_BROWSING_THREAT_MALWARE =
  const SafeBrowsingThreat._internal(1);

  ///The resource was blocked because it contains deceptive content.
  static const SAFE_BROWSING_THREAT_PHISHING =
  const SafeBrowsingThreat._internal(2);

  ///The resource was blocked because it contains unwanted software.
  static const SAFE_BROWSING_THREAT_UNWANTED_SOFTWARE =
  const SafeBrowsingThreat._internal(3);

  ///The resource was blocked because it may trick the user into a billing agreement.
  ///
  ///This constant is only used when `targetSdkVersion` is at least Android 29.
  ///Otherwise, [SAFE_BROWSING_THREAT_UNKNOWN] is used instead.
  static const SAFE_BROWSING_THREAT_BILLING =
  const SafeBrowsingThreat._internal(4);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}