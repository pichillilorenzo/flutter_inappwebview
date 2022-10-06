// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_browsing_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onSafeBrowsingHit] event.
///It is used to indicate an action to take when hitting a malicious URL.
class SafeBrowsingResponse {
  ///If reporting is enabled, all reports will be sent according to the privacy policy referenced by [InAppWebViewController.getSafeBrowsingPrivacyPolicyUrl].
  bool report;

  ///Indicate the [SafeBrowsingResponseAction] to take when hitting a malicious URL.
  SafeBrowsingResponseAction? action;
  SafeBrowsingResponse(
      {this.report = true,
      this.action = SafeBrowsingResponseAction.SHOW_INTERSTITIAL});

  ///Gets a possible [SafeBrowsingResponse] instance from a [Map] value.
  static SafeBrowsingResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = SafeBrowsingResponse();
    instance.report = map['report'];
    instance.action = SafeBrowsingResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "report": report,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SafeBrowsingResponse{report: $report, action: $action}';
  }
}
