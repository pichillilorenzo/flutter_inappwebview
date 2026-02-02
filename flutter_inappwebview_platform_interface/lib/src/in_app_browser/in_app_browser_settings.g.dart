// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_browser_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.InAppWebViewSettings}
///This class represents all [InAppBrowser] settings available.
///{@endtemplate}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView
///- iOS WKWebView
///- macOS WKWebView
///- Windows WebView2
///- Linux WPE WebKit ([Official API - GtkWindow](https://docs.gtk.org/gtk3/class.Window.html))
class InAppBrowserSettings
    implements BrowserOptions, AndroidOptions, IosOptions {
  ///Set to `false` to block the InAppBrowser WebView going back when the user click on the Android back button. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? allowGoBackWithBackButton;

  ///Set the custom text for the close button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  String? closeButtonCaption;

  ///Set the custom color for the close button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? closeButtonColor;

  ///Set to `false` to not close the InAppBrowser when the user click on the Android back button and the WebView cannot go back to the history. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? closeOnCannotGoBack;

  ///Set to `true` to create the browser and load the page, but not show it. Omit or set to `false` to have the browser open and load normally.
  ///The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  bool? hidden;

  ///Set to `true` to hide the close button. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? hideCloseButton;

  ///Set to `true` to hide the default menu items. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  bool? hideDefaultMenuItems;

  ///Set to `true` to hide the progress bar when the WebView is loading a page. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  bool? hideProgressBar;

  ///Set to `true` if you want the title should be displayed. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? hideTitleBar;

  ///Set to `true` to hide the toolbar at the bottom of the WebView. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? hideToolbarBottom;

  ///Set to `true` to hide the toolbar at the top of the WebView. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  bool? hideToolbarTop;

  ///Set to `true` to hide the url bar on the toolbar at the top. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  bool? hideUrlBar;

  ///Set the custom color for the menu button.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? menuButtonColor;

  ///Set the custom modal presentation style when presenting the WebView. The default value is [ModalPresentationStyle.FULL_SCREEN].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ModalPresentationStyle? presentationStyle;

  ///Set to `true` to close the InAppBrowser when the user click on the Android back button. The default value is `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  bool? shouldCloseOnBackButtonPressed;

  ///Set the custom background color of the toolbar at the bottom.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? toolbarBottomBackgroundColor;

  ///Set the tint color to apply to the bar button items.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? toolbarBottomTintColor;

  ///Set to `true` to set the toolbar at the bottom translucent. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? toolbarBottomTranslucent;

  ///Set the custom background color of the toolbar at the top.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  Color? toolbarTopBackgroundColor;

  ///Set the tint color to apply to the navigation bar background.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? toolbarTopBarTintColor;

  ///Set the action bar's title.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  String? toolbarTopFixedTitle;

  ///Set the tint color to apply to the navigation items and bar button items.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  Color? toolbarTopTintColor;

  ///Set to `true` to set the toolbar at the top translucent. The default value is `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  bool? toolbarTopTranslucent;

  ///Set to the custom transition style when presenting the WebView. The default value is [ModalTransitionStyle.COVER_VERTICAL].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ModalTransitionStyle? transitionStyle;

  ///The window’s alpha value.
  ///The default value is `1.0`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  double? windowAlphaValue;

  ///Sets the origin and size of the window’s frame rectangle according to a given frame rectangle,
  ///thereby setting its position and size onscreen.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  InAppWebViewRect? windowFrame;

  ///Flags that describe the window’s current style, such as if it’s resizable or in full-screen mode.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  WindowStyleMask? windowStyleMask;

  ///The type of separator that the app displays between the title bar and content of a window.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView 11.0+
  WindowTitlebarSeparatorStyle? windowTitlebarSeparatorStyle;

  ///How the browser window should be added to the main window.
  ///The default value is [WindowType.WINDOW].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  WindowType? windowType;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit ([Official API - GtkWindow](https://docs.gtk.org/gtk3/class.Window.html))
  InAppBrowserSettings({
    this.allowGoBackWithBackButton = true,
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
    ModalPresentationStyle? presentationStyle,
    this.shouldCloseOnBackButtonPressed = false,
    this.toolbarBottomBackgroundColor,
    this.toolbarBottomTintColor,
    this.toolbarBottomTranslucent = true,
    this.toolbarTopBackgroundColor,
    this.toolbarTopFixedTitle,
    this.toolbarTopTintColor,
    this.toolbarTopTranslucent = true,
    ModalTransitionStyle? transitionStyle,
    this.windowAlphaValue = 1.0,
    this.windowFrame,
    this.windowStyleMask,
    this.windowTitlebarSeparatorStyle,
    this.windowType,
  }) : presentationStyle =
           presentationStyle ?? ModalPresentationStyle.FULL_SCREEN,
       transitionStyle = transitionStyle ?? ModalTransitionStyle.COVER_VERTICAL;

  ///Gets a possible [InAppBrowserSettings] instance from a [Map] value.
  static InAppBrowserSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
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
              map['toolbarBottomBackgroundColor'],
            )
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
        enumMethod: enumMethod,
      ),
      windowStyleMask: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WindowStyleMask.fromNativeValue(
          map['windowStyleMask'],
        ),
        EnumMethod.value => WindowStyleMask.fromValue(map['windowStyleMask']),
        EnumMethod.name => WindowStyleMask.byName(map['windowStyleMask']),
      },
      windowTitlebarSeparatorStyle: switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WindowTitlebarSeparatorStyle.fromNativeValue(
          map['windowTitlebarSeparatorStyle'],
        ),
        EnumMethod.value => WindowTitlebarSeparatorStyle.fromValue(
          map['windowTitlebarSeparatorStyle'],
        ),
        EnumMethod.name => WindowTitlebarSeparatorStyle.byName(
          map['windowTitlebarSeparatorStyle'],
        ),
      },
      windowType: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WindowType.fromNativeValue(map['windowType']),
        EnumMethod.value => WindowType.fromValue(map['windowType']),
        EnumMethod.name => WindowType.byName(map['windowType']),
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
      EnumMethod.nativeValue => ModalPresentationStyle.fromNativeValue(
        map['presentationStyle'],
      ),
      EnumMethod.value => ModalPresentationStyle.fromValue(
        map['presentationStyle'],
      ),
      EnumMethod.name => ModalPresentationStyle.byName(
        map['presentationStyle'],
      ),
    };
    instance.shouldCloseOnBackButtonPressed =
        map['shouldCloseOnBackButtonPressed'];
    instance.toolbarBottomTranslucent = map['toolbarBottomTranslucent'];
    instance.toolbarTopBarTintColor = map['toolbarTopBarTintColor'] != null
        ? UtilColor.fromStringRepresentation(map['toolbarTopBarTintColor'])
        : null;
    instance.toolbarTopTranslucent = map['toolbarTopTranslucent'];
    instance.transitionStyle = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => ModalTransitionStyle.fromNativeValue(
        map['transitionStyle'],
      ),
      EnumMethod.value => ModalTransitionStyle.fromValue(
        map['transitionStyle'],
      ),
      EnumMethod.name => ModalTransitionStyle.byName(map['transitionStyle']),
    };
    instance.windowAlphaValue = map['windowAlphaValue'];
    return instance;
  }

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    InAppBrowserSettingsProperty property, {
    TargetPlatform? platform,
  }) => _InAppBrowserSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

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
        EnumMethod.name => presentationStyle?.name(),
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
        EnumMethod.name => transitionStyle?.name(),
      },
      "windowAlphaValue": windowAlphaValue,
      "windowFrame": windowFrame?.toMap(enumMethod: enumMethod),
      "windowStyleMask": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowStyleMask?.toNativeValue(),
        EnumMethod.value => windowStyleMask?.toValue(),
        EnumMethod.name => windowStyleMask?.name(),
      },
      "windowTitlebarSeparatorStyle": switch (enumMethod ??
          EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowTitlebarSeparatorStyle?.toNativeValue(),
        EnumMethod.value => windowTitlebarSeparatorStyle?.toValue(),
        EnumMethod.name => windowTitlebarSeparatorStyle?.name(),
      },
      "windowType": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => windowType?.toNativeValue(),
        EnumMethod.value => windowType?.toValue(),
        EnumMethod.name => windowType?.name(),
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

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

///List of [InAppBrowserSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum InAppBrowserSettingsProperty {
  ///Can be used to check if the [InAppBrowserSettings.allowGoBackWithBackButton] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.allowGoBackWithBackButton.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  allowGoBackWithBackButton,

  ///Can be used to check if the [InAppBrowserSettings.closeButtonCaption] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.closeButtonCaption.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  closeButtonCaption,

  ///Can be used to check if the [InAppBrowserSettings.closeButtonColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.closeButtonColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  closeButtonColor,

  ///Can be used to check if the [InAppBrowserSettings.closeOnCannotGoBack] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.closeOnCannotGoBack.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  closeOnCannotGoBack,

  ///Can be used to check if the [InAppBrowserSettings.hidden] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hidden.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hidden,

  ///Can be used to check if the [InAppBrowserSettings.hideCloseButton] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideCloseButton.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideCloseButton,

  ///Can be used to check if the [InAppBrowserSettings.hideDefaultMenuItems] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideDefaultMenuItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideDefaultMenuItems,

  ///Can be used to check if the [InAppBrowserSettings.hideProgressBar] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideProgressBar.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideProgressBar,

  ///Can be used to check if the [InAppBrowserSettings.hideTitleBar] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideTitleBar.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideTitleBar,

  ///Can be used to check if the [InAppBrowserSettings.hideToolbarBottom] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideToolbarBottom.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideToolbarBottom,

  ///Can be used to check if the [InAppBrowserSettings.hideToolbarTop] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideToolbarTop.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideToolbarTop,

  ///Can be used to check if the [InAppBrowserSettings.hideUrlBar] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.hideUrlBar.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  hideUrlBar,

  ///Can be used to check if the [InAppBrowserSettings.menuButtonColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.menuButtonColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  menuButtonColor,

  ///Can be used to check if the [InAppBrowserSettings.presentationStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.presentationStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  presentationStyle,

  ///Can be used to check if the [InAppBrowserSettings.shouldCloseOnBackButtonPressed] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.shouldCloseOnBackButtonPressed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  shouldCloseOnBackButtonPressed,

  ///Can be used to check if the [InAppBrowserSettings.toolbarBottomBackgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarBottomBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarBottomBackgroundColor,

  ///Can be used to check if the [InAppBrowserSettings.toolbarBottomTintColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarBottomTintColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarBottomTintColor,

  ///Can be used to check if the [InAppBrowserSettings.toolbarBottomTranslucent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarBottomTranslucent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarBottomTranslucent,

  ///Can be used to check if the [InAppBrowserSettings.toolbarTopBackgroundColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarTopBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarTopBackgroundColor,

  ///Can be used to check if the [InAppBrowserSettings.toolbarTopBarTintColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarTopBarTintColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarTopBarTintColor,

  ///Can be used to check if the [InAppBrowserSettings.toolbarTopFixedTitle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarTopFixedTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarTopFixedTitle,

  ///Can be used to check if the [InAppBrowserSettings.toolbarTopTintColor] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarTopTintColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarTopTintColor,

  ///Can be used to check if the [InAppBrowserSettings.toolbarTopTranslucent] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.toolbarTopTranslucent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  toolbarTopTranslucent,

  ///Can be used to check if the [InAppBrowserSettings.transitionStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.transitionStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  transitionStyle,

  ///Can be used to check if the [InAppBrowserSettings.windowAlphaValue] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.windowAlphaValue.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  windowAlphaValue,

  ///Can be used to check if the [InAppBrowserSettings.windowFrame] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.windowFrame.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  windowFrame,

  ///Can be used to check if the [InAppBrowserSettings.windowStyleMask] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.windowStyleMask.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  windowStyleMask,

  ///Can be used to check if the [InAppBrowserSettings.windowTitlebarSeparatorStyle] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.windowTitlebarSeparatorStyle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView 11.0+
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  windowTitlebarSeparatorStyle,

  ///Can be used to check if the [InAppBrowserSettings.windowType] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.InAppBrowserSettings.windowType.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  ///- Windows WebView2
  ///- Linux WPE WebKit
  ///
  ///Use the [InAppBrowserSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  windowType,
}

extension _InAppBrowserSettingsPropertySupported on InAppBrowserSettings {
  static bool isPropertySupported(
    InAppBrowserSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case InAppBrowserSettingsProperty.allowGoBackWithBackButton:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.closeButtonCaption:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.closeButtonColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.closeOnCannotGoBack:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hidden:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideCloseButton:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideDefaultMenuItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideProgressBar:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideTitleBar:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideToolbarBottom:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideToolbarTop:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.hideUrlBar:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.menuButtonColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.presentationStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.shouldCloseOnBackButtonPressed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarBottomBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarBottomTintColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarBottomTranslucent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarTopBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarTopBarTintColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarTopFixedTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarTopTintColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.toolbarTopTranslucent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.transitionStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.windowAlphaValue:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.windowFrame:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.windowStyleMask:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.windowTitlebarSeparatorStyle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.macOS].contains(platform ?? defaultTargetPlatform);
      case InAppBrowserSettingsProperty.windowType:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
