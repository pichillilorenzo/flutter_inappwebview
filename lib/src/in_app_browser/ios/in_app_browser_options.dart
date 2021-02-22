import 'dart:ui';

import '../../in_app_webview/ios/in_app_webview_options.dart';

import '../in_app_browser_options.dart';
import '../in_app_browser.dart';

import '../../types.dart';
import '../../util.dart';

///This class represents all the iOS-only [InAppBrowser] options available.
class IOSInAppBrowserOptions implements BrowserOptions, IosOptions {
  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  bool toolbarTopTranslucent;

  ///Set the tint color to apply to the navigation bar background.
  Color? toolbarTopBarTintColor;

  ///Set the tint color to apply to the navigation items and bar button items.
  Color? toolbarTopTintColor;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  bool hideToolbarBottom;

  ///Set the custom background color of the toolbar at the bottom.
  Color? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  Color? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  bool toolbarBottomTranslucent;

  ///Set the custom text for the close button.
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  Color? closeButtonColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [IOSUIModalPresentationStyle.FULL_SCREEN].
  IOSUIModalPresentationStyle presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [IOSUIModalTransitionStyle.COVER_VERTICAL].
  IOSUIModalTransitionStyle transitionStyle;

  IOSInAppBrowserOptions(
      {this.toolbarTopTranslucent = true,
      this.toolbarTopTintColor,
      this.hideToolbarBottom = false,
      this.toolbarBottomBackgroundColor,
      this.toolbarBottomTintColor,
      this.toolbarBottomTranslucent = true,
      this.closeButtonCaption,
      this.closeButtonColor,
      this.presentationStyle = IOSUIModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = IOSUIModalTransitionStyle.COVER_VERTICAL});

  @override
  Map<String, dynamic> toMap() {
    return {
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

  static IOSInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    IOSInAppBrowserOptions options = IOSInAppBrowserOptions();
    options.toolbarTopTranslucent = map["toolbarTopTranslucent"];
    options.toolbarTopTintColor = UtilColor.fromHex(map["toolbarTopTintColor"]);
    options.hideToolbarBottom = map["hideToolbarBottom"];
    options.toolbarBottomBackgroundColor =
        UtilColor.fromHex(map["toolbarBottomBackgroundColor"]);
    options.toolbarBottomTintColor =
        UtilColor.fromHex(map["toolbarBottomTintColor"]);
    options.toolbarBottomTranslucent = map["toolbarBottomTranslucent"];
    options.closeButtonCaption = map["closeButtonCaption"];
    options.closeButtonColor = UtilColor.fromHex(map["closeButtonColor"]);
    options.presentationStyle =
        IOSUIModalPresentationStyle.fromValue(map["presentationStyle"])!;
    options.transitionStyle =
        IOSUIModalTransitionStyle.fromValue(map["transitionStyle"])!;
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
  IOSInAppBrowserOptions copy() {
    return IOSInAppBrowserOptions.fromMap(this.toMap());
  }
}
