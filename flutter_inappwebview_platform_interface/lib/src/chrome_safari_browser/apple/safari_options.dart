import 'dart:ui';

import '../../util.dart';
import '../../types/main.dart';

import '../chrome_safari_browser_settings.dart';
import '../platform_chrome_safari_browser.dart';

import '../../in_app_webview/apple/in_app_webview_options.dart';

///This class represents all the iOS-only [PlatformChromeSafariBrowser] options available.
///Use [ChromeSafariBrowserSettings] instead.
@Deprecated('Use ChromeSafariBrowserSettings instead')
class IOSSafariOptions implements ChromeSafariBrowserOptions, IosOptions {
  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  bool entersReaderIfAvailable;

  ///Set to `true` to enable bar collapsing. The default value is `false`.
  bool barCollapsingEnabled;

  ///Set the custom style for the dismiss button. The default value is [IOSSafariDismissButtonStyle.DONE].
  ///
  ///**NOTE**: available on iOS 11.0+.
  IOSSafariDismissButtonStyle dismissButtonStyle;

  ///Set the custom background color of the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  Color? preferredBarTintColor;

  ///Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///
  ///**NOTE**: available on iOS 10.0+.
  Color? preferredControlTintColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [IOSUIModalPresentationStyle.FULL_SCREEN].
  IOSUIModalPresentationStyle presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [IOSUIModalTransitionStyle.COVER_VERTICAL].
  IOSUIModalTransitionStyle transitionStyle;

  IOSSafariOptions({
    this.entersReaderIfAvailable = false,
    this.barCollapsingEnabled = false,
    this.dismissButtonStyle = IOSSafariDismissButtonStyle.DONE,
    this.preferredBarTintColor,
    this.preferredControlTintColor,
    this.presentationStyle = IOSUIModalPresentationStyle.FULL_SCREEN,
    this.transitionStyle = IOSUIModalTransitionStyle.COVER_VERTICAL,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle.toNativeValue(),
      "preferredBarTintColor": preferredBarTintColor?.toHex(),
      "preferredControlTintColor": preferredControlTintColor?.toHex(),
      "presentationStyle": presentationStyle.toNativeValue(),
      "transitionStyle": transitionStyle.toNativeValue(),
    };
  }

  static IOSSafariOptions fromMap(Map<String, dynamic> map) {
    IOSSafariOptions options = IOSSafariOptions();
    options.entersReaderIfAvailable = map["entersReaderIfAvailable"];
    options.barCollapsingEnabled = map["barCollapsingEnabled"];
    options.dismissButtonStyle = IOSSafariDismissButtonStyle.fromNativeValue(
      map["dismissButtonStyle"],
    )!;
    options.preferredBarTintColor = UtilColor.fromHex(
      map["preferredBarTintColor"],
    );
    options.preferredControlTintColor = UtilColor.fromHex(
      map["preferredControlTintColor"],
    );
    options.presentationStyle = IOSUIModalPresentationStyle.fromNativeValue(
      map["presentationStyle"],
    )!;
    options.transitionStyle = IOSUIModalTransitionStyle.fromNativeValue(
      map["transitionStyle"],
    )!;
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
  IOSSafariOptions copy() {
    return IOSSafariOptions.fromMap(this.toMap());
  }
}
