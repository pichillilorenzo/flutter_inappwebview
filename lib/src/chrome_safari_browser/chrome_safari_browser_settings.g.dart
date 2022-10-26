// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrome_safari_browser_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings that can be used for an [ChromeSafariBrowser] window.
class ChromeSafariBrowserSettings implements ChromeSafariBrowserOptions {
  ///The share state that should be applied to the custom tab. The default value is [CustomTabsShareState.SHARE_STATE_DEFAULT].
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  CustomTabsShareState? shareState;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? showTitle;

  ///Set the custom background color of the toolbar.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Color? toolbarBackgroundColor;

  ///Sets the navigation bar color. Has no effect on Android API versions below L.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Color? navigationBarColor;

  ///Sets the navigation bar divider color. Has no effect on Android API versions below P.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Color? navigationBarDividerColor;

  ///Sets the color of the secondary toolbar.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Color? secondaryToolbarColor;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? enableUrlBarHiding;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? instantAppsEnabled;

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
  bool? keepAliveEnabled;

  ///Set to `true` to launch the Android activity in `singleInstance` mode. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? isSingleInstance;

  ///Set to `true` to launch the Android intent with the flag `FLAG_ACTIVITY_NO_HISTORY`. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? noHistory;

  ///Set to `true` to launch the Custom Tab as a Trusted Web Activity. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? isTrustedWebActivity;

  ///Sets a list of additional trusted origins that the user may navigate or be redirected to from the starting uri.
  ///
  ///**NOTE**: Available only in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  List<String>? additionalTrustedOrigins;

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
  TrustedWebActivityScreenOrientation? screenOrientation;

  ///Sets the start animations.
  ///It must contain 2 [AndroidResource], where the first one represents the "enter" animation for the browser
  ///and the second one represents the "exit" animation for the application.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  List<AndroidResource>? startAnimations;

  ///Sets the exit animations.
  ///It must contain 2 [AndroidResource], where the first one represents the "enter" animation for the application
  ///and the second one represents the "exit" animation for the browser.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  List<AndroidResource>? exitAnimations;

  ///Adds the necessary flags and extras to signal any browser supporting custom tabs to use the browser UI
  ///at all times and avoid showing custom tab like UI.
  ///Calling this with an intent will override any custom tabs related customizations.
  ///The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  bool? alwaysUseBrowserUI;

  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? entersReaderIfAvailable;

  ///Set to `true` to enable bar collapsing. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? barCollapsingEnabled;

  ///Set the custom style for the dismiss button. The default value is [DismissButtonStyle.DONE].
  ///
  ///**NOTE**: available on iOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  DismissButtonStyle? dismissButtonStyle;

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
  ModalPresentationStyle? presentationStyle;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ModalTransitionStyle? transitionStyle;

  ///An additional button to be shown in `SFSafariViewController`'s toolbar.
  ///This allows the user to access powerful functionality from your extension without needing to first show the `UIActivityViewController`.
  ///
  ///**NOTE**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  ActivityButton? activityButton;

  ///An event attribution associated with a click that caused this `SFSafariViewController` to be opened.
  ///This attribute is ignored if the `SFSafariViewController` url has a scheme of 'http'.
  ///
  ///**NOTE**: available on iOS 15.2+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  UIEventAttribution? eventAttribution;
  ChromeSafariBrowserSettings(
      {this.shareState = CustomTabsShareState.SHARE_STATE_DEFAULT,
      this.showTitle = true,
      this.toolbarBackgroundColor,
      this.navigationBarColor,
      this.navigationBarDividerColor,
      this.secondaryToolbarColor,
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
      this.startAnimations,
      this.exitAnimations,
      this.alwaysUseBrowserUI = false,
      this.entersReaderIfAvailable = false,
      this.barCollapsingEnabled = false,
      this.dismissButtonStyle = DismissButtonStyle.DONE,
      this.preferredBarTintColor,
      this.preferredControlTintColor,
      this.presentationStyle = ModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = ModalTransitionStyle.COVER_VERTICAL,
      this.activityButton,
      this.eventAttribution}) {
    if (startAnimations != null) {
      assert(startAnimations!.length == 2,
          "start animations must be have 2 android resources");
    }
    if (exitAnimations != null) {
      assert(exitAnimations!.length == 2,
          "exit animations must be have 2 android resources");
    }
  }

  ///Gets a possible [ChromeSafariBrowserSettings] instance from a [Map] value.
  static ChromeSafariBrowserSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserSettings(
      toolbarBackgroundColor: map['toolbarBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarBackgroundColor'])
          : null,
      navigationBarColor: map['navigationBarColor'] != null
          ? UtilColor.fromStringRepresentation(map['navigationBarColor'])
          : null,
      navigationBarDividerColor: map['navigationBarDividerColor'] != null
          ? UtilColor.fromStringRepresentation(map['navigationBarDividerColor'])
          : null,
      secondaryToolbarColor: map['secondaryToolbarColor'] != null
          ? UtilColor.fromStringRepresentation(map['secondaryToolbarColor'])
          : null,
      packageName: map['packageName'],
      displayMode: _deserializeDisplayMode(map['displayMode']),
      startAnimations: map['startAnimations'] != null
          ? List<AndroidResource>.from(map['startAnimations']
              .map((e) => AndroidResource.fromMap(e?.cast<String, dynamic>())!))
          : null,
      exitAnimations: map['exitAnimations'] != null
          ? List<AndroidResource>.from(map['exitAnimations']
              .map((e) => AndroidResource.fromMap(e?.cast<String, dynamic>())!))
          : null,
      preferredBarTintColor: map['preferredBarTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['preferredBarTintColor'])
          : null,
      preferredControlTintColor: map['preferredControlTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['preferredControlTintColor'])
          : null,
      activityButton: ActivityButton.fromMap(
          map['activityButton']?.cast<String, dynamic>()),
      eventAttribution: UIEventAttribution.fromMap(
          map['eventAttribution']?.cast<String, dynamic>()),
    );
    instance.shareState =
        CustomTabsShareState.fromNativeValue(map['shareState']);
    instance.showTitle = map['showTitle'];
    instance.enableUrlBarHiding = map['enableUrlBarHiding'];
    instance.instantAppsEnabled = map['instantAppsEnabled'];
    instance.keepAliveEnabled = map['keepAliveEnabled'];
    instance.isSingleInstance = map['isSingleInstance'];
    instance.noHistory = map['noHistory'];
    instance.isTrustedWebActivity = map['isTrustedWebActivity'];
    instance.additionalTrustedOrigins =
        map['additionalTrustedOrigins']?.cast<String>();
    instance.screenOrientation =
        TrustedWebActivityScreenOrientation.fromNativeValue(
            map['screenOrientation']);
    instance.alwaysUseBrowserUI = map['alwaysUseBrowserUI'];
    instance.entersReaderIfAvailable = map['entersReaderIfAvailable'];
    instance.barCollapsingEnabled = map['barCollapsingEnabled'];
    instance.dismissButtonStyle =
        DismissButtonStyle.fromNativeValue(map['dismissButtonStyle']);
    instance.presentationStyle =
        ModalPresentationStyle.fromNativeValue(map['presentationStyle']);
    instance.transitionStyle =
        ModalTransitionStyle.fromNativeValue(map['transitionStyle']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "shareState": shareState?.toNativeValue(),
      "showTitle": showTitle,
      "toolbarBackgroundColor": toolbarBackgroundColor?.toHex(),
      "navigationBarColor": navigationBarColor?.toHex(),
      "navigationBarDividerColor": navigationBarDividerColor?.toHex(),
      "secondaryToolbarColor": secondaryToolbarColor?.toHex(),
      "enableUrlBarHiding": enableUrlBarHiding,
      "instantAppsEnabled": instantAppsEnabled,
      "packageName": packageName,
      "keepAliveEnabled": keepAliveEnabled,
      "isSingleInstance": isSingleInstance,
      "noHistory": noHistory,
      "isTrustedWebActivity": isTrustedWebActivity,
      "additionalTrustedOrigins": additionalTrustedOrigins,
      "displayMode": displayMode?.toMap(),
      "screenOrientation": screenOrientation?.toNativeValue(),
      "startAnimations": startAnimations?.map((e) => e.toMap()).toList(),
      "exitAnimations": exitAnimations?.map((e) => e.toMap()).toList(),
      "alwaysUseBrowserUI": alwaysUseBrowserUI,
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": dismissButtonStyle?.toNativeValue(),
      "preferredBarTintColor": preferredBarTintColor?.toHex(),
      "preferredControlTintColor": preferredControlTintColor?.toHex(),
      "presentationStyle": presentationStyle?.toNativeValue(),
      "transitionStyle": transitionStyle?.toNativeValue(),
      "activityButton": activityButton?.toMap(),
      "eventAttribution": eventAttribution?.toMap(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of ChromeSafariBrowserSettings.
  ChromeSafariBrowserSettings copy() {
    return ChromeSafariBrowserSettings.fromMap(toMap()) ??
        ChromeSafariBrowserSettings();
  }

  @override
  String toString() {
    return 'ChromeSafariBrowserSettings{shareState: $shareState, showTitle: $showTitle, toolbarBackgroundColor: $toolbarBackgroundColor, navigationBarColor: $navigationBarColor, navigationBarDividerColor: $navigationBarDividerColor, secondaryToolbarColor: $secondaryToolbarColor, enableUrlBarHiding: $enableUrlBarHiding, instantAppsEnabled: $instantAppsEnabled, packageName: $packageName, keepAliveEnabled: $keepAliveEnabled, isSingleInstance: $isSingleInstance, noHistory: $noHistory, isTrustedWebActivity: $isTrustedWebActivity, additionalTrustedOrigins: $additionalTrustedOrigins, displayMode: $displayMode, screenOrientation: $screenOrientation, startAnimations: $startAnimations, exitAnimations: $exitAnimations, alwaysUseBrowserUI: $alwaysUseBrowserUI, entersReaderIfAvailable: $entersReaderIfAvailable, barCollapsingEnabled: $barCollapsingEnabled, dismissButtonStyle: $dismissButtonStyle, preferredBarTintColor: $preferredBarTintColor, preferredControlTintColor: $preferredControlTintColor, presentationStyle: $presentationStyle, transitionStyle: $transitionStyle, activityButton: $activityButton, eventAttribution: $eventAttribution}';
  }
}
