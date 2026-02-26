import '../../in_app_webview/android/in_app_webview_options.dart';

import '../in_app_browser_settings.dart';
import '../platform_in_app_browser.dart';

///This class represents all the Android-only [PlatformInAppBrowser] options available.
///Use [InAppBrowserSettings] instead.
@Deprecated('Use InAppBrowserSettings instead')
class AndroidInAppBrowserOptions implements BrowserOptions, AndroidOptions {
  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  bool hideTitleBar;

  ///Set the action bar's title.
  String? toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  bool closeOnCannotGoBack;

  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  bool allowGoBackWithBackButton;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  bool shouldCloseOnBackButtonPressed;

  AndroidInAppBrowserOptions({
    this.hideTitleBar = false,
    this.toolbarTopFixedTitle,
    this.closeOnCannotGoBack = true,
    this.allowGoBackWithBackButton = true,
    this.shouldCloseOnBackButtonPressed = false,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "allowGoBackWithBackButton": allowGoBackWithBackButton,
      "shouldCloseOnBackButtonPressed": shouldCloseOnBackButtonPressed,
    };
  }

  static AndroidInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    var instance = AndroidInAppBrowserOptions();
    instance.hideTitleBar = map["hideTitleBar"];
    instance.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
    instance.closeOnCannotGoBack = map["closeOnCannotGoBack"];
    instance.allowGoBackWithBackButton = map["allowGoBackWithBackButton"];
    instance.shouldCloseOnBackButtonPressed =
        map["shouldCloseOnBackButtonPressed"];
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
  AndroidInAppBrowserOptions copy() {
    return AndroidInAppBrowserOptions.fromMap(this.toMap());
  }
}
