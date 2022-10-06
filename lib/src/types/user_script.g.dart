// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_script.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a script that the [WebView] injects into the web page.
class UserScript {
  ///The script’s group name.
  String? groupName;

  ///The script’s source code.
  String source;

  ///The time at which to inject the script into the [WebView].
  UserScriptInjectionTime injectionTime;

  ///Use [forMainFrameOnly] instead.
  @Deprecated('Use forMainFrameOnly instead')
  bool? iosForMainFrameOnly;

  ///A Boolean value that indicates whether to inject the script into the main frame.
  ///Specify true to inject the script only into the main frame, or false to inject it into all frames.
  ///The default value is `true`.
  ///
  ///**NOTE**: available only on iOS.
  bool forMainFrameOnly;

  ///A set of matching rules for the allowed origins.
  ///
  ///**NOTE**: available only on Android and only if [WebViewFeature.DOCUMENT_START_SCRIPT] feature is supported.
  late Set<String> allowedOriginRules;

  ///A scope of execution in which to evaluate the script to prevent conflicts between different scripts.
  ///For more information about content worlds, see [ContentWorld].
  late ContentWorld contentWorld;
  UserScript(
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
    this.forMainFrameOnly = this.iosForMainFrameOnly != null
        ? this.iosForMainFrameOnly!
        : this.forMainFrameOnly;
  }

  ///Gets a possible [UserScript] instance from a [Map] value.
  static UserScript? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = UserScript(
      groupName: map['groupName'],
      source: map['source'],
      injectionTime:
          UserScriptInjectionTime.fromNativeValue(map['injectionTime'])!,
      iosForMainFrameOnly: map['forMainFrameOnly'],
    );
    instance.forMainFrameOnly = map['forMainFrameOnly'];
    instance.allowedOriginRules = map['allowedOriginRules'].cast<String>();
    instance.contentWorld = map['contentWorld'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "groupName": groupName,
      "source": source,
      "injectionTime": injectionTime.toNativeValue(),
      "forMainFrameOnly": forMainFrameOnly,
      "allowedOriginRules": allowedOriginRules.toList(),
      "contentWorld": contentWorld.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UserScript{groupName: $groupName, source: $source, injectionTime: $injectionTime, forMainFrameOnly: $forMainFrameOnly, allowedOriginRules: $allowedOriginRules, contentWorld: $contentWorld}';
  }
}
