// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_script.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents a script that the `WebView` injects into the web page.
class UserScript {
  ///A set of matching rules for the allowed origins.
  ///Adding `'*'` as an allowed origin or setting this to `null`, it means it will allow every origin.
  ///Instead, an empty [Set] will block every origin.
  ///
  ///**NOTE for Android**: each origin pattern MUST follow the table rule of [PlatformInAppWebViewController.addWebMessageListener].
  ///
  ///**NOTE for iOS, macOS, Windows**: each origin pattern will be used as a
  ///Regular Expression Pattern that will be used on JavaScript side using [RegExp](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp).
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  late Set<String> allowedOriginRules;

  ///A scope of execution in which to evaluate the script to prevent conflicts between different scripts.
  ///For more information about content worlds, see [ContentWorld].
  ///
  ///**NOTE for Android**: because of how a Content World is implemented on Android, if [forMainFrameOnly] is `true`,
  ///the [source] inside a specific Content World that is not [ContentWorld.PAGE] will not be executed.
  ///See [ContentWorld] for more details.
  late ContentWorld contentWorld;

  ///A Boolean value that indicates whether to inject the script into the main frame.
  ///Specify `true` to inject the script only into the main frame, or false to inject it into all frames.
  ///The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  bool forMainFrameOnly;

  ///The script’s group name.
  String? groupName;

  ///The time at which to inject the script into the `WebView`.
  UserScriptInjectionTime injectionTime;

  ///Use [forMainFrameOnly] instead.
  @Deprecated('Use forMainFrameOnly instead')
  bool? iosForMainFrameOnly;

  ///The script’s source code.
  String source;
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
  static UserScript? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = UserScript(
      groupName: map['groupName'],
      injectionTime: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          UserScriptInjectionTime.fromNativeValue(map['injectionTime']),
        EnumMethod.value =>
          UserScriptInjectionTime.fromValue(map['injectionTime']),
        EnumMethod.name => UserScriptInjectionTime.byName(map['injectionTime'])
      }!,
      iosForMainFrameOnly: map['forMainFrameOnly'],
      source: map['source'],
    );
    if (map['allowedOriginRules'] != null) {
      instance.allowedOriginRules =
          Set<String>.from(map['allowedOriginRules']!.cast<String>());
    }
    if (map['contentWorld'] != null) {
      instance.contentWorld = ContentWorld.fromMap(
          map['contentWorld']?.cast<String, dynamic>(),
          enumMethod: enumMethod)!;
    }
    if (map['forMainFrameOnly'] != null) {
      instance.forMainFrameOnly = map['forMainFrameOnly'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowedOriginRules": allowedOriginRules.toList(),
      "contentWorld": contentWorld.toMap(enumMethod: enumMethod),
      "forMainFrameOnly": forMainFrameOnly,
      "groupName": groupName,
      "injectionTime": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => injectionTime.toNativeValue(),
        EnumMethod.value => injectionTime.toValue(),
        EnumMethod.name => injectionTime.name()
      },
      "source": source,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'UserScript{allowedOriginRules: $allowedOriginRules, contentWorld: $contentWorld, forMainFrameOnly: $forMainFrameOnly, groupName: $groupName, injectionTime: $injectionTime, source: $source}';
  }
}
