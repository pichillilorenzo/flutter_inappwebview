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
  SafeBrowsingResponse({SafeBrowsingResponseAction? action, this.report = true})
    : action = action ?? SafeBrowsingResponseAction.SHOW_INTERSTITIAL;

  ///Gets a possible [SafeBrowsingResponse] instance from a [Map] value.
  static SafeBrowsingResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = SafeBrowsingResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => SafeBrowsingResponseAction.fromNativeValue(
        map['action'],
      ),
      EnumMethod.value => SafeBrowsingResponseAction.fromValue(map['action']),
      EnumMethod.name => SafeBrowsingResponseAction.byName(map['action']),
    };
    if (map['report'] != null) {
      instance.report = map['report'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name(),
      },
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
