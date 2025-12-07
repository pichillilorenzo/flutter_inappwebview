// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_pull_to_refresh_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformPullToRefreshControllerCreationParamsClassSupported
    on PlatformPullToRefreshControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformPullToRefreshControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformPullToRefreshControllerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformPullToRefreshControllerCreationParamsProperty {
  ///Can be used to check if the [PlatformPullToRefreshControllerCreationParams.onRefresh] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshControllerCreationParams.onRefresh.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformPullToRefreshControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  onRefresh,

  ///Can be used to check if the [PlatformPullToRefreshControllerCreationParams.options] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshControllerCreationParams.options.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformPullToRefreshControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use settings instead')
  options,

  ///Can be used to check if the [PlatformPullToRefreshControllerCreationParams.settings] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshControllerCreationParams.settings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformPullToRefreshControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  settings,
}

extension _PlatformPullToRefreshControllerCreationParamsPropertySupported
    on PlatformPullToRefreshControllerCreationParams {
  static bool isPropertySupported(
      PlatformPullToRefreshControllerCreationParamsProperty property,
      {TargetPlatform? platform}) {
    switch (property) {
      case PlatformPullToRefreshControllerCreationParamsProperty.onRefresh:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerCreationParamsProperty.options:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerCreationParamsProperty.settings:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _PlatformPullToRefreshControllerClassSupported
    on PlatformPullToRefreshController {
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView:
  ///    - **NOTE**: to be able to use the "pull-to-refresh" feature, [InAppWebViewSettings.useHybridComposition] must be `true`.
  ///- iOS WKWebView
  ///
  ///Use the [PlatformPullToRefreshController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android, TargetPlatform.iOS]
            .contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformPullToRefreshController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformPullToRefreshControllerMethod {
  ///Can be used to check if the [PlatformPullToRefreshController.beginRefreshing] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.beginRefreshing.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setRefreshing(boolean)))
  ///- iOS WKWebView ([Official API - UIRefreshControl.beginRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624842-beginrefreshing))
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  beginRefreshing,

  ///Can be used to check if the [PlatformPullToRefreshController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [isKeepAlive]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformPullToRefreshController.endRefreshing] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.endRefreshing.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setRefreshing(boolean)))
  ///- iOS WKWebView ([Official API - UIRefreshControl.endRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624846-endrefreshing))
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  endRefreshing,

  ///Can be used to check if the [PlatformPullToRefreshController.getDefaultSlingshotDistance] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.getDefaultSlingshotDistance.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.DEFAULT_SLINGSHOT_DISTANCE](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#DEFAULT_SLINGSHOT_DISTANCE()))
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getDefaultSlingshotDistance,

  ///Can be used to check if the [PlatformPullToRefreshController.isEnabled] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - View.isEnabled](https://developer.android.com/reference/android/view/View#isEnabled()))
  ///- iOS WKWebView ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isEnabled,

  ///Can be used to check if the [PlatformPullToRefreshController.isRefreshing] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.isRefreshing.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.isRefreshing](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#isRefreshing()))
  ///- iOS WKWebView ([Official API - UIRefreshControl.isRefreshing](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624844-isrefreshing))
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isRefreshing,

  ///Can be used to check if the [PlatformPullToRefreshController.setAttributedTitle] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setAttributedTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [attributedTitle]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use setStyledTitle instead')
  setAttributedTitle,

  ///Can be used to check if the [PlatformPullToRefreshController.setBackgroundColor] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setBackgroundColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setProgressBackgroundColorSchemeColor](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setProgressBackgroundColorSchemeColor(int)))
  ///- iOS WKWebView ([Official API - UIView.backgroundColor](https://developer.apple.com/documentation/uikit/uiview/1622591-backgroundcolor))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [color]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setBackgroundColor,

  ///Can be used to check if the [PlatformPullToRefreshController.setColor] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setColor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setColorSchemeColors](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setColorSchemeColors(int...)))
  ///- iOS WKWebView ([Official API - UIRefreshControl.tintColor](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624847-tintcolor))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [color]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setColor,

  ///Can be used to check if the [PlatformPullToRefreshController.setDistanceToTriggerSync] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setDistanceToTriggerSync.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setDistanceToTriggerSync](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setDistanceToTriggerSync(int)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [distanceToTriggerSync]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setDistanceToTriggerSync,

  ///Can be used to check if the [PlatformPullToRefreshController.setEnabled] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setEnabled.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setEnabled](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setEnabled(boolean)))
  ///- iOS WKWebView ([Official API - UIScrollView.refreshControl](https://developer.apple.com/documentation/uikit/uiscrollview/2127691-refreshcontrol))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [enabled]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setEnabled,

  ///Can be used to check if the [PlatformPullToRefreshController.setIndicatorSize] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setIndicatorSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [size]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setIndicatorSize,

  ///Can be used to check if the [PlatformPullToRefreshController.setSize] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSize.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setSize](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSize(int)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [size]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  @Deprecated('Use setIndicatorSize instead')
  setSize,

  ///Can be used to check if the [PlatformPullToRefreshController.setSlingshotDistance] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setSlingshotDistance.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - SwipeRefreshLayout.setSlingshotDistance](https://developer.android.com/reference/androidx/swiperefreshlayout/widget/SwipeRefreshLayout#setSlingshotDistance(int)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [slingshotDistance]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSlingshotDistance,

  ///Can be used to check if the [PlatformPullToRefreshController.setStyledTitle] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformPullToRefreshController.setStyledTitle.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - UIRefreshControl.attributedTitle](https://developer.apple.com/documentation/uikit/uirefreshcontrol/1624845-attributedtitle))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [attributedTitle]: all platforms
  ///
  ///Use the [PlatformPullToRefreshController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setStyledTitle,
}

extension _PlatformPullToRefreshControllerMethodSupported
    on PlatformPullToRefreshController {
  static bool isMethodSupported(PlatformPullToRefreshControllerMethod method,
      {TargetPlatform? platform}) {
    switch (method) {
      case PlatformPullToRefreshControllerMethod.beginRefreshing:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.endRefreshing:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.getDefaultSlingshotDistance:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.isEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.isRefreshing:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setAttributedTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setBackgroundColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setColor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setDistanceToTriggerSync:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setEnabled:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android, TargetPlatform.iOS]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setIndicatorSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setSize:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setSlingshotDistance:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.android]
                .contains(platform ?? defaultTargetPlatform);
      case PlatformPullToRefreshControllerMethod.setStyledTitle:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
