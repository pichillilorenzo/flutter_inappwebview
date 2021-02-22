import 'dart:ui';

import '../../util.dart';

import '../chrome_safari_browser_options.dart';
import '../chrome_safari_browser.dart';

import '../../in_app_webview/android/in_app_webview_options.dart';

///This class represents all the Android-only [ChromeSafariBrowser] options available.
class AndroidChromeCustomTabsOptions
    implements ChromeSafariBrowserOptions, AndroidOptions {
  ///Set to `false` if you don't want the default share item to the menu. The default value is `true`.
  bool addDefaultShareMenuItem;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  bool showTitle;

  ///Set the custom background color of the toolbar.
  Color? toolbarBackgroundColor;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  bool enableUrlBarHiding;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  bool instantAppsEnabled;

  ///Set an explicit application package name that limits
  ///the components this Intent will resolve to.  If left to the default
  ///value of null, all components in all applications will considered.
  ///If non-null, the Intent can only match the components in the given
  ///application package.
  String? packageName;

  ///Set to `true` to enable Keep Alive. The default value is `false`.
  bool keepAliveEnabled;

  AndroidChromeCustomTabsOptions(
      {this.addDefaultShareMenuItem = true,
      this.showTitle = true,
      this.toolbarBackgroundColor,
      this.enableUrlBarHiding = false,
      this.instantAppsEnabled = false,
      this.packageName,
      this.keepAliveEnabled = false});

  @override
  Map<String, dynamic> toMap() {
    return {
      "addDefaultShareMenuItem": addDefaultShareMenuItem,
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor?.toHex(),
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled,
      "packageName": packageName,
      "keepAliveEnabled": keepAliveEnabled
    };
  }

  static AndroidChromeCustomTabsOptions fromMap(Map<String, dynamic> map) {
    AndroidChromeCustomTabsOptions options =
        new AndroidChromeCustomTabsOptions();
    options.addDefaultShareMenuItem = map["addDefaultShareMenuItem"];
    options.showTitle = map["showTitle"];
    options.toolbarBackgroundColor =
        UtilColor.fromHex(map["toolbarBackgroundColor"]);
    options.enableUrlBarHiding = map["enableUrlBarHiding"];
    options.instantAppsEnabled = map["instantAppsEnabled"];
    options.packageName = map["packageName"];
    options.keepAliveEnabled = map["keepAliveEnabled"];
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
  AndroidChromeCustomTabsOptions copy() {
    return AndroidChromeCustomTabsOptions.fromMap(this.toMap());
  }
}
