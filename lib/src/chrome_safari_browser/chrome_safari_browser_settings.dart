import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../util.dart';
import 'android/chrome_custom_tabs_options.dart';
import 'apple/safari_options.dart';
import '../types/main.dart';

class ChromeSafariBrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static ChromeSafariBrowserOptions fromMap(Map<String, dynamic> map) {
    return new ChromeSafariBrowserOptions();
  }

  ChromeSafariBrowserOptions copy() {
    return ChromeSafariBrowserOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the settings that can be used for an [ChromeSafariBrowser] window.
class ChromeSafariBrowserSettings implements ChromeSafariBrowserOptions {
  ///The share state that should be applied to the custom tab. The default value is [CustomTabsShareState.SHARE_STATE_DEFAULT].
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  CustomTabsShareState shareState;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool showTitle;

  ///Set the custom background color of the toolbar.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Color? toolbarBackgroundColor;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool enableUrlBarHiding;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool instantAppsEnabled;

  ///Set an explicit application package name that limits
  ///the components this Intent will resolve to.  If left to the default
  ///value of null, all components in all applications will considered.
  ///If non-null, the Intent can only match the components in the given
  ///application package.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  String? packageName;

  ///Set to `true` to enable Keep Alive. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool keepAliveEnabled;

  ///Set to `true` to launch the Android activity in `singleInstance` mode. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool isSingleInstance;

  ///Set to `true` to launch the Android intent with the flag `FLAG_ACTIVITY_NO_HISTORY`. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool noHistory;

  ///Set to `true` to launch the Custom Tab as a Trusted Web Activity. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool isTrustedWebActivity;

  ///Sets a list of additional trusted origins that the user may navigate or be redirected to from the starting uri.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  List<String> additionalTrustedOrigins;

  ///Sets a display mode of a Trusted Web Activity.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  TrustedWebActivityDisplayMode? displayMode;

  ///Sets a screen orientation. This can be used e.g. to enable the locking of an orientation lock type.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  TrustedWebActivityScreenOrientation screenOrientation;

  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool entersReaderIfAvailable;

  ///Set to `true` to enable bar collapsing. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool barCollapsingEnabled;

  ///Set the custom style for the dismiss button. The default value is [DismissButtonStyle.DONE].
  ///
  ///**NOTE**: available on iOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  DismissButtonStyle dismissButtonStyle;

  ///Set the custom background color of the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? preferredBarTintColor;

  ///Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? preferredControlTintColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [ModalPresentationStyle.FULL_SCREEN].
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ModalPresentationStyle presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ModalTransitionStyle transitionStyle;

  ChromeSafariBrowserSettings(
      {this.shareState = CustomTabsShareState.SHARE_STATE_DEFAULT,
      this.showTitle = true,
      this.toolbarBackgroundColor,
      this.enableUrlBarHiding = false,
      this.instantAppsEnabled = false,
      this.packageName,
      this.keepAliveEnabled = false,
      this.isSingleInstance = false,
      this.noHistory = false,
      this.isTrustedWebActivity = false,
      this.additionalTrustedOrigins = const [],
      this.displayMode,
      this.screenOrientation = TrustedWebActivityScreenOrientation.DEFAULT,
      this.entersReaderIfAvailable = false,
      this.barCollapsingEnabled = false,
      this.dismissButtonStyle = DismissButtonStyle.DONE,
      this.preferredBarTintColor,
      this.preferredControlTintColor,
      this.presentationStyle = ModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = ModalTransitionStyle.COVER_VERTICAL});

  @override
  Map<String, dynamic> toMap() {
    return {
      "shareState": shareState.toNativeValue(),
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor?.toHex(),
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled,
      "packageName": packageName,
      "keepAliveEnabled": keepAliveEnabled,
      "isSingleInstance": isSingleInstance,
      "noHistory": noHistory,
      "isTrustedWebActivity": isTrustedWebActivity,
      "additionalTrustedOrigins": additionalTrustedOrigins,
      "displayMode": displayMode?.toMap(),
      "screenOrientation": screenOrientation.toNativeValue(),
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle.toNativeValue(),
      "preferredBarTintColor": preferredBarTintColor?.toHex(),
      "preferredControlTintColor": preferredControlTintColor?.toHex(),
      "presentationStyle": presentationStyle.toNativeValue(),
      "transitionStyle": transitionStyle.toNativeValue()
    };
  }

  static ChromeSafariBrowserSettings fromMap(Map<String, dynamic> map) {
    ChromeSafariBrowserSettings settings = new ChromeSafariBrowserSettings();
    if (defaultTargetPlatform == TargetPlatform.android) {
      settings.shareState = map["shareState"];
      settings.showTitle = map["showTitle"];
      settings.toolbarBackgroundColor =
          UtilColor.fromHex(map["toolbarBackgroundColor"]);
      settings.enableUrlBarHiding = map["enableUrlBarHiding"];
      settings.instantAppsEnabled = map["instantAppsEnabled"];
      settings.packageName = map["packageName"];
      settings.keepAliveEnabled = map["keepAliveEnabled"];
      settings.isSingleInstance = map["isSingleInstance"];
      settings.noHistory = map["noHistory"];
      settings.isTrustedWebActivity = map["isTrustedWebActivity"];
      settings.additionalTrustedOrigins = map["additionalTrustedOrigins"];
      switch (map["displayMode"]["type"]) {
        case "IMMERSIVE_MODE":
          settings.displayMode = TrustedWebActivityImmersiveDisplayMode.fromMap(
              map["displayMode"]);
          break;
        case "DEFAULT_MODE":
        default:
          settings.displayMode = TrustedWebActivityDefaultDisplayMode();
          break;
      }
      settings.screenOrientation = map["screenOrientation"];
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      settings.entersReaderIfAvailable = map["entersReaderIfAvailable"];
      settings.barCollapsingEnabled = map["barCollapsingEnabled"];
      settings.dismissButtonStyle =
          DismissButtonStyle.fromNativeValue(map["dismissButtonStyle"])!;
      settings.preferredBarTintColor =
          UtilColor.fromHex(map["preferredBarTintColor"]);
      settings.preferredControlTintColor =
          UtilColor.fromHex(map["preferredControlTintColor"]);
      settings.presentationStyle =
          ModalPresentationStyle.fromNativeValue(map["presentationStyle"])!;
      settings.transitionStyle =
          ModalTransitionStyle.fromNativeValue(map["transitionStyle"])!;
    }
    return settings;
  }

  @override
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  ChromeSafariBrowserSettings copy() {
    return ChromeSafariBrowserSettings.fromMap(this.toMap());
  }
}

///Class that represents the options that can be used for an [ChromeSafariBrowser] window.
///Use [ChromeSafariBrowserSettings] instead.
@Deprecated('Use ChromeSafariBrowserSettings instead')
class ChromeSafariBrowserClassOptions {
  ///Android-specific options.
  AndroidChromeCustomTabsOptions? android;

  ///iOS-specific options.
  IOSSafariOptions? ios;

  ChromeSafariBrowserClassOptions({this.android, this.ios}) {
    this.android = this.android ?? AndroidChromeCustomTabsOptions();
    this.ios = this.ios ?? IOSSafariOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    if (defaultTargetPlatform == TargetPlatform.android)
      options.addAll(this.android?.toMap() ?? {});
    else if (defaultTargetPlatform == TargetPlatform.iOS)
      options.addAll(this.ios?.toMap() ?? {});

    return options;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
