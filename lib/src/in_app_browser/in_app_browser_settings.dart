import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/src/types.dart';

import '../util.dart';

import '../in_app_webview/in_app_webview_settings.dart';

import 'android/in_app_browser_options.dart';
import '../in_app_webview/android/in_app_webview_options.dart';

import 'apple/in_app_browser_options.dart';
import '../in_app_webview/apple/in_app_webview_options.dart';

class BrowserOptions {
  Map<String, dynamic> toMap() {
    return {};
  }

  static BrowserOptions fromMap(Map<String, dynamic> map) {
    return BrowserOptions();
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

///Class that represents the settings that can be used for an [InAppBrowser] instance.
class InAppBrowserClassSettings {
  ///Browser settings.
  late InAppBrowserSettings browserSettings;

  ///WebView settings.
  late InAppWebViewSettings webViewSettings;

  InAppBrowserClassSettings(
      {InAppBrowserSettings? browserSettings,
      InAppWebViewSettings? webViewSettings}) {
    this.browserSettings = browserSettings ?? InAppBrowserSettings();
    this.webViewSettings = webViewSettings ?? InAppWebViewSettings();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> options = {};

    options.addAll(this.browserSettings.toMap());
    options.addAll(this.webViewSettings.toMap());

    return options;
  }

  static Map<String, dynamic> instanceToMap(
      InAppBrowserClassSettings settings) {
    return settings.toMap();
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }

  static InAppBrowserClassSettings fromMap(Map<String, dynamic> options,
      {InAppBrowserClassSettings? instance}) {
    if (instance == null) {
      instance = InAppBrowserClassSettings();
    }
    instance.browserSettings = InAppBrowserSettings.fromMap(options);
    instance.webViewSettings = InAppWebViewSettings.fromMap(options);
    return instance;
  }

  InAppBrowserClassSettings copy() {
    return InAppBrowserClassSettings.fromMap(this.toMap());
  }
}

///This class represents all [InAppBrowser] settings available.
class InAppBrowserSettings
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool hidden;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool hideToolbarTop;

  ///Set the custom background color of the toolbar at the top.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Color? toolbarTopBackgroundColor;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool hideUrlBar;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  bool hideProgressBar;

  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool hideTitleBar;

  ///Set the action bar's title.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  String? toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool closeOnCannotGoBack;

  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool allowGoBackWithBackButton;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool shouldCloseOnBackButtonPressed;

  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool toolbarTopTranslucent;

  ///Set the tint color to apply to the navigation bar background.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopBarTintColor;

  ///Set the tint color to apply to the navigation items and bar button items.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopTintColor;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool hideToolbarBottom;

  ///Set the custom background color of the toolbar at the bottom.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool toolbarBottomTranslucent;

  ///Set the custom text for the close button.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? closeButtonColor;

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

  InAppBrowserSettings(
      {this.hidden = false,
      this.hideToolbarTop = false,
      this.toolbarTopBackgroundColor,
      this.hideUrlBar = false,
      this.hideProgressBar = false,
      this.toolbarTopTranslucent = true,
      this.toolbarTopTintColor,
      this.hideToolbarBottom = false,
      this.toolbarBottomBackgroundColor,
      this.toolbarBottomTintColor,
      this.toolbarBottomTranslucent = true,
      this.closeButtonCaption,
      this.closeButtonColor,
      this.presentationStyle = ModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = ModalTransitionStyle.COVER_VERTICAL,
      this.hideTitleBar = false,
      this.toolbarTopFixedTitle,
      this.closeOnCannotGoBack = true,
      this.allowGoBackWithBackButton = true,
      this.shouldCloseOnBackButtonPressed = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "hideToolbarTop": hideToolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor?.toHex(),
      "hideUrlBar": hideUrlBar,
      "hideProgressBar": hideProgressBar,
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "allowGoBackWithBackButton": allowGoBackWithBackButton,
      "shouldCloseOnBackButtonPressed": shouldCloseOnBackButtonPressed,
      "toolbarTopTranslucent": toolbarTopTranslucent,
      "toolbarTopTintColor": toolbarTopTintColor?.toHex(),
      "hideToolbarBottom": hideToolbarBottom,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor?.toHex(),
      "toolbarBottomTintColor": toolbarBottomTintColor?.toHex(),
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor?.toHex(),
      "presentationStyle": presentationStyle.toValue(),
      "transitionStyle": transitionStyle.toValue(),
    };
  }

  static InAppBrowserSettings fromMap(Map<String, dynamic> map) {
    var settings = InAppBrowserSettings();
    settings.hidden = map["hidden"];
    settings.hideToolbarTop = map["hideToolbarTop"];
    settings.toolbarTopBackgroundColor =
        UtilColor.fromHex(map["toolbarTopBackgroundColor"]);
    settings.hideUrlBar = map["hideUrlBar"];
    settings.hideProgressBar = map["hideProgressBar"];
    if (Platform.isAndroid) {
      settings.hideTitleBar = map["hideTitleBar"];
      settings.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
      settings.closeOnCannotGoBack = map["closeOnCannotGoBack"];
      settings.allowGoBackWithBackButton = map["allowGoBackWithBackButton"];
      settings.shouldCloseOnBackButtonPressed =
          map["shouldCloseOnBackButtonPressed"];
    }
    if (Platform.isIOS || Platform.isMacOS) {
      settings.toolbarTopTranslucent = map["toolbarTopTranslucent"];
      settings.toolbarTopTintColor =
          UtilColor.fromHex(map["toolbarTopTintColor"]);
      settings.hideToolbarBottom = map["hideToolbarBottom"];
      settings.toolbarBottomBackgroundColor =
          UtilColor.fromHex(map["toolbarBottomBackgroundColor"]);
      settings.toolbarBottomTintColor =
          UtilColor.fromHex(map["toolbarBottomTintColor"]);
      settings.toolbarBottomTranslucent = map["toolbarBottomTranslucent"];
      settings.closeButtonCaption = map["closeButtonCaption"];
      settings.closeButtonColor = UtilColor.fromHex(map["closeButtonColor"]);
      settings.presentationStyle =
          ModalPresentationStyle.fromValue(map["presentationStyle"])!;
      settings.transitionStyle =
          ModalTransitionStyle.fromValue(map["transitionStyle"])!;
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
///Use [InAppBrowserClassSettings] instead.
@Deprecated('Use InAppBrowserClassSettings instead')
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
    var instance = InAppBrowserOptions();
    instance.hidden = map["hidden"];
    instance.hideToolbarTop = map["hideToolbarTop"];
    instance.toolbarTopBackgroundColor =
        UtilColor.fromHex(map["toolbarTopBackgroundColor"]);
    instance.hideUrlBar = map["hideUrlBar"];
    instance.hideProgressBar = map["hideProgressBar"];
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
  InAppBrowserOptions copy() {
    return InAppBrowserOptions.fromMap(this.toMap());
  }
}
