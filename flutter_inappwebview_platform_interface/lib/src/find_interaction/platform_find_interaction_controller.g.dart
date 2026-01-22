// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_find_interaction_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformFindInteractionControllerCreationParamsClassSupported
    on PlatformFindInteractionControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///- Windows WebView2
  ///
  ///Use the [PlatformFindInteractionControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.linux,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformFindInteractionControllerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformFindInteractionControllerCreationParamsProperty {
  ///Can be used to check if the [PlatformFindInteractionControllerCreationParams.onFindResultReceived] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionControllerCreationParams.onFindResultReceived.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.FindListener.onFindResultReceived](https://developer.android.com/reference/android/webkit/WebView.FindListener#onFindResultReceived(int,%20int,%20boolean)))
  ///- iOS WKWebView:
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, this event will not be called.
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - WebKitFindController::counted-matches](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/signal.FindController.counted-matches.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Find.ActiveMatchIndexChanged/MatchCountChanged](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [controller]: all platforms
  ///- [activeMatchOrdinal]: all platforms
  ///- [numberOfMatches]: all platforms
  ///- [isDoneCounting]: all platforms
  ///
  ///Use the [PlatformFindInteractionControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onFindResultReceived,
}

extension _PlatformFindInteractionControllerCreationParamsPropertySupported
    on PlatformFindInteractionControllerCreationParams {
  static bool isPropertySupported(
    PlatformFindInteractionControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformFindInteractionControllerCreationParamsProperty
          .onFindResultReceived:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformFindInteractionControllerClassSupported
    on PlatformFindInteractionController {
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///- Windows WebView2
  ///
  ///Use the [PlatformFindInteractionController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.linux,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformFindInteractionController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformFindInteractionControllerMethod {
  ///Can be used to check if the [PlatformFindInteractionController.clearMatches] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.clearMatches.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.clearMatches](https://developer.android.com/reference/android/webkit/WebView#clearMatches()))
  ///- iOS WKWebView:
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2)
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_find_controller_search_finish](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search_finish.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Find.Stop](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#stop))
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearMatches,

  ///Can be used to check if the [PlatformFindInteractionController.dismissFindNavigator] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.dismissFindNavigator.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIFindInteraction.dismissFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975827-dismissfindnavigator?changes=_2)):
  ///    - Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dismissFindNavigator,

  ///Can be used to check if the [PlatformFindInteractionController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Linux WPE WebKit
  ///- Windows WebView2
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [isKeepAlive]: all platforms
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformFindInteractionController.findAll] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.findAll.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.findAllAsync](https://developer.android.com/reference/android/webkit/WebView#findAllAsync(java.lang.String))):
  ///    - It finds all instances asynchronously. Successive calls to this will cancel any pending searches.
  ///- iOS WKWebView:
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2) with [Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2)
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_find_controller_search](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Find.Start](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#start))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [find]: all platforms
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  findAll,

  ///Can be used to check if the [PlatformFindInteractionController.findNext] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.findNext.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebView.findNext](https://developer.android.com/reference/android/webkit/WebView#findNext(boolean)))
  ///- iOS WKWebView:
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it uses the built-in find interaction native UI, otherwise this is implemented using CSS and Javascript. In this case, it will use the [Official API - UIFindInteraction.findNext](https://developer.apple.com/documentation/uikit/uifindinteraction/3975829-findnext?changes=_2) and ([Official API - UIFindInteraction.findPrevious](https://developer.apple.com/documentation/uikit/uifindinteraction/3975830-findprevious?changes=_2)
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_find_controller_search_next](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search_next.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Find.FindNext/FindPrevious](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find#findnext))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [forward]: all platforms
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  findNext,

  ///Can be used to check if the [PlatformFindInteractionController.getActiveFindSession] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.getActiveFindSession.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIFindInteraction.activeFindSession](https://developer.apple.com/documentation/uikit/uifindinteraction/3975825-activefindsession?changes=_7____4_8&language=objc))
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - WebKitFindController](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.FindController.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2Find](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2find))
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getActiveFindSession,

  ///Can be used to check if the [PlatformFindInteractionController.getSearchText] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.getSearchText.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIFindInteraction.getSearchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2)):
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it will get the system find panel's search text field value.
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_find_controller_get_search_text](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.get_search_text.html))
  ///- Windows WebView2
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getSearchText,

  ///Can be used to check if the [PlatformFindInteractionController.isFindNavigatorVisible] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.isFindNavigatorVisible.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIFindInteraction.isFindNavigatorVisible](https://developer.apple.com/documentation/uikit/uifindinteraction/3975828-isfindnavigatorvisible?changes=_2)):
  ///    - Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isFindNavigatorVisible,

  ///Can be used to check if the [PlatformFindInteractionController.presentFindNavigator] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.presentFindNavigator.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIFindInteraction.presentFindNavigator](https://developer.apple.com/documentation/uikit/uifindinteraction/3975832-presentfindnavigator?changes=_2)):
  ///    - Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  presentFindNavigator,

  ///Can be used to check if the [PlatformFindInteractionController.setFindOptions] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.setFindOptions.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 ([Official API - ICoreWebView2Environment15.CreateFindOptions](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2environment15?view=webview2-1.0.2849.39#createfindoptions))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [options]: all platforms
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setFindOptions,

  ///Can be used to check if the [PlatformFindInteractionController.setSearchText] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.setSearchText.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - UIFindInteraction.searchText](https://developer.apple.com/documentation/uikit/uifindinteraction/3975834-searchtext?changes=_2)):
  ///    - If [InAppWebViewSettings.isFindInteractionEnabled] is `true`, it will pre-populate the system find panel's search text field with a search query.
  ///- macOS WKWebView
  ///- Linux WPE WebKit ([Official API - webkit_find_controller_search](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.FindController.search.html))
  ///- Windows WebView2 ([Official API - ICoreWebView2FindOptions.put_FindTerm](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2findoptions))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [searchText]: all platforms
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSearchText,

  ///Can be used to check if the [PlatformFindInteractionController.updateResultCount] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformFindInteractionController.updateResultCount.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIFindInteraction.updateResultCount](https://developer.apple.com/documentation/uikit/uifindinteraction/3975835-updateresultcount?changes=_2)):
  ///    - Available only if [InAppWebViewSettings.isFindInteractionEnabled] is `true`.
  ///
  ///Use the [PlatformFindInteractionController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  updateResultCount,
}

extension _PlatformFindInteractionControllerMethodSupported
    on PlatformFindInteractionController {
  static bool isMethodSupported(
    PlatformFindInteractionControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformFindInteractionControllerMethod.clearMatches:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.dismissFindNavigator:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.findAll:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.findNext:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.getActiveFindSession:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.getSearchText:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.isFindNavigatorVisible:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.presentFindNavigator:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.setFindOptions:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.setSearchText:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformFindInteractionControllerMethod.updateResultCount:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
