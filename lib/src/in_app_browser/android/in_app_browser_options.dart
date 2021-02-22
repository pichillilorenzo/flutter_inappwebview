import '../../in_app_webview/android/in_app_webview_options.dart';

import '../in_app_browser_options.dart';
import '../in_app_browser.dart';

///This class represents all the Android-only [InAppBrowser] options available.
class AndroidInAppBrowserOptions implements BrowserOptions, AndroidOptions {
  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  bool hideTitleBar;

  ///Set the action bar's title.
  String? toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the back button and the WebView cannot go back to the history. The default value is `true`.
  bool closeOnCannotGoBack;

  AndroidInAppBrowserOptions(
      {this.hideTitleBar = false,
      this.toolbarTopFixedTitle,
      this.closeOnCannotGoBack = true});

  @override
  Map<String, dynamic> toMap() {
    return {
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
    };
  }

  static AndroidInAppBrowserOptions fromMap(Map<String, dynamic> map) {
    AndroidInAppBrowserOptions options = AndroidInAppBrowserOptions();
    options.hideTitleBar = map["hideTitleBar"];
    options.toolbarTopFixedTitle = map["toolbarTopFixedTitle"];
    options.closeOnCannotGoBack = map["closeOnCannotGoBack"];
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
  AndroidInAppBrowserOptions copy() {
    return AndroidInAppBrowserOptions.fromMap(this.toMap());
  }
}
