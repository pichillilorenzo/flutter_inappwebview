import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Object specifying creation parameters for creating a [PlatformChromeSafariBrowser].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformChromeSafariBrowserCreationParams {
  /// Used by the platform implementation to create a new [PlatformChromeSafariBrowser].
  const PlatformChromeSafariBrowserCreationParams();
}

///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser}
///Class that provides a visible standard interface for browsing the web.
///It presents a self-contained web interface inside your app.
///
///If you need to customize or interact with the web content, use the `InAppWebView` widget.
///
///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///**NOTE**: If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for
///`android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml`
///(you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).
///
///**Officially Supported Platforms/Implementations**:
///- Android
///- iOS
///{@endtemplate}
abstract class PlatformChromeSafariBrowser extends PlatformInterface
    implements Disposable {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Event handler object that handles the [PlatformChromeSafariBrowser] events.
  PlatformChromeSafariBrowserEvents? eventHandler;

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.id}
  ///View ID used internally.
  ///{@endtemplate}
  String get id {
    throw UnimplementedError('id is not implemented on the current platform');
  }

  /// Creates a new [PlatformChromeSafariBrowser]
  factory PlatformChromeSafariBrowser(
      PlatformChromeSafariBrowserCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformChromeSafariBrowser chromeSafariBrowser = InAppWebViewPlatform
        .instance!
        .createPlatformChromeSafariBrowser(params);
    PlatformInterface.verify(chromeSafariBrowser, _token);
    return chromeSafariBrowser;
  }

  /// Creates a new [PlatformChromeSafariBrowser] to access static methods.
  factory PlatformChromeSafariBrowser.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformChromeSafariBrowser chromeSafariBrowserStatic =
        InAppWebViewPlatform.instance!
            .createPlatformChromeSafariBrowserStatic();
    PlatformInterface.verify(chromeSafariBrowserStatic, _token);
    return chromeSafariBrowserStatic;
  }

  /// Used by the platform implementation to create a new [PlatformChromeSafariBrowser].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformChromeSafariBrowser.implementation(this.params)
      : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformChromeSafariBrowser].
  final PlatformChromeSafariBrowserCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.open}
  ///Opens the [PlatformChromeSafariBrowser] instance with an [url].
  ///
  ///[url] - The [url] to load. On iOS, the [url] is required and must use the `http` or `https` scheme.
  ///
  ///[headers] (Supported only on Android) - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order. Supported only on Android.
  ///
  ///[referrer] - referrer header. Supported only on Android.
  ///
  ///[options] - Deprecated. Use `settings` instead.
  ///
  ///[settings] - Settings for the [PlatformChromeSafariBrowser].
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  Future<void> open(
      {WebUri? url,
      Map<String, String>? headers,
      List<WebUri>? otherLikelyURLs,
      WebUri? referrer,
      @Deprecated('Use settings instead')
      // ignore: deprecated_member_use_from_same_package
      ChromeSafariBrowserClassOptions? options,
      ChromeSafariBrowserSettings? settings}) {
    throw UnimplementedError('open is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.launchUrl}
  ///Tells the browser to launch with [url].
  ///
  ///[url] - initial url.
  ///
  ///[headers] (Supported only on Android) - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///[referrer] - referrer header. Supported only on Android.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///{@endtemplate}
  Future<void> launchUrl({
    required WebUri url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
  }) {
    throw UnimplementedError(
        'launchUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.mayLaunchUrl}
  ///Tells the browser of a likely future navigation to a URL.
  ///The most likely URL has to be specified first.
  ///Optionally, a list of other likely URLs can be provided.
  ///They are treated as less likely than the first one, and have to be sorted in decreasing priority order.
  ///These additional URLs may be ignored. All previous calls to this method will be deprioritized.
  ///
  ///[url] - Most likely URL, may be null if otherLikelyBundles is provided.
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.mayLaunchUrl](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#mayLaunchUrl(android.net.Uri,android.os.Bundle,java.util.List%3Candroid.os.Bundle%3E)))
  ///{@endtemplate}
  Future<bool> mayLaunchUrl({WebUri? url, List<WebUri>? otherLikelyURLs}) {
    throw UnimplementedError(
        'mayLaunchUrl is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.validateRelationship}
  ///Requests to validate a relationship between the application and an origin.
  ///
  ///See [here](https://developers.google.com/digital-asset-links/v1/getting-started) for documentation about Digital Asset Links.
  ///This methods requests the browser to verify a relation with the calling application, to grant the associated rights.
  ///
  ///If this method returns `true`, the validation result will be provided through [PlatformChromeSafariBrowserEvents.onRelationshipValidationResult].
  ///Otherwise the request didn't succeed.
  ///
  ///[relation] – Relation to check, must be one of the [CustomTabsRelationType] constants.
  ///
  ///[origin] – Origin.
  ///
  ///[extras] – Reserved for future use.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.validateRelationship](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#validateRelationship(int,android.net.Uri,android.os.Bundle)))
  ///{@endtemplate}
  Future<bool> validateRelationship(
      {required CustomTabsRelationType relation, required WebUri origin}) {
    throw UnimplementedError(
        'validateRelationship is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close}
  ///Closes the [PlatformChromeSafariBrowser] instance.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton}
  ///Set a custom action button.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsIntent.Builder.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean)))
  ///{@endtemplate}
  void setActionButton(ChromeSafariBrowserActionButton actionButton) {
    throw UnimplementedError(
        'setActionButton is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton}
  ///Updates the [ChromeSafariBrowserActionButton.icon] and [ChromeSafariBrowserActionButton.description].
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#setActionButton(android.graphics.Bitmap,java.lang.String)))
  ///{@endtemplate}
  Future<void> updateActionButton(
      {required Uint8List icon, required String description}) {
    throw UnimplementedError(
        'updateActionButton is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar}
  ///Sets the remote views displayed in the secondary toolbar in a custom tab.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsIntent.Builder.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)))
  ///{@endtemplate}
  void setSecondaryToolbar(
      ChromeSafariBrowserSecondaryToolbar secondaryToolbar) {
    throw UnimplementedError(
        'setSecondaryToolbar is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar}
  ///Sets or updates (if already present) the Remote Views of the secondary toolbar in an existing custom tab session.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)))
  ///{@endtemplate}
  Future<void> updateSecondaryToolbar(
      ChromeSafariBrowserSecondaryToolbar secondaryToolbar) {
    throw UnimplementedError(
        'updateSecondaryToolbar is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem}
  ///Adds a [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'addMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems}
  ///Adds a list of [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) {
    throw UnimplementedError(
        'addMenuItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.requestPostMessageChannel}
  ///Sends a request to create a two way postMessage channel between the client
  ///and the browser.
  ///If you want to specifying the target origin to communicate with, set the [targetOrigin].
  ///
  ///[sourceOrigin] - A origin that the client is requesting to be
  ///identified as during the postMessage communication.
  ///It has to either start with http or https.
  ///
  ///[targetOrigin] - The target Origin to establish the postMessage communication with.
  ///This can be the app's package name, it has to either start with http or https.
  ///
  ///Returns whether the implementation accepted the request.
  ///Note that returning true here doesn't mean an origin has already been
  ///assigned as the validation is asynchronous.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.requestPostMessageChannel](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#requestPostMessageChannel(android.net.Uri,android.net.Uri,android.os.Bundle)))
  ///{@endtemplate}
  Future<bool> requestPostMessageChannel(
      {required WebUri sourceOrigin, WebUri? targetOrigin}) {
    throw UnimplementedError(
        'requestPostMessageChannel is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.postMessage}
  ///Sends a postMessage request using the origin communicated via [requestPostMessageChannel].
  ///Fails when called before [PlatformChromeSafariBrowserEvents.onMessageChannelReady] event.
  ///
  ///[message] – The message that is being sent.
  ///
  ///Returns an integer constant about the postMessage request result.
  ///Will return CustomTabsService.RESULT_SUCCESS if successful.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.postMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#postMessage(java.lang.String,android.os.Bundle)))
  ///{@endtemplate}
  Future<CustomTabsPostMessageResultType> postMessage(String message) {
    throw UnimplementedError(
        'postMessage is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable}
  ///Returns whether the Engagement Signals API is available.
  ///The availability of the Engagement Signals API may change at runtime.
  ///If an EngagementSignalsCallback has been set, an [PlatformChromeSafariBrowserEvents.onSessionEnded]
  ///signal will be sent if the API becomes unavailable later.
  ///
  ///Returns whether the Engagement Signals API is available.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.isEngagementSignalsApiAvailable](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#isEngagementSignalsApiAvailable(android.os.Bundle)))
  ///{@endtemplate}
  Future<bool> isEngagementSignalsApiAvailable() {
    throw UnimplementedError(
        'isEngagementSignalsApiAvailable is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened}
  ///Returns `true` if the [PlatformChromeSafariBrowser] instance is opened, otherwise `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  bool isOpened() {
    throw UnimplementedError(
        'isOpened is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable}
  ///On Android, returns `true` if Chrome Custom Tabs is available.
  ///On iOS, returns `true` if SFSafariViewController is available.
  ///Otherwise returns `false`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  Future<bool> isAvailable() {
    throw UnimplementedError(
        'isAvailable is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems}
  ///The maximum number of allowed secondary toolbar items.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///{@endtemplate}
  Future<int> getMaxToolbarItems() {
    throw UnimplementedError(
        'getMaxToolbarItems is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getPackageName}
  ///Returns the preferred package to use for Custom Tabs.
  ///The preferred package name is the default VIEW intent handler as long as it supports Custom Tabs.
  ///To modify this preferred behavior, set [ignoreDefault] to `true` and give a
  ///non empty list of package names in packages.
  ///This method queries the `PackageManager` to determine which packages support the Custom Tabs API.
  ///On apps that target Android 11 and above, this requires adding the following
  ///package visibility elements to your manifest.
  ///
  ///[packages] – Ordered list of packages to test for Custom Tabs support, in decreasing order of priority.
  ///
  ///[ignoreDefault] – If set, the default VIEW handler won't get priority over other browsers.
  ///
  ///Returns the preferred package name for handling Custom Tabs, or null.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsClient.getPackageName](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsClient#getPackageName(android.content.Context,java.util.List%3Cjava.lang.String%3E,boolean))))
  ///{@endtemplate}
  Future<String?> getPackageName(
      {List<String>? packages, bool ignoreDefault = false}) {
    throw UnimplementedError(
        'getPackageName is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData}
  ///Clear associated website data accrued from browsing activity within your app.
  ///This includes all local storage, cached resources, and cookies.
  ///
  ///**NOTE for iOS**: available on iOS 16.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.DataStore.clearWebsiteData](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/datastore/3981117-clearwebsitedata))
  ///{@endtemplate}
  Future<void> clearWebsiteData() {
    throw UnimplementedError(
        'clearWebsiteData is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.prewarmConnections}
  ///Prewarms a connection to each URL. SFSafariViewController will automatically use a
  ///prewarmed connection if possible when loading its initial URL.
  ///
  ///Returns a token object that corresponds to the requested URLs. You must keep a strong
  ///reference to this token as long as you expect the prewarmed connections to remain open. If the same
  ///server is requested in multiple calls to this method, all of the corresponding tokens must be
  ///invalidated or released to end the prewarmed connection to that server.
  ///
  ///This method uses a best-effort approach to prewarming connections, but may delay
  ///or drop requests based on the volume of requests made by your app. Use this method when you expect
  ///to present the browser soon. Many HTTP servers time out connections after a few minutes.
  ///After a timeout, prewarming delivers less performance benefit.
  ///
  ///[URLs] - the URLs of servers that the browser should prewarm connections to.
  ///Only supports URLs with `http://` or `https://` schemes.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.prewarmConnections](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections))
  ///{@endtemplate}
  Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) {
    throw UnimplementedError(
        'prewarmConnections is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken}
  ///Ends all prewarmed connections associated with the token, except for connections that are also kept alive by other tokens.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.prewarmConnections](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections))
  ///{@endtemplate}
  Future<void> invalidatePrewarmingToken(PrewarmingToken prewarmingToken) {
    throw UnimplementedError(
        'invalidatePrewarmingToken is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose}
  ///Disposes the channel and event handler.
  ///{@endtemplate}
  @override
  @mustCallSuper
  void dispose() {
    eventHandler = null;
  }
}

abstract class PlatformChromeSafariBrowserEvents {
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onServiceConnected}
  ///Event fired when the when connecting from Android Custom Tabs Service.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///{@endtemplate}
  void onServiceConnected() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onOpened}
  ///Event fired when the [PlatformChromeSafariBrowser] is opened.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  void onOpened() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onCompletedInitialLoad}
  ///Event fired when the initial URL load is complete.
  ///
  ///[didLoadSuccessfully] - `true` if loading completed successfully; otherwise, `false`. Supported only on iOS.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/1621215-safariviewcontroller))
  ///{@endtemplate}
  void onCompletedInitialLoad(bool? didLoadSuccessfully) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onInitialLoadDidRedirect}
  ///Event fired when the initial URL load is complete.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/2923545-safariviewcontroller))
  ///{@endtemplate}
  void onInitialLoadDidRedirect(WebUri? url) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onNavigationEvent}
  ///Event fired when a navigation event happens.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onNavigationEvent](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onNavigationEvent(int,android.os.Bundle)))
  ///{@endtemplate}
  void onNavigationEvent(CustomTabsNavigationEventType? navigationEvent) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onRelationshipValidationResult}
  ///Event fired when a relationship validation result is available.
  ///
  ///[relation] - Relation for which the result is available. Value previously passed to [PlatformChromeSafariBrowser.validateRelationship].
  ///
  ///[requestedOrigin] - Origin requested. Value previously passed to [PlatformChromeSafariBrowser.validateRelationship].
  ///
  ///[result] - Whether the relation was validated.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onRelationshipValidationResult](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onRelationshipValidationResult(int,android.net.Uri,boolean,android.os.Bundle)))
  ///{@endtemplate}
  void onRelationshipValidationResult(
      CustomTabsRelationType? relation, WebUri? requestedOrigin, bool result) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onWillOpenInBrowser}
  ///Event fired when the user opens the current page in the default browser by tapping the toolbar button.
  ///
  ///**NOTE for iOS**: available on iOS 14.0+.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewControllerWillOpenInBrowser](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/3650426-safariviewcontrollerwillopeninbr))
  ///{@endtemplate}
  void onWillOpenInBrowser() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onMessageChannelReady}
  ///Called when the [PlatformChromeSafariBrowser] has requested a postMessage channel through
  ///[PlatformChromeSafariBrowser.requestPostMessageChannel] and the channel is ready for sending and receiving messages on both ends.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onMessageChannelReady](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onMessageChannelReady(android.os.Bundle)))
  ///{@endtemplate}
  void onMessageChannelReady() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onPostMessage}
  ///Called when a tab controlled by this [PlatformChromeSafariBrowser] has sent a postMessage.
  ///If [PlatformChromeSafariBrowser.postMessage] is called from a single thread, then the messages will be posted in the same order.
  ///When received on the client side, it is the client's responsibility to preserve the ordering further.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onPostMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onPostMessage(java.lang.String,android.os.Bundle)))
  ///{@endtemplate}
  void onPostMessage(String message) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onVerticalScrollEvent}
  ///Called when a user scrolls the tab.
  ///
  ///[isDirectionUp] - `false` when the user scrolls farther down the page,
  ///and `true` when the user scrolls back up toward the top of the page.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onVerticalScrollEvent](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onVerticalScrollEvent(boolean,android.os.Bundle)))
  ///{@endtemplate}
  void onVerticalScrollEvent(bool isDirectionUp) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onGreatestScrollPercentageIncreased}
  ///Called when a user has reached a greater scroll percentage on the page. The greatest scroll
  ///percentage is reset if the user navigates to a different page. If the current page's total
  ///height changes, this method will be called again only if the scroll progress reaches a
  ///higher percentage based on the new and current height of the page.
  ///
  ///[scrollPercentage] - An integer indicating the percent of scrollable progress
  ///the user hasmade down the current page.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onGreatestScrollPercentageIncreased](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onGreatestScrollPercentageIncreased(int,android.os.Bundle)))
  ///{@endtemplate}
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onBrowserNotSupported}
  /// Called when the browser is not supported.
  /// This can happen if a user forces a certain browser package to be used but the browser is not installed on the user's system.
  void onBrowserNotSupported() {
    throw UnimplementedError(
        'onBrowserNotSupported is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onSessionEnded}
  ///Called when a `CustomTabsSession` is ending or when no further Engagement Signals
  ///callbacks are expected to report whether any user action has occurred during the session.
  ///
  ///[didUserInteract] - Whether the user has interacted with the page in any way, e.g. scrolling.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onSessionEnded](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onSessionEnded(boolean,android.os.Bundle)))
  ///{@endtemplate}
  void onSessionEnded(bool didUserInteract) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.onClosed}
  ///Event fired when the [PlatformChromeSafariBrowser] is closed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  ///{@endtemplate}
  void onClosed() {}
}
