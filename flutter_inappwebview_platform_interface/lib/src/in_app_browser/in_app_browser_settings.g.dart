// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_browser_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class represents all [InAppBrowser] settings available.
class InAppBrowserSettings
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? allowGoBackWithBackButton;

  ///Set the custom text for the close button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? closeButtonColor;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? closeOnCannotGoBack;

  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Windows
  bool? hidden;

  ///Set to `true` to hide the close button. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? hideCloseButton;

  ///Set to `true` to hide the default menu items. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideDefaultMenuItems;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideProgressBar;

  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? hideTitleBar;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? hideToolbarBottom;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideToolbarTop;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideUrlBar;

  ///Set the custom color for the menu button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? menuButtonColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [ModalPresentationStyle.FULL_SCREEN].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ModalPresentationStyle? presentationStyle;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? shouldCloseOnBackButtonPressed;

  ///Set the custom background color of the toolbar at the bottom.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? toolbarBottomTranslucent;

  ///Set the custom background color of the toolbar at the top.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Color? toolbarTopBackgroundColor;

  ///Set the tint color to apply to the navigation bar background.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopBarTintColor;

  ///Set the action bar's title.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  ///- Windows
  String? toolbarTopFixedTitle;

  ///Set the tint color to apply to the navigation items and bar button items.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopTintColor;

  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  bool? toolbarTopTranslucent;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ModalTransitionStyle? transitionStyle;

  ///The window’s alpha value.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  ///- Windows
  double? windowAlphaValue;

  ///Sets the origin and size of the window’s frame rectangle according to a given frame rectangle,
  ///thereby setting its position and size onscreen.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  ///- Windows
  InAppWebViewRect? windowFrame;

  ///Flags that describe the window’s current style, such as if it’s resizable or in full-screen mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  WindowStyleMask? windowStyleMask;

  ///The type of separator that the app displays between the title bar and content of a window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS 11.0+
  WindowTitlebarSeparatorStyle? windowTitlebarSeparatorStyle;

  ///How the browser window should be added to the main window.
  ///The default value is [WindowType.WINDOW].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- MacOS
  ///- Windows
  WindowType? windowType;
  InAppBrowserSettings(
      {this.allowGoBackWithBackButton = true,
      this.closeButtonCaption,
      this.closeButtonColor,
      this.closeOnCannotGoBack = true,
      this.hidden = false,
      this.hideCloseButton = false,
      this.hideDefaultMenuItems = false,
      this.hideProgressBar = false,
      this.hideTitleBar = false,
      this.hideToolbarBottom = false,
      this.hideToolbarTop = false,
      this.hideUrlBar = false,
      this.menuButtonColor,
      this.presentationStyle = ModalPresentationStyle.FULL_SCREEN,
      this.shouldCloseOnBackButtonPressed = false,
      this.toolbarBottomBackgroundColor,
      this.toolbarBottomTintColor,
      this.toolbarBottomTranslucent = true,
      this.toolbarTopBackgroundColor,
      this.toolbarTopFixedTitle,
      this.toolbarTopTintColor,
      this.toolbarTopTranslucent = true,
      this.transitionStyle = ModalTransitionStyle.COVER_VERTICAL,
      this.windowAlphaValue = 1.0,
      this.windowFrame,
      this.windowStyleMask,
      this.windowTitlebarSeparatorStyle,
      this.windowType});

  ///Gets a possible [InAppBrowserSettings] instance from a [Map] value.
  static InAppBrowserSettings? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = InAppBrowserSettings(
      closeButtonCaption: map['closeButtonCaption'],
      closeButtonColor: map['closeButtonColor'] != null
          ? UtilColor.fromStringRepresentation(map['closeButtonColor'])
          : null,
      menuButtonColor: map['menuButtonColor'] != null
          ? UtilColor.fromStringRepresentation(map['menuButtonColor'])
          : null,
      toolbarBottomBackgroundColor: map['toolbarBottomBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['toolbarBottomBackgroundColor'])
          : null,
      toolbarBottomTintColor: map['toolbarBottomTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarBottomTintColor'])
          : null,
      toolbarTopBackgroundColor: map['toolbarTopBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarTopBackgroundColor'])
          : null,
      toolbarTopFixedTitle: map['toolbarTopFixedTitle'],
      toolbarTopTintColor: map['toolbarTopTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarTopTintColor'])
          : null,
      windowFrame: InAppWebViewRect.fromMap(
          map['windowFrame']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      windowStyleMask: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          WindowStyleMask.fromNativeValue(map['windowStyleMask']),
        EnumMethod.value => WindowStyleMask.fromValue(map['windowStyleMask']),
        EnumMethod.name => WindowStyleMask.byName(map['windowStyleMask'])
      },
      windowTitlebarSeparatorStyle: switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WindowTitlebarSeparatorStyle.fromNativeValue(
            map['windowTitlebarSeparatorStyle']),
        EnumMethod.value => WindowTitlebarSeparatorStyle.fromValue(
            map['windowTitlebarSeparatorStyle']),
        EnumMethod.name => WindowTitlebarSeparatorStyle.byName(
            map['windowTitlebarSeparatorStyle'])
      },
      windowType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WindowType.fromNativeValue(map['windowType']),
        EnumMethod.value => WindowType.fromValue(map['windowType']),
        EnumMethod.name => WindowType.byName(map['windowType'])
      },
    );
    instance.allowGoBackWithBackButton = map['allowGoBackWithBackButton'];
    instance.closeOnCannotGoBack = map['closeOnCannotGoBack'];
    instance.hidden = map['hidden'];
    instance.hideCloseButton = map['hideCloseButton'];
    instance.hideDefaultMenuItems = map['hideDefaultMenuItems'];
    instance.hideProgressBar = map['hideProgressBar'];
    instance.hideTitleBar = map['hideTitleBar'];
    instance.hideToolbarBottom = map['hideToolbarBottom'];
    instance.hideToolbarTop = map['hideToolbarTop'];
    instance.hideUrlBar = map['hideUrlBar'];
    instance.presentationStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ModalPresentationStyle.fromNativeValue(map['presentationStyle']),
      EnumMethod.value =>
        ModalPresentationStyle.fromValue(map['presentationStyle']),
      EnumMethod.name => ModalPresentationStyle.byName(map['presentationStyle'])
    };
    instance.shouldCloseOnBackButtonPressed =
        map['shouldCloseOnBackButtonPressed'];
    instance.toolbarBottomTranslucent = map['toolbarBottomTranslucent'];
    instance.toolbarTopBarTintColor = map['toolbarTopBarTintColor'] != null
        ? UtilColor.fromStringRepresentation(map['toolbarTopBarTintColor'])
        : null;
    instance.toolbarTopTranslucent = map['toolbarTopTranslucent'];
    instance.transitionStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue =>
        ModalTransitionStyle.fromNativeValue(map['transitionStyle']),
      EnumMethod.value =>
        ModalTransitionStyle.fromValue(map['transitionStyle']),
      EnumMethod.name => ModalTransitionStyle.byName(map['transitionStyle'])
    };
    instance.windowAlphaValue = map['windowAlphaValue'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowGoBackWithBackButton": allowGoBackWithBackButton,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor?.toHex(),
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "hidden": hidden,
      "hideCloseButton": hideCloseButton,
      "hideDefaultMenuItems": hideDefaultMenuItems,
      "hideProgressBar": hideProgressBar,
      "hideTitleBar": hideTitleBar,
      "hideToolbarBottom": hideToolbarBottom,
      "hideToolbarTop": hideToolbarTop,
      "hideUrlBar": hideUrlBar,
      "menuButtonColor": menuButtonColor?.toHex(),
      "presentationStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => presentationStyle?.toNativeValue(),
        EnumMethod.value => presentationStyle?.toValue(),
        EnumMethod.name => presentationStyle?.name()
      },
      "shouldCloseOnBackButtonPressed": shouldCloseOnBackButtonPressed,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor?.toHex(),
      "toolbarBottomTintColor": toolbarBottomTintColor?.toHex(),
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor?.toHex(),
      "toolbarTopBarTintColor": toolbarTopBarTintColor?.toHex(),
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "toolbarTopTintColor": toolbarTopTintColor?.toHex(),
      "toolbarTopTranslucent": toolbarTopTranslucent,
      "transitionStyle": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => transitionStyle?.toNativeValue(),
        EnumMethod.value => transitionStyle?.toValue(),
        EnumMethod.name => transitionStyle?.name()
      },
      "windowAlphaValue": windowAlphaValue,
      "windowFrame": windowFrame?.toMap(enumMethod: enumMethod),
      "windowStyleMask": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowStyleMask?.toNativeValue(),
        EnumMethod.value => windowStyleMask?.toValue(),
        EnumMethod.name => windowStyleMask?.name()
      },
      "windowTitlebarSeparatorStyle": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowTitlebarSeparatorStyle?.toNativeValue(),
        EnumMethod.value => windowTitlebarSeparatorStyle?.toValue(),
        EnumMethod.name => windowTitlebarSeparatorStyle?.name()
      },
      "windowType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowType?.toNativeValue(),
        EnumMethod.value => windowType?.toValue(),
        EnumMethod.name => windowType?.name()
      },
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of InAppBrowserSettings.
  InAppBrowserSettings copy() {
    return InAppBrowserSettings.fromMap(toMap()) ?? InAppBrowserSettings();
  }

  @override
  String toString() {
    return 'InAppBrowserSettings{allowGoBackWithBackButton: $allowGoBackWithBackButton, closeButtonCaption: $closeButtonCaption, closeButtonColor: $closeButtonColor, closeOnCannotGoBack: $closeOnCannotGoBack, hidden: $hidden, hideCloseButton: $hideCloseButton, hideDefaultMenuItems: $hideDefaultMenuItems, hideProgressBar: $hideProgressBar, hideTitleBar: $hideTitleBar, hideToolbarBottom: $hideToolbarBottom, hideToolbarTop: $hideToolbarTop, hideUrlBar: $hideUrlBar, menuButtonColor: $menuButtonColor, presentationStyle: $presentationStyle, shouldCloseOnBackButtonPressed: $shouldCloseOnBackButtonPressed, toolbarBottomBackgroundColor: $toolbarBottomBackgroundColor, toolbarBottomTintColor: $toolbarBottomTintColor, toolbarBottomTranslucent: $toolbarBottomTranslucent, toolbarTopBackgroundColor: $toolbarTopBackgroundColor, toolbarTopBarTintColor: $toolbarTopBarTintColor, toolbarTopFixedTitle: $toolbarTopFixedTitle, toolbarTopTintColor: $toolbarTopTintColor, toolbarTopTranslucent: $toolbarTopTranslucent, transitionStyle: $transitionStyle, windowAlphaValue: $windowAlphaValue, windowFrame: $windowFrame, windowStyleMask: $windowStyleMask, windowTitlebarSeparatorStyle: $windowTitlebarSeparatorStyle, windowType: $windowType}';
  }
}
