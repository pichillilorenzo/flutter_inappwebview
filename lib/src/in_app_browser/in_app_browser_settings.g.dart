// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_browser_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class represents all [InAppBrowser] settings available.
class InAppBrowserSettings
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hidden;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideToolbarTop;

  ///Set the custom background color of the toolbar at the top.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Color? toolbarTopBackgroundColor;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideUrlBar;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool? hideProgressBar;

  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? hideTitleBar;

  ///Set the action bar's title.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- MacOS
  String? toolbarTopFixedTitle;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? closeOnCannotGoBack;

  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? allowGoBackWithBackButton;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  bool? shouldCloseOnBackButtonPressed;

  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? toolbarTopTranslucent;

  ///Set the tint color to apply to the navigation bar background.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopBarTintColor;

  ///Set the tint color to apply to the navigation items and bar button items.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarTopTintColor;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? hideToolbarBottom;

  ///Set the custom background color of the toolbar at the bottom.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  bool? toolbarBottomTranslucent;

  ///Set the custom text for the close button.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Color? closeButtonColor;

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

  ///How the browser window should be added to the main window.
  ///The default value is [WindowType.CHILD].
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  WindowType? windowType;

  ///The window’s alpha value.
  ///The default value is `1.0`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  double? windowAlphaValue;

  ///Flags that describe the window’s current style, such as if it’s resizable or in full-screen mode.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  WindowStyleMask? windowStyleMask;

  ///The type of separator that the app displays between the title bar and content of a window.
  ///
  ///**NOTE for MacOS**: available on MacOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  WindowTitlebarSeparatorStyle? windowTitlebarSeparatorStyle;

  ///Sets the origin and size of the window’s frame rectangle according to a given frame rectangle,
  ///thereby setting its position and size onscreen.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  InAppWebViewRect? windowFrame;
  InAppBrowserSettings(
      {this.hidden = false,
      this.hideToolbarTop = false,
      this.toolbarTopBackgroundColor,
      this.hideUrlBar = false,
      this.hideProgressBar = false,
      this.hideTitleBar = false,
      this.toolbarTopFixedTitle,
      this.closeOnCannotGoBack = true,
      this.allowGoBackWithBackButton = true,
      this.shouldCloseOnBackButtonPressed = false,
      this.toolbarTopTranslucent = true,
      this.toolbarTopTintColor,
      this.hideToolbarBottom = false,
      this.toolbarBottomBackgroundColor,
      this.toolbarBottomTintColor,
      this.toolbarBottomTranslucent = true,
      this.closeButtonCaption,
      this.closeButtonColor,
      this.presentationStyle = ModalPresentationStyle.FULL_SCREEN,
      this.transitionStyle = ModalTransitionStyle.COVER_VERTICAL,
      this.windowType,
      this.windowAlphaValue = 1.0,
      this.windowStyleMask,
      this.windowTitlebarSeparatorStyle,
      this.windowFrame});

  ///Gets a possible [InAppBrowserSettings] instance from a [Map] value.
  static InAppBrowserSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = InAppBrowserSettings(
      toolbarTopBackgroundColor: map['toolbarTopBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarTopBackgroundColor'])
          : null,
      toolbarTopFixedTitle: map['toolbarTopFixedTitle'],
      toolbarTopTintColor: map['toolbarTopTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarTopTintColor'])
          : null,
      toolbarBottomBackgroundColor: map['toolbarBottomBackgroundColor'] != null
          ? UtilColor.fromStringRepresentation(
              map['toolbarBottomBackgroundColor'])
          : null,
      toolbarBottomTintColor: map['toolbarBottomTintColor'] != null
          ? UtilColor.fromStringRepresentation(map['toolbarBottomTintColor'])
          : null,
      closeButtonCaption: map['closeButtonCaption'],
      closeButtonColor: map['closeButtonColor'] != null
          ? UtilColor.fromStringRepresentation(map['closeButtonColor'])
          : null,
      windowType: WindowType.fromNativeValue(map['windowType']),
      windowStyleMask: WindowStyleMask.fromNativeValue(map['windowStyleMask']),
      windowTitlebarSeparatorStyle:
          WindowTitlebarSeparatorStyle.fromNativeValue(
              map['windowTitlebarSeparatorStyle']),
      windowFrame:
          InAppWebViewRect.fromMap(map['windowFrame']?.cast<String, dynamic>()),
    );
    instance.hidden = map['hidden'];
    instance.hideToolbarTop = map['hideToolbarTop'];
    instance.hideUrlBar = map['hideUrlBar'];
    instance.hideProgressBar = map['hideProgressBar'];
    instance.hideTitleBar = map['hideTitleBar'];
    instance.closeOnCannotGoBack = map['closeOnCannotGoBack'];
    instance.allowGoBackWithBackButton = map['allowGoBackWithBackButton'];
    instance.shouldCloseOnBackButtonPressed =
        map['shouldCloseOnBackButtonPressed'];
    instance.toolbarTopTranslucent = map['toolbarTopTranslucent'];
    instance.toolbarTopBarTintColor = map['toolbarTopBarTintColor'] != null
        ? UtilColor.fromStringRepresentation(map['toolbarTopBarTintColor'])
        : null;
    instance.hideToolbarBottom = map['hideToolbarBottom'];
    instance.toolbarBottomTranslucent = map['toolbarBottomTranslucent'];
    instance.presentationStyle =
        ModalPresentationStyle.fromNativeValue(map['presentationStyle']);
    instance.transitionStyle =
        ModalTransitionStyle.fromNativeValue(map['transitionStyle']);
    instance.windowAlphaValue = map['windowAlphaValue'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "hidden": hidden,
      "hideToolbarTop": hideToolbarTop,
      "toolbarTopBackgroundColor": toolbarTopBackgroundColor?.toHex(),
      "hideUrlBar": hideUrlBar,
      "hideProgressBar": hideProgressBar,
      "hideTitleBar": hideTitleBar,
      "toolbarTopFixedTitle": toolbarTopFixedTitle,
      "closeOnCannotGoBack": closeOnCannotGoBack,
      "allowGoBackWithBackButton": allowGoBackWithBackButton,
      "shouldCloseOnBackButtonPressed": shouldCloseOnBackButtonPressed,
      "toolbarTopTranslucent": toolbarTopTranslucent,
      "toolbarTopBarTintColor": toolbarTopBarTintColor?.toHex(),
      "toolbarTopTintColor": toolbarTopTintColor?.toHex(),
      "hideToolbarBottom": hideToolbarBottom,
      "toolbarBottomBackgroundColor": toolbarBottomBackgroundColor?.toHex(),
      "toolbarBottomTintColor": toolbarBottomTintColor?.toHex(),
      "toolbarBottomTranslucent": toolbarBottomTranslucent,
      "closeButtonCaption": closeButtonCaption,
      "closeButtonColor": closeButtonColor?.toHex(),
      "presentationStyle": presentationStyle?.toNativeValue(),
      "transitionStyle": transitionStyle?.toNativeValue(),
      "windowType": windowType?.toNativeValue(),
      "windowAlphaValue": windowAlphaValue,
      "windowStyleMask": windowStyleMask?.toNativeValue(),
      "windowTitlebarSeparatorStyle":
          windowTitlebarSeparatorStyle?.toNativeValue(),
      "windowFrame": windowFrame?.toMap(),
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
    return 'InAppBrowserSettings{hidden: $hidden, hideToolbarTop: $hideToolbarTop, toolbarTopBackgroundColor: $toolbarTopBackgroundColor, hideUrlBar: $hideUrlBar, hideProgressBar: $hideProgressBar, hideTitleBar: $hideTitleBar, toolbarTopFixedTitle: $toolbarTopFixedTitle, closeOnCannotGoBack: $closeOnCannotGoBack, allowGoBackWithBackButton: $allowGoBackWithBackButton, shouldCloseOnBackButtonPressed: $shouldCloseOnBackButtonPressed, toolbarTopTranslucent: $toolbarTopTranslucent, toolbarTopBarTintColor: $toolbarTopBarTintColor, toolbarTopTintColor: $toolbarTopTintColor, hideToolbarBottom: $hideToolbarBottom, toolbarBottomBackgroundColor: $toolbarBottomBackgroundColor, toolbarBottomTintColor: $toolbarBottomTintColor, toolbarBottomTranslucent: $toolbarBottomTranslucent, closeButtonCaption: $closeButtonCaption, closeButtonColor: $closeButtonColor, presentationStyle: $presentationStyle, transitionStyle: $transitionStyle, windowType: $windowType, windowAlphaValue: $windowAlphaValue, windowStyleMask: $windowStyleMask, windowTitlebarSeparatorStyle: $windowTitlebarSeparatorStyle, windowFrame: $windowFrame}';
  }
}
