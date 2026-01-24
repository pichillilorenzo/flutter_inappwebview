// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_chrome_safari_browser.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformChromeSafariBrowserClassSupported
    on PlatformChromeSafariBrowser {
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary). If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for `android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml` (you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).
  ///- iOS SFSafariViewController:
  ///    - This class uses native [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)
  ///
  ///Use the [PlatformChromeSafariBrowser.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformChromeSafariBrowser]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformChromeSafariBrowserMethod {
  ///Can be used to check if the [PlatformChromeSafariBrowser.addMenuItem] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///- iOS SFSafariViewController
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [menuItem]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addMenuItem,

  ///Can be used to check if the [PlatformChromeSafariBrowser.addMenuItems] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs:
  ///    - Not available in a Trusted Web Activity.
  ///- iOS SFSafariViewController
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [menuItems]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addMenuItems,

  ///Can be used to check if the [PlatformChromeSafariBrowser.clearWebsiteData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 16.0+ ([Official API - SFSafariViewController.DataStore.clearWebsiteData](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/datastore/3981117-clearwebsitedata))
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearWebsiteData,

  ///Can be used to check if the [PlatformChromeSafariBrowser.close] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  close,

  ///Can be used to check if the [PlatformChromeSafariBrowser.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformChromeSafariBrowser.getMaxToolbarItems] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getMaxToolbarItems,

  ///Can be used to check if the [PlatformChromeSafariBrowser.getPackageName] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getPackageName.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsClient.getPackageName](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsClient#getPackageName(android.content.Context,java.util.List%3Cjava.lang.String%3E,boolean)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [packages]: all platforms
  ///- [ignoreDefault]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getPackageName,

  ///Can be used to check if the [PlatformChromeSafariBrowser.invalidatePrewarmingToken] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.0+ ([Official API - SFSafariViewController.PrewarmingToken.invalidate](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/prewarmingtoken/invalidate()))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [prewarmingToken]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  invalidatePrewarmingToken,

  ///Can be used to check if the [PlatformChromeSafariBrowser.isAvailable] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isAvailable,

  ///Can be used to check if the [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.isEngagementSignalsApiAvailable](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#isEngagementSignalsApiAvailable(android.os.Bundle)))
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isEngagementSignalsApiAvailable,

  ///Can be used to check if the [PlatformChromeSafariBrowser.isOpened] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isOpened,

  ///Can be used to check if the [PlatformChromeSafariBrowser.launchUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.launchUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [headers]: all platforms
  ///- [otherLikelyURLs]: all platforms
  ///- [referrer]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  launchUrl,

  ///Can be used to check if the [PlatformChromeSafariBrowser.mayLaunchUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.mayLaunchUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.mayLaunchUrl](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#mayLaunchUrl(android.net.Uri,android.os.Bundle,java.util.List%3Candroid.os.Bundle%3E)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [otherLikelyURLs]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  mayLaunchUrl,

  ///Can be used to check if the [PlatformChromeSafariBrowser.open] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.open.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs
  ///- iOS SFSafariViewController
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///- [headers]:
  ///    - Android Chrome Custom Tabs
  ///- [otherLikelyURLs]:
  ///    - Android Chrome Custom Tabs
  ///- [referrer]:
  ///    - Android Chrome Custom Tabs
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  open,

  ///Can be used to check if the [PlatformChromeSafariBrowser.postMessage] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.postMessage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.postMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#postMessage(java.lang.String,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [message]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  postMessage,

  ///Can be used to check if the [PlatformChromeSafariBrowser.prewarmConnections] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.prewarmConnections.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS SFSafariViewController 15.0+ ([Official API - SFSafariViewController.prewarmConnections](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [URLs]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  prewarmConnections,

  ///Can be used to check if the [PlatformChromeSafariBrowser.requestPostMessageChannel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.requestPostMessageChannel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.requestPostMessageChannel](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#requestPostMessageChannel(android.net.Uri,android.net.Uri,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [sourceOrigin]: all platforms
  ///- [targetOrigin]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  requestPostMessageChannel,

  ///Can be used to check if the [PlatformChromeSafariBrowser.setActionButton] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean))):
  ///    - Not available in a Trusted Web Activity.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [actionButton]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setActionButton,

  ///Can be used to check if the [PlatformChromeSafariBrowser.setSecondaryToolbar] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsIntent.Builder.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent))):
  ///    - Not available in a Trusted Web Activity.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [secondaryToolbar]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  setSecondaryToolbar,

  ///Can be used to check if the [PlatformChromeSafariBrowser.updateActionButton] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean))):
  ///    - Not available in a Trusted Web Activity.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [icon]: all platforms
  ///- [description]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  updateActionButton,

  ///Can be used to check if the [PlatformChromeSafariBrowser.updateSecondaryToolbar] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsIntent.Builder.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent))):
  ///    - Not available in a Trusted Web Activity.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [secondaryToolbar]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  updateSecondaryToolbar,

  ///Can be used to check if the [PlatformChromeSafariBrowser.validateRelationship] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.validateRelationship.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android Chrome Custom Tabs ([Official API - CustomTabsSession.validateRelationship](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#validateRelationship(int,android.net.Uri,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [relation]: all platforms
  ///- [origin]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowser.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  validateRelationship,
}

extension _PlatformChromeSafariBrowserMethodSupported
    on PlatformChromeSafariBrowser {
  static bool isMethodSupported(
    PlatformChromeSafariBrowserMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformChromeSafariBrowserMethod.addMenuItem:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.addMenuItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.clearWebsiteData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.close:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.getMaxToolbarItems:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.getPackageName:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.invalidatePrewarmingToken:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.isAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.isEngagementSignalsApiAvailable:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.isOpened:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.launchUrl:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.mayLaunchUrl:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.open:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.postMessage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.prewarmConnections:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.requestPostMessageChannel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.setActionButton:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.setSecondaryToolbar:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.updateActionButton:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.updateSecondaryToolbar:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserMethod.validateRelationship:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformChromeSafariBrowserEvents]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformChromeSafariBrowserEventsMethod {
  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onClosed] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onClosed.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onClosed,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onCompletedInitialLoad] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onCompletedInitialLoad.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/1621215-safariviewcontroller))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [didLoadSuccessfully]:
  ///    - iOS WKWebView
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onCompletedInitialLoad,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onGreatestScrollPercentageIncreased] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onGreatestScrollPercentageIncreased.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - EngagementSignalsCallback.onGreatestScrollPercentageIncreased](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onGreatestScrollPercentageIncreased(int,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [scrollPercentage]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onGreatestScrollPercentageIncreased,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onInitialLoadDidRedirect] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onInitialLoadDidRedirect.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/2923545-safariviewcontroller))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [url]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onInitialLoadDidRedirect,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onMessageChannelReady] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onMessageChannelReady.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CustomTabsCallback.onMessageChannelReady](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onMessageChannelReady(android.os.Bundle)))
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onMessageChannelReady,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onNavigationEvent] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onNavigationEvent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CustomTabsCallback.onNavigationEvent](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onNavigationEvent(int,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [navigationEvent]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onNavigationEvent,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onOpened] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onOpened.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onOpened,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onPostMessage] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onPostMessage.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CustomTabsCallback.onPostMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onPostMessage(java.lang.String,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [message]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onPostMessage,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onRelationshipValidationResult] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onRelationshipValidationResult.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - CustomTabsCallback.onRelationshipValidationResult](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onRelationshipValidationResult(int,android.net.Uri,boolean,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [relation]: all platforms
  ///- [requestedOrigin]: all platforms
  ///- [result]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onRelationshipValidationResult,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onServiceConnected] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onServiceConnected.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onServiceConnected,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onSessionEnded] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onSessionEnded.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - EngagementSignalsCallback.onSessionEnded](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onSessionEnded(boolean,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [didUserInteract]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onSessionEnded,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onVerticalScrollEvent] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onVerticalScrollEvent.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - EngagementSignalsCallback.onVerticalScrollEvent](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onVerticalScrollEvent(boolean,android.os.Bundle)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [isDirectionUp]: all platforms
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onVerticalScrollEvent,

  ///Can be used to check if the [PlatformChromeSafariBrowserEvents.onWillOpenInBrowser] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onWillOpenInBrowser.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 14.0+ ([Official API - SFSafariViewControllerDelegate.safariViewControllerWillOpenInBrowser](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/3650426-safariviewcontrollerwillopeninbr))
  ///
  ///Use the [PlatformChromeSafariBrowserEvents.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  onWillOpenInBrowser,
}

extension _PlatformChromeSafariBrowserEventsMethodSupported
    on PlatformChromeSafariBrowserEvents {
  static bool isMethodSupported(
    PlatformChromeSafariBrowserEventsMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformChromeSafariBrowserEventsMethod.onClosed:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onCompletedInitialLoad:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod
          .onGreatestScrollPercentageIncreased:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onInitialLoadDidRedirect:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onMessageChannelReady:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onNavigationEvent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onOpened:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onPostMessage:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod
          .onRelationshipValidationResult:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onServiceConnected:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onSessionEnded:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onVerticalScrollEvent:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformChromeSafariBrowserEventsMethod.onWillOpenInBrowser:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [TargetPlatform.iOS].contains(platform ?? defaultTargetPlatform);
    }
  }
}
