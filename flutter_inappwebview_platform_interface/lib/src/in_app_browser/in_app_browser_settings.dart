import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/in_app_webview_rect.dart';
import '../types/modal_presentation_style.dart';
import '../types/modal_transition_style.dart';
import '../types/window_style_mask.dart';
import '../types/window_titlebar_separator_style.dart';
import '../types/window_type.dart';
import '../util.dart';

import '../in_app_webview/in_app_webview_settings.dart';

import 'android/in_app_browser_options.dart';
import '../in_app_webview/android/in_app_webview_options.dart';

import 'apple/in_app_browser_options.dart';
import '../in_app_webview/apple/in_app_webview_options.dart';
import '../types/enum_method.dart';

part 'in_app_browser_settings.g.dart';

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

    options.addAll(browserSettings.toMap());
    options.addAll(webViewSettings.toMap());

    return options;
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  String toString() {
    return toMap().toString();
  }

  factory InAppBrowserClassSettings.fromMap(Map<String, dynamic> options,
      {InAppBrowserClassSettings? instance, EnumMethod? enumMethod}) {
    if (instance == null) {
      instance = InAppBrowserClassSettings();
    }
    instance.browserSettings =
        InAppBrowserSettings.fromMap(options, enumMethod: enumMethod) ??
            InAppBrowserSettings();
    instance.webViewSettings =
        InAppWebViewSettings.fromMap(options, enumMethod: enumMethod) ??
            InAppWebViewSettings();
    return instance;
  }

  InAppBrowserClassSettings copy() {
    return InAppBrowserClassSettings.fromMap(toMap());
  }
}

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

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all [InAppBrowser] settings available.
///{@endtemplate}
@ExchangeableObject(copyMethod: true)
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
  WindowsPlatform()
])
class InAppBrowserSettings_
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform()
  ])
  bool? hidden;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()])
  bool? hideToolbarTop;

  ///Set the custom background color of the toolbar at the top.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()])
  Color_? toolbarTopBackgroundColor;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()])
  bool? hideUrlBar;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()])
  bool? hideProgressBar;

  ///Set to `true` to hide the default menu items. The default value is `false`.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()])
  bool? hideDefaultMenuItems;

  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? hideTitleBar;

  ///Set the action bar's title.
  @SupportedPlatforms(
      platforms: [AndroidPlatform(), MacOSPlatform(), WindowsPlatform()])
  String? toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? closeOnCannotGoBack;

  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? allowGoBackWithBackButton;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  bool? shouldCloseOnBackButtonPressed;

  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? toolbarTopTranslucent;

  ///Set the tint color to apply to the navigation bar background.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? toolbarTopBarTintColor;

  ///Set the tint color to apply to the navigation items and bar button items.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? toolbarTopTintColor;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? hideToolbarBottom;

  ///Set the custom background color of the toolbar at the bottom.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? toolbarBottomTranslucent;

  ///Set the custom text for the close button.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? closeButtonColor;

  ///Set to `true` to hide the close button. The default value is `false`.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  bool? hideCloseButton;

  ///Set the custom color for the menu button.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Color_? menuButtonColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [ModalPresentationStyle.FULL_SCREEN].
  @SupportedPlatforms(platforms: [IOSPlatform()])
  ModalPresentationStyle_? presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  @SupportedPlatforms(platforms: [IOSPlatform()])
  ModalTransitionStyle_? transitionStyle;

  ///How the browser window should be added to the main window.
  ///The default value is [WindowType.WINDOW].
  @SupportedPlatforms(platforms: [MacOSPlatform(), WindowsPlatform()])
  WindowType_? windowType;

  ///The window’s alpha value.
  ///The default value is `1.0`.
  @SupportedPlatforms(platforms: [MacOSPlatform(), WindowsPlatform()])
  double? windowAlphaValue;

  ///Flags that describe the window’s current style, such as if it’s resizable or in full-screen mode.
  @SupportedPlatforms(platforms: [MacOSPlatform()])
  WindowStyleMask_? windowStyleMask;

  ///The type of separator that the app displays between the title bar and content of a window.
  @SupportedPlatforms(platforms: [MacOSPlatform(available: '11.0')])
  WindowTitlebarSeparatorStyle_? windowTitlebarSeparatorStyle;

  ///Sets the origin and size of the window’s frame rectangle according to a given frame rectangle,
  ///thereby setting its position and size onscreen.
  @SupportedPlatforms(platforms: [MacOSPlatform(), WindowsPlatform()])
  InAppWebViewRect_? windowFrame;

  InAppBrowserSettings_(
      {this.hidden = false,
      this.hideToolbarTop = false,
      this.toolbarTopBackgroundColor,
      this.hideUrlBar = false,
      this.hideProgressBar = false,
      this.hideDefaultMenuItems = false,
      this.toolbarTopTranslucent = true,
      this.toolbarTopTintColor,
      this.hideToolbarBottom = false,
      this.toolbarBottomBackgroundColor,
      this.toolbarBottomTintColor,
      this.toolbarBottomTranslucent = true,
      this.closeButtonCaption,
      this.closeButtonColor,
      this.hideCloseButton = false,
      this.menuButtonColor,
      this.presentationStyle = ModalPresentationStyle_.FULL_SCREEN,
      this.transitionStyle = ModalTransitionStyle_.COVER_VERTICAL,
      this.hideTitleBar = false,
      this.toolbarTopFixedTitle,
      this.closeOnCannotGoBack = true,
      this.allowGoBackWithBackButton = true,
      this.shouldCloseOnBackButtonPressed = false,
      this.windowType,
      this.windowAlphaValue = 1.0,
      this.windowStyleMask,
      this.windowTitlebarSeparatorStyle,
      this.windowFrame});

  @override
  @ExchangeableObjectMethod(ignore: true)
  InAppBrowserSettings_ copy() {
    throw UnimplementedError();
  }

  @override
  @ExchangeableObjectMethod(ignore: true)
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  @ExchangeableObjectMethod(ignore: true)
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(InAppBrowserSettingsProperty property,
          {TargetPlatform? platform}) =>
      _InAppBrowserSettingsPropertySupported.isPropertySupported(property,
          platform: platform);
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
    if (Util.isAndroid) {
      options.addAll(this.android.toMap());
      options.addAll(this.inAppWebViewGroupOptions.android.toMap());
    } else if (Util.isIOS) {
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

  static InAppBrowserClassOptions fromMap(Map<String, dynamic> options,
      {EnumMethod? enumMethod}) {
    InAppBrowserClassOptions inAppBrowserClassOptions =
        InAppBrowserClassOptions();

    inAppBrowserClassOptions.crossPlatform =
        InAppBrowserOptions.fromMap(options);
    inAppBrowserClassOptions.inAppWebViewGroupOptions =
        InAppWebViewGroupOptions();
    inAppBrowserClassOptions.inAppWebViewGroupOptions.crossPlatform =
        InAppWebViewOptions.fromMap(options);
    if (Util.isAndroid) {
      inAppBrowserClassOptions.android =
          AndroidInAppBrowserOptions.fromMap(options);
      inAppBrowserClassOptions.inAppWebViewGroupOptions.android =
          AndroidInAppWebViewOptions.fromMap(options);
    } else if (Util.isIOS) {
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
