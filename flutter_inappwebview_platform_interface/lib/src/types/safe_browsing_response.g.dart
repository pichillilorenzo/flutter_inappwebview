// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_browsing_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onSafeBrowsingHit] event.
///It is used to indicate an action to take when hitting a malicious URL.
class SafeBrowsingResponse {
  ///Indicate the [SafeBrowsingResponseAction] to take when hitting a malicious URL.
  SafeBrowsingResponseAction? action;

  ///If reporting is enabled, all reports will be sent according to the privacy policy referenced by [PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  bool report;
  SafeBrowsingResponse(
      {this.action = SafeBrowsingResponseAction.SHOW_INTERSTITIAL,
      this.report = true});

  ///Gets a possible [SafeBrowsingResponse] instance from a [Map] value.
  static SafeBrowsingResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = SafeBrowsingResponse();
    instance.action = SafeBrowsingResponseAction.fromNativeValue(map['action']);
    instance.report = map['report'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
      "report": report,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SafeBrowsingResponse{action: $action, report: $report}';
  }
}
