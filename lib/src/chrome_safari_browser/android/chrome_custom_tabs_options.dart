import 'dart:ui';

import '../../util.dart';
import '../../types.dart';

import '../chrome_safari_browser_options.dart';
import '../chrome_safari_browser.dart';

import '../../in_app_webview/android/in_app_webview_options.dart';

///This class represents all the Android-only [ChromeSafariBrowser] options available.
class AndroidChromeCustomTabsOptions
    implements ChromeSafariBrowserOptions, AndroidOptions {
  ///Use [shareState] instead.
  @Deprecated('Use `shareState` instead')
  bool? addDefaultShareMenuItem;

  ///The share state that should be applied to the custom tab. The default value is [CustomTabsShareState.SHARE_STATE_DEFAULT].
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  CustomTabsShareState shareState;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  bool showTitle;

  ///Set the custom background color of the toolbar.
  Color? toolbarBackgroundColor;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  bool enableUrlBarHiding;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  bool instantAppsEnabled;

  ///Set an explicit application package name that limits
  ///the components this Intent will resolve to.  If left to the default
  ///value of null, all components in all applications will considered.
  ///If non-null, the Intent can only match the components in the given
  ///application package.
  String? packageName;

  ///Set to `true` to enable Keep Alive. The default value is `false`.
  bool keepAliveEnabled;

  ///Set to `true` to launch the Android activity in `singleInstance` mode. The default value is `false`.
  bool isSingleInstance;

  ///Set to `true` to launch the Android intent with the flag `FLAG_ACTIVITY_NO_HISTORY`. The default value is `false`.
  bool noHistory;

  ///Set to `true` to launch the Custom Tab as a Trusted Web Activity. The default value is `false`.
  bool isTrustedWebActivity;

  ///Sets a list of additional trusted origins that the user may navigate or be redirected to from the starting uri.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  List<String> additionalTrustedOrigins;

  ///Sets a display mode of a Trusted Web Activity.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  TrustedWebActivityDisplayMode? displayMode;

  ///Sets a screen orientation. This can be used e.g. to enable the locking of an orientation lock type.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  TrustedWebActivityScreenOrientation screenOrientation;

  AndroidChromeCustomTabsOptions(
      {@Deprecated('Use `shareState` instead') this.addDefaultShareMenuItem,
      this.shareState = CustomTabsShareState.SHARE_STATE_DEFAULT,
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
      this.screenOrientation = TrustedWebActivityScreenOrientation.DEFAULT});

  @override
  Map<String, dynamic> toMap() {
    return {
      // ignore: deprecated_member_use_from_same_package
      "addDefaultShareMenuItem": addDefaultShareMenuItem,
      "shareState": shareState.toValue(),
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
      "screenOrientation": screenOrientation.toValue()
    };
  }

  static AndroidChromeCustomTabsOptions fromMap(Map<String, dynamic> map) {
    AndroidChromeCustomTabsOptions options =
        new AndroidChromeCustomTabsOptions();
    // ignore: deprecated_member_use_from_same_package
    options.addDefaultShareMenuItem = map["addDefaultShareMenuItem"];
    options.shareState = map["shareState"];
    options.showTitle = map["showTitle"];
    options.toolbarBackgroundColor =
        UtilColor.fromHex(map["toolbarBackgroundColor"]);
    options.enableUrlBarHiding = map["enableUrlBarHiding"];
    options.instantAppsEnabled = map["instantAppsEnabled"];
    options.packageName = map["packageName"];
    options.keepAliveEnabled = map["keepAliveEnabled"];
    options.isSingleInstance = map["isSingleInstance"];
    options.noHistory = map["noHistory"];
    options.isTrustedWebActivity = map["isTrustedWebActivity"];
    options.additionalTrustedOrigins = map["additionalTrustedOrigins"];
    switch (map["displayMode"]["type"]) {
      case "IMMERSIVE_MODE":
        options.displayMode =
            TrustedWebActivityImmersiveDisplayMode.fromMap(map["displayMode"]);
        break;
      case "DEFAULT_MODE":
      default:
        options.displayMode = TrustedWebActivityDefaultDisplayMode();
        break;
    }
    options.screenOrientation = map["screenOrientation"];
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
