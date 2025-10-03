// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chrome_safari_browser_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings}
///Class that represents the settings that can be used for an [ChromeSafariBrowser] window.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.supported_platforms}
///
///**Officially Supported Platforms/Implementations**:
///- Android Chrome Custom Tabs
///- iOS SFSafariViewController
class ChromeSafariBrowserSettings implements ChromeSafariBrowserOptions {
  ///An additional button to be shown in `SFSafariViewController`'s toolbar.
  ///This allows the user to access powerful functionality from your extension without needing to first show the `UIActivityViewController`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.0+
  ActivityButton? activityButton;

  ///Sets a list of additional trusted origins that the user may navigate or be redirected to from the starting uri.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  List<String>? additionalTrustedOrigins;

  ///Adds the necessary flags and extras to signal any browser supporting custom tabs to use the browser UI
  ///at all times and avoid showing custom tab like UI.
  ///Calling this with an intent will override any custom tabs related customizations.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  bool? alwaysUseBrowserUI;

  ///Set to `true` to enable bar collapsing. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  bool? barCollapsingEnabled;

  ///Set the custom style for the dismiss button. The default value is [DismissButtonStyle.DONE].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 11.0+
  DismissButtonStyle? dismissButtonStyle;

  ///Sets a display mode of a Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  TrustedWebActivityDisplayMode? displayMode;

  ///Set to `true` to enable the url bar to hide as the user scrolls down on the page. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  bool? enableUrlBarHiding;

  ///Set to `true` if Reader mode should be entered automatically when it is available for the webpage. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  bool? entersReaderIfAvailable;

  ///An event attribution associated with a click that caused this `SFSafariViewController` to be opened.
  ///This attribute is ignored if the `SFSafariViewController` url has a scheme of 'http'.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.2+
  UIEventAttribution? eventAttribution;

  ///Sets the exit animations.
  ///It must contain 2 [AndroidResource], where the first one represents the "enter" animation for the application
  ///and the second one represents the "exit" animation for the browser.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  List<AndroidResource>? exitAnimations;

  ///Set to `true` to enable Instant Apps. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  bool? instantAppsEnabled;

  ///Set to `true` to launch the Android activity in `singleInstance` mode. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  bool? isSingleInstance;

  ///Set to `true` to launch the Custom Tab as a Trusted Web Activity. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  bool? isTrustedWebActivity;

  ///Set to `true` to enable Keep Alive. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  bool? keepAliveEnabled;

  ///Sets the navigation bar color. Has no effect on Android API versions below L.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  Color? navigationBarColor;

  ///Sets the navigation bar divider color. Has no effect on Android API versions below P.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  Color? navigationBarDividerColor;

  ///Set to `true` to launch the Android intent with the flag `FLAG_ACTIVITY_NO_HISTORY`. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  bool? noHistory;

  ///Set an explicit application package name that limits
  ///the components this Intent will resolve to.  If left to the default
  ///value of null, all components in all applications will considered.
  ///If non-null, the Intent can only match the components in the given
  ///application package.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  String? packageName;

  ///Set the custom background color of the navigation bar and the toolbar.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 10.0+
  Color? preferredBarTintColor;

  ///Set the custom color of the control buttons on the navigation bar and the toolbar.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 10.0+
  Color? preferredControlTintColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [ModalPresentationStyle.FULL_SCREEN].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ModalPresentationStyle? presentationStyle;

  ///Sets a screen orientation. This can be used e.g. to enable the locking of an orientation lock type.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  TrustedWebActivityScreenOrientation? screenOrientation;

  ///Sets the color of the secondary toolbar.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  Color? secondaryToolbarColor;

  ///The share state that should be applied to the custom tab. The default value is [CustomTabsShareState.SHARE_STATE_DEFAULT].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  CustomTabsShareState? shareState;

  ///Set to `false` if the title shouldn't be shown in the custom tab. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  bool? showTitle;

  ///Sets the start animations.
  ///It must contain 2 [AndroidResource], where the first one represents the "enter" animation for the browser
  ///and the second one represents the "exit" animation for the application.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  List<AndroidResource>? startAnimations;

  ///Set the custom background color of the toolbar.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  Color? toolbarBackgroundColor;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ModalTransitionStyle? transitionStyle;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
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
  static ChromeSafariBrowserSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = ChromeSafariBrowserSettings(
      activityButton: ActivityButton.fromMap(
          map['activityButton']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      displayMode:
          _deserializeDisplayMode(map['displayMode'], enumMethod: enumMethod),
      eventAttribution: UIEventAttribution.fromMap(
          map['eventAttribution']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      exitAnimations: map['exitAnimations'] != null
          ? List<AndroidResource>.from(map['exitAnimations'].map((e) =>
              AndroidResource.fromMap(e?.cast<String, dynamic>(),
                  enumMethod: enumMethod)!))
          : null,
      navigationBarColor: map['navigationBarColor'] != null
          ? UtilColor.fromStringRepresentation(map['navigationBarColor'])
          : null,
      navigationBarDividerColor: map['navigationBarDividerColor'] != null
          ? UtilColor.fromStringRepresentation(map['navigationBarDividerColor'])
          : null,
      packageName: map['packageName'],
      preferredBarTintColor: map['preferredBarTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['preferredBarTintColor'])
          : null,
      preferredControlTintColor: map['preferredControlTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['preferredControlTintColor'])
          : null,
      secondaryToolbarColor: map['secondaryToolbarColor'] != null
          ? UtilColor.fromStringRepresentation(map['secondaryToolbarColor'])
          : null,
      startAnimations: map['startAnimations'] != null
          ? List<AndroidResource>.from(map['startAnimations'].map((e) =>
              AndroidResource.fromMap(e?.cast<String, dynamic>(),
                  enumMethod: enumMethod)!))
          : null,
      toolbarBackgroundColor: map['toolbarBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarBackgroundColor'])
          : null,
    );
    instance.additionalTrustedOrigins = map['additionalTrustedOrigins'] != null
        ? List<String>.from(map['additionalTrustedOrigins']!.cast<String>())
        : null;
    instance.alwaysUseBrowserUI = map['alwaysUseBrowserUI'];
    instance.barCollapsingEnabled = map['barCollapsingEnabled'];
    instance.dismissButtonStyle =
        switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        DismissButtonStyle.fromNativeValue(map['dismissButtonStyle']),
      EnumMethod.value =>
        DismissButtonStyle.fromValue(map['dismissButtonStyle']),
      EnumMethod.name => DismissButtonStyle.byName(map['dismissButtonStyle'])
    };
    instance.enableUrlBarHiding = map['enableUrlBarHiding'];
    instance.entersReaderIfAvailable = map['entersReaderIfAvailable'];
    instance.instantAppsEnabled = map['instantAppsEnabled'];
    instance.isSingleInstance = map['isSingleInstance'];
    instance.isTrustedWebActivity = map['isTrustedWebActivity'];
    instance.keepAliveEnabled = map['keepAliveEnabled'];
    instance.noHistory = map['noHistory'];
    instance.presentationStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ModalPresentationStyle.fromNativeValue(map['presentationStyle']),
      EnumMethod.value =>
        ModalPresentationStyle.fromValue(map['presentationStyle']),
      EnumMethod.name => ModalPresentationStyle.byName(map['presentationStyle'])
    };
    instance.screenOrientation = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        TrustedWebActivityScreenOrientation.fromNativeValue(
            map['screenOrientation']),
      EnumMethod.value =>
        TrustedWebActivityScreenOrientation.fromValue(map['screenOrientation']),
      EnumMethod.name =>
        TrustedWebActivityScreenOrientation.byName(map['screenOrientation'])
    };
    instance.shareState = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        CustomTabsShareState.fromNativeValue(map['shareState']),
      EnumMethod.value => CustomTabsShareState.fromValue(map['shareState']),
      EnumMethod.name => CustomTabsShareState.byName(map['shareState'])
    };
    instance.showTitle = map['showTitle'];
    instance.transitionStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ModalTransitionStyle.fromNativeValue(map['transitionStyle']),
      EnumMethod.value =>
        ModalTransitionStyle.fromValue(map['transitionStyle']),
      EnumMethod.name => ModalTransitionStyle.byName(map['transitionStyle'])
    };
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(ChromeSafariBrowserSettingsProperty property,
          {TargetPlatform? platform}) =>
      _ChromeSafariBrowserSettingsPropertySupported.isPropertySupported(
          property,
          platform: platform);

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "activityButton": activityButton?.toMap(enumMethod: enumMethod),
      "additionalTrustedOrigins": additionalTrustedOrigins,
      "alwaysUseBrowserUI": alwaysUseBrowserUI,
      "barCollapsingEnabled": barCollapsingEnabled,
      "dismissButtonStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => dismissButtonStyle?.toNativeValue(),
        EnumMethod.value => dismissButtonStyle?.toValue(),
        EnumMethod.name => dismissButtonStyle?.name()
      },
      "displayMode": displayMode?.toMap(enumMethod: enumMethod),
      "enableUrlBarHiding": enableUrlBarHiding,
      "entersReaderIfAvailable": entersReaderIfAvailable,
      "eventAttribution": eventAttribution?.toMap(enumMethod: enumMethod),
      "exitAnimations":
          exitAnimations?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "instantAppsEnabled": instantAppsEnabled,
      "isSingleInstance": isSingleInstance,
      "isTrustedWebActivity": isTrustedWebActivity,
      "keepAliveEnabled": keepAliveEnabled,
      "navigationBarColor": navigationBarColor?.toHex(),
      "navigationBarDividerColor": navigationBarDividerColor?.toHex(),
      "noHistory": noHistory,
      "packageName": packageName,
      "preferredBarTintColor": preferredBarTintColor?.toHex(),
      "preferredControlTintColor": preferredControlTintColor?.toHex(),
      "presentationStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => presentationStyle?.toNativeValue(),
        EnumMethod.value => presentationStyle?.toValue(),
        EnumMethod.name => presentationStyle?.name()
      },
      "screenOrientation": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => screenOrientation?.toNativeValue(),
        EnumMethod.value => screenOrientation?.toValue(),
        EnumMethod.name => screenOrientation?.name()
      },
      "secondaryToolbarColor": secondaryToolbarColor?.toHex(),
      "shareState": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => shareState?.toNativeValue(),
        EnumMethod.value => shareState?.toValue(),
        EnumMethod.name => shareState?.name()
      },
      "showTitle": showTitle,
      "startAnimations":
          startAnimations?.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
      "toolbarBackgroundColor": toolbarBackgroundColor?.toHex(),
      "transitionStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => transitionStyle?.toNativeValue(),
        EnumMethod.value => transitionStyle?.toValue(),
        EnumMethod.name => transitionStyle?.name()
      },
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
    return 'ChromeSafariBrowserSettings{activityButton: $activityButton, additionalTrustedOrigins: $additionalTrustedOrigins, alwaysUseBrowserUI: $alwaysUseBrowserUI, barCollapsingEnabled: $barCollapsingEnabled, dismissButtonStyle: $dismissButtonStyle, displayMode: $displayMode, enableUrlBarHiding: $enableUrlBarHiding, entersReaderIfAvailable: $entersReaderIfAvailable, eventAttribution: $eventAttribution, exitAnimations: $exitAnimations, instantAppsEnabled: $instantAppsEnabled, isSingleInstance: $isSingleInstance, isTrustedWebActivity: $isTrustedWebActivity, keepAliveEnabled: $keepAliveEnabled, navigationBarColor: $navigationBarColor, navigationBarDividerColor: $navigationBarDividerColor, noHistory: $noHistory, packageName: $packageName, preferredBarTintColor: $preferredBarTintColor, preferredControlTintColor: $preferredControlTintColor, presentationStyle: $presentationStyle, screenOrientation: $screenOrientation, secondaryToolbarColor: $secondaryToolbarColor, shareState: $shareState, showTitle: $showTitle, startAnimations: $startAnimations, toolbarBackgroundColor: $toolbarBackgroundColor, transitionStyle: $transitionStyle}';
  }
}

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [ChromeSafariBrowserSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum ChromeSafariBrowserSettingsProperty {
  ///Can be used to check if the [ChromeSafariBrowserSettings.activityButton] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.activityButton.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.0+
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  activityButton,

  ///Can be used to check if the [ChromeSafariBrowserSettings.additionalTrustedOrigins] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.additionalTrustedOrigins.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  additionalTrustedOrigins,

  ///Can be used to check if the [ChromeSafariBrowserSettings.alwaysUseBrowserUI] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.alwaysUseBrowserUI.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  alwaysUseBrowserUI,

  ///Can be used to check if the [ChromeSafariBrowserSettings.barCollapsingEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.barCollapsingEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  barCollapsingEnabled,

  ///Can be used to check if the [ChromeSafariBrowserSettings.dismissButtonStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.dismissButtonStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 11.0+
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  dismissButtonStyle,

  ///Can be used to check if the [ChromeSafariBrowserSettings.displayMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.displayMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  displayMode,

  ///Can be used to check if the [ChromeSafariBrowserSettings.enableUrlBarHiding] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.enableUrlBarHiding.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  enableUrlBarHiding,

  ///Can be used to check if the [ChromeSafariBrowserSettings.entersReaderIfAvailable] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.entersReaderIfAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  entersReaderIfAvailable,

  ///Can be used to check if the [ChromeSafariBrowserSettings.eventAttribution] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.eventAttribution.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.2+
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  eventAttribution,

  ///Can be used to check if the [ChromeSafariBrowserSettings.exitAnimations] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.exitAnimations.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  exitAnimations,

  ///Can be used to check if the [ChromeSafariBrowserSettings.instantAppsEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.instantAppsEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  instantAppsEnabled,

  ///Can be used to check if the [ChromeSafariBrowserSettings.isSingleInstance] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.isSingleInstance.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isSingleInstance,

  ///Can be used to check if the [ChromeSafariBrowserSettings.isTrustedWebActivity] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.isTrustedWebActivity.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  isTrustedWebActivity,

  ///Can be used to check if the [ChromeSafariBrowserSettings.keepAliveEnabled] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.keepAliveEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  keepAliveEnabled,

  ///Can be used to check if the [ChromeSafariBrowserSettings.navigationBarColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.navigationBarColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  navigationBarColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.navigationBarDividerColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.navigationBarDividerColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  navigationBarDividerColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.noHistory] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.noHistory.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  noHistory,

  ///Can be used to check if the [ChromeSafariBrowserSettings.packageName] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.packageName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  packageName,

  ///Can be used to check if the [ChromeSafariBrowserSettings.preferredBarTintColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.preferredBarTintColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 10.0+
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredBarTintColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.preferredControlTintColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.preferredControlTintColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 10.0+
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  preferredControlTintColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.presentationStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.presentationStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  presentationStyle,

  ///Can be used to check if the [ChromeSafariBrowserSettings.screenOrientation] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.screenOrientation.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  screenOrientation,

  ///Can be used to check if the [ChromeSafariBrowserSettings.secondaryToolbarColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.secondaryToolbarColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  secondaryToolbarColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.shareState] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.shareState.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shareState,

  ///Can be used to check if the [ChromeSafariBrowserSettings.showTitle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.showTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  showTitle,

  ///Can be used to check if the [ChromeSafariBrowserSettings.startAnimations] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.startAnimations.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  startAnimations,

  ///Can be used to check if the [ChromeSafariBrowserSettings.toolbarBackgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.toolbarBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarBackgroundColor,

  ///Can be used to check if the [ChromeSafariBrowserSettings.transitionStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.ChromeSafariBrowserSettings.transitionStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController
  ///
  ///Use the [ChromeSafariBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  transitionStyle,
}

extension _ChromeSafariBrowserSettingsPropertySupported
    on ChromeSafariBrowserSettings {
  static bool isPropertySupported(ChromeSafariBrowserSettingsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case ChromeSafariBrowserSettingsProperty.activityButton:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.additionalTrustedOrigins:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.alwaysUseBrowserUI:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.barCollapsingEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.dismissButtonStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.displayMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.enableUrlBarHiding:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.entersReaderIfAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.eventAttribution:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.exitAnimations:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.instantAppsEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.isSingleInstance:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.isTrustedWebActivity:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.keepAliveEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.navigationBarColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.navigationBarDividerColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.noHistory:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.packageName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.preferredBarTintColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.preferredControlTintColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.presentationStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.screenOrientation:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.secondaryToolbarColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.shareState:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.showTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.startAnimations:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.toolbarBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case ChromeSafariBrowserSettingsProperty.transitionStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
