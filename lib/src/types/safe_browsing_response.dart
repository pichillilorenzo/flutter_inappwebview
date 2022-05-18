import '../in_app_webview/webview.dart';
import '../in_app_webview/in_app_webview_controller.dart';

import 'safe_browsing_response_action.dart';

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

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"report": report, "action": action?.toValue()};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}