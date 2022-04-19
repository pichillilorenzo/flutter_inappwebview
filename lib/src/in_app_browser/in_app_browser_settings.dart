import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/src/types.dart';

import '../util.dart';

import '../in_app_webview/in_app_webview_settings.dart';

import 'android/in_app_browser_options.dart';
import '../in_app_webview/android/in_app_webview_settings.dart';

import 'ios/in_app_browser_settings.dart';
import '../in_app_webview/ios/in_app_webview_settings.dart';

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static BrowserOptions fromMap(Map<String, dynamic> map, {BrowserOptions? instance}) {
    return BrowserOptions();
  }

  static Map<String, dynamic> instanceToMap(BrowserOptions options) {
    return options.toMap();
  }

  BrowserOptions copy() {
    return BrowserOptions.fromMap(this.toMap());
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents the settings that can be used for an [InAppBrowser] WebView.
class InAppBrowserClassSettings {
  ///Browser settings.
  late InAppBrowserSettings settings;

  ///WebView settings.
  late InAppWebViewSettings webViewSettings;

  InAppBrowserClassSettings(
      {InAppBrowserSettings? settings,
        InAppWebViewSettings? webViewSettings}) {
    this.settings = settings ?? InAppBrowserSettings();
    this.webViewSettings = webViewSettings ?? InAppWebViewSettings();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};

    options.addAll(this.settings.toMap());
    options.addAll(this.webViewSettings.toMap());

    return options;
  }

  static Map<String, dynamic> instanceToMap(InAppBrowserClassSettings settings) {
    return settings.toMap();
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static InAppBrowserClassSettings fromMap(Map<String, dynamic> options, {InAppBrowserClassSettings? instance}) {
    if (instance == null) {
      instance = InAppBrowserClassSettings();
    }
    instance.settings = InAppBrowserSettings.fromMap(options);
    instance.webViewSettings = InAppWebViewSettings.fromMap(options);
    return instance;
  }

  InAppBrowserClassSettings copy() {
    return InAppBrowserClassSettings.fromMap(this.toMap());
  }
}

class InAppBrowserSettings extends InAppBrowserOptions implements AndroidInAppBrowserOptions, IOSInAppBrowserOptions {
  @override
  bool allowGoBackWithBackButton;

  @override
  String? closeButtonCaption;

  @override
  Color? closeButtonColor;

  @override
  bool closeOnCannotGoBack;

  @override
  bool hideTitleBar;

  @override
  bool hideToolbarBottom;

  @override
  IOSUIModalPresentationStyle presentationStyle;

  @override
  bool shouldCloseOnBackButtonPressed;

  @override
  Color? toolbarBottomBackgroundColor;

  @override
  Color? toolbarBottomTintColor;

  @override
  bool toolbarBottomTranslucent;

  @override
  Color? toolbarTopBarTintColor;

  @override
  String? toolbarTopFixedTitle;

  @override
  Color? toolbarTopTintColor;

  @override
  bool toolbarTopTranslucent;

  @override
  IOSUIModalTransitionStyle transitionStyle;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};
    // ignore: deprecated_member_use_from_same_package
    options.addAll(InAppBrowserOptions.instanceToMap(this));
    options.addAll(AndroidInAppBrowserSettings.instanceToMap(this));
    options.addAll(IOSInAppBrowserSettings.instanceToMap(this));
    return options;
  }

  static Map<String, dynamic> instanceToMap(InAppBrowserSettings settings) {
    return settings.toMap();
  }

  static InAppBrowserSettings fromMap(Map<String, dynamic> options, {InAppBrowserSettings? instance}) {
    if (instance == null) {
      instance = InAppBrowserSettings();
    }
    // ignore: deprecated_member_use_from_same_package
    InAppBrowserOptions.fromMap(options, instance: instance);
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidInAppBrowserSettings.fromMap(options, instance: instance);
    }
    else if (defaultTargetPlatform == TargetPlatform.iOS) {
      IOSInAppBrowserSettings.fromMap(options, instance: instance);
    }
    return instance;
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
  InAppBrowserSettings copy() {
    return InAppBrowserSettings.fromMap(this.toMap());
  }
}

///Class that represents the options that can be used for an [InAppBrowser] WebView.
///Use [InAppBrowserClassSettings] instead.
@Deprecated('Use InAppBrowserClassSettings instead')
class InAppBrowserClassOptions {
  ///Cross-platform options.
  late InAppBrowserOptions crossPlatform;

  ///Android-specific options.
  late AndroidInAppBrowserOptions android;

  ///iOS-specific options.
  late IOSInAppBrowserOptions ios;

  ///WebView options.
  late InAppWebViewGroupOptions inAppWebViewGroupOptions;

  InAppBrowserClassOptions(
      {InAppBrowserOptions? crossPlatform,
      AndroidInAppBrowserOptions? android,
      IOSInAppBrowserOptions? ios,
      InAppWebViewGroupOptions? inAppWebViewGroupOptions}) {
    this.crossPlatform = crossPlatform ?? InAppBrowserOptions();
    this.android = android ?? AndroidInAppBrowserOptions();
    this.ios = ios ?? IOSInAppBrowserOptions();
    this.inAppWebViewGroupOptions =
        inAppWebViewGroupOptions ?? InAppWebViewGroupOptions();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};

    options.addAll(this.crossPlatform.toMap());
    options.addAll(this.inAppWebViewGroupOptions.crossPlatform.toMap());
    if (defaultTargetPlatform == TargetPlatform.android) {
      options.addAll(this.android.toMap());
      options.addAll(this.inAppWebViewGroupOptions.android.toMap());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      options.addAll(this.ios.toMap());
      options.addAll(this.inAppWebViewGroupOptions.ios.toMap());
    }

    return options;
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static InAppBrowserClassOptions fromMap(Map<String, dynamic> options) {
    InAppBrowserClassOptions inAppBrowserClassOptions =
        InAppBrowserClassOptions();

    inAppBrowserClassOptions.crossPlatform =
        InAppBrowserOptions.fromMap(options);
    inAppBrowserClassOptions.inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();
    inAppBrowserClassOptions.inAppWebViewGroupOptions.crossPlatform =
        InAppWebViewOptions.fromMap(options);
    if (defaultTargetPlatform == TargetPlatform.android) {
      inAppBrowserClassOptions.android =
          AndroidInAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewGroupOptions.android =
          AndroidInAppWebViewOptions.fromMap(options);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      inAppBrowserClassOptions.ios = IOSInAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewGroupOptions.ios =
          IOSInAppWebViewOptions.fromMap(options);
    }

    return inAppBrowserClassOptions;
  }

  InAppBrowserClassOptions copy() {
    return InAppBrowserClassOptions.fromMap(this.toMap());
  }
}

///This class represents all the cross-platform [InAppBrowser] options available.
class InAppBrowserOptions
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  bool hidden;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  bool hideToolbarTop;

  ///Set the custom background color of the toolbar at the top.
  Color? toolbarTopBackgroundColor;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  bool hideUrlBar;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  bool hideProgressBar;

  InAppBrowserOptions(
      {this.hidden = false,
      this.hideToolbarTop = false,
      this.toolbarTopBackgroundColor,
      this.hideUrlBar = false,
      this.hideProgressBar = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "hideToolbarTop": hideToolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor?.toHex(),
      "hideUrlBar": hideUrlBar,
      "hideProgressBar": hideProgressBar
    };
  }

  static InAppBrowserOptions fromMap(Map<String, dynamic> map) {
    InAppBrowserOptions options = InAppBrowserOptions();
    options.hidden = map["hidden"];
    options.hideToolbarTop = map["hideToolbarTop"];
    options.toolbarTopBackgroundColor =
        UtilColor.fromHex(map["toolbarTopBackgroundColor"]);
    options.hideUrlBar = map["hideUrlBar"];
    options.hideProgressBar = map["hideProgressBar"];
    return options;
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
  InAppBrowserOptions copy() {
    return InAppBrowserOptions.fromMap(this.toMap());
  }
}
