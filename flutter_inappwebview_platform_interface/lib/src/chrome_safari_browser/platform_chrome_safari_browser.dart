import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'platform_chrome_safari_browser.g.dart';

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
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(
    note:
        """This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary).
If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for
`android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml`
(you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).""",
    name: 'Android Chrome Custom Tabs',
  ),
  IOSPlatform(
      note:
          'This class uses native [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)',
      name: 'iOS SFSafariViewController'),
])
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
  ///[headers] - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///[referrer] - referrer header.
  ///
  ///[options] - Deprecated. Use `settings` instead.
  ///
  ///[settings] - Settings for the [PlatformChromeSafariBrowser].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.open.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  Future<void> open(
      {WebUri? url,
      @SupportedPlatforms(platforms: [
        AndroidPlatform(),
      ])
      Map<String, String>? headers,
      @SupportedPlatforms(platforms: [
        AndroidPlatform(),
      ])
      List<WebUri>? otherLikelyURLs,
      @SupportedPlatforms(platforms: [
        AndroidPlatform(),
      ])
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
  ///[headers] - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///[referrer] - referrer header.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.launchUrl.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.mayLaunchUrl.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.mayLaunchUrl',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#mayLaunchUrl(android.net.Uri,android.os.Bundle,java.util.List%3Candroid.os.Bundle%3E)',
    ),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.validateRelationship.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.validateRelationship',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#validateRelationship(int,android.net.Uri,android.os.Bundle)',
    ),
  ])
  Future<bool> validateRelationship(
      {required CustomTabsRelationType relation, required WebUri origin}) {
    throw UnimplementedError(
        'validateRelationship is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close}
  ///Closes the [PlatformChromeSafariBrowser] instance.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton}
  ///Set a custom action button.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.setActionButton',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean)',
      note: 'Not available in a Trusted Web Activity.',
    ),
  ])
  void setActionButton(ChromeSafariBrowserActionButton actionButton) {
    throw UnimplementedError(
        'setActionButton is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton}
  ///Updates the [ChromeSafariBrowserActionButton.icon] and [ChromeSafariBrowserActionButton.description].
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.setActionButton',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean)',
      note: 'Not available in a Trusted Web Activity.',
    ),
  ])
  Future<void> updateActionButton(
      {required Uint8List icon, required String description}) {
    throw UnimplementedError(
        'updateActionButton is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar}
  ///Sets the remote views displayed in the secondary toolbar in a custom tab.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsIntent.Builder.setSecondaryToolbarViews',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)',
      note: 'Not available in a Trusted Web Activity.',
    ),
  ])
  void setSecondaryToolbar(
      ChromeSafariBrowserSecondaryToolbar secondaryToolbar) {
    throw UnimplementedError(
        'setSecondaryToolbar is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar}
  ///Sets or updates (if already present) the Remote Views of the secondary toolbar in an existing custom tab session.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsIntent.Builder.setSecondaryToolbarViews',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)',
      note: 'Not available in a Trusted Web Activity.',
    ),
  ])
  Future<void> updateSecondaryToolbar(
      ChromeSafariBrowserSecondaryToolbar secondaryToolbar) {
    throw UnimplementedError(
        'updateSecondaryToolbar is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem}
  ///Adds a [ChromeSafariBrowserMenuItem] to the menu.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      note: 'Not available in a Trusted Web Activity.',
    ),
    IOSPlatform(),
  ])
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) {
    throw UnimplementedError(
        'addMenuItem is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems}
  ///Adds a list of [ChromeSafariBrowserMenuItem] to the menu.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      note: 'Not available in a Trusted Web Activity.',
    ),
    IOSPlatform(),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.requestPostMessageChannel.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.requestPostMessageChannel',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#requestPostMessageChannel(android.net.Uri,android.net.Uri,android.os.Bundle)',
    ),
  ])
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
  ///Will return [CustomTabsPostMessageResultType.SUCCESS] if successful.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.postMessage.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.postMessage',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#postMessage(java.lang.String,android.os.Bundle)',
    ),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsSession.isEngagementSignalsApiAvailable',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#isEngagementSignalsApiAvailable(android.os.Bundle)',
    ),
  ])
  Future<bool> isEngagementSignalsApiAvailable() {
    throw UnimplementedError(
        'isEngagementSignalsApiAvailable is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened}
  ///Returns `true` if the [PlatformChromeSafariBrowser] instance is opened, otherwise `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  bool isOpened() {
    throw UnimplementedError(
        'isOpened is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable}
  ///On Android, returns `true` if Chrome Custom Tabs is available.
  ///On iOS, returns `true` if SFSafariViewController is available.
  ///Otherwise returns `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  Future<bool> isAvailable() {
    throw UnimplementedError(
        'isAvailable is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems}
  ///The maximum number of allowed secondary toolbar items.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
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
  ///Returns the preferred package name for handling Custom Tabs, or `null`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getPackageName.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsClient.getPackageName',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsClient#getPackageName(android.content.Context,java.util.List%3Cjava.lang.String%3E,boolean)',
    ),
  ])
  Future<String?> getPackageName(
      {List<String>? packages, bool ignoreDefault = false}) {
    throw UnimplementedError(
        'getPackageName is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData}
  ///Clear associated website data accrued from browsing activity within your app.
  ///This includes all local storage, cached resources, and cookies.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'SFSafariViewController.DataStore.clearWebsiteData',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/datastore/3981117-clearwebsitedata',
      available: '16.0',
    ),
  ])
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
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.prewarmConnections.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'SFSafariViewController.prewarmConnections',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections',
      available: '15.0',
    ),
  ])
  Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) {
    throw UnimplementedError(
        'prewarmConnections is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken}
  ///Ends all prewarmed connections associated with the token, except for connections that are also kept alive by other tokens.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'SFSafariViewController.PrewarmingToken.invalidate',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/prewarmingtoken/invalidate()',
      available: '15.0',
    ),
  ])
  Future<void> invalidatePrewarmingToken(PrewarmingToken prewarmingToken) {
    throw UnimplementedError(
        'invalidatePrewarmingToken is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose}
  ///Disposes the channel and event handler.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  @override
  @mustCallSuper
  void dispose() {
    eventHandler = null;
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformChromeSafariBrowserClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(PlatformChromeSafariBrowserMethod method,
          {TargetPlatform? platform}) =>
      _PlatformChromeSafariBrowserMethodSupported.isMethodSupported(method,
          platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.isMethodSupported}
  bool isEventMethodSupported(PlatformChromeSafariBrowserEventsMethod method,
          {TargetPlatform? platform}) =>
      PlatformChromeSafariBrowserEvents.isMethodSupported(method,
          platform: platform);
}

@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
])
abstract class PlatformChromeSafariBrowserEvents {
  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onServiceConnected}
  ///Event fired when the when connecting from Android Custom Tabs Service.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onServiceConnected.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  void onServiceConnected() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onOpened}
  ///Event fired when the [PlatformChromeSafariBrowser] is opened.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onOpened.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  void onOpened() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onCompletedInitialLoad}
  ///Event fired when the initial URL load is complete.
  ///
  ///[didLoadSuccessfully] - `true` if loading completed successfully; otherwise, `false`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onCompletedInitialLoad.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(
      apiName: 'SFSafariViewControllerDelegate.safariViewController',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/1621215-safariviewcontroller',
    ),
  ])
  void onCompletedInitialLoad(
      @SupportedPlatforms(platforms: [
        IOSPlatform(),
      ])
      bool? didLoadSuccessfully) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onInitialLoadDidRedirect}
  ///Event fired when the initial URL load is complete.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onInitialLoadDidRedirect.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName: 'SFSafariViewControllerDelegate.safariViewController',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/2923545-safariviewcontroller',
    ),
  ])
  void onInitialLoadDidRedirect(WebUri? url) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onNavigationEvent}
  ///Event fired when a navigation event happens.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onNavigationEvent.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsCallback.onNavigationEvent',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onNavigationEvent(int,android.os.Bundle)',
    ),
  ])
  void onNavigationEvent(CustomTabsNavigationEventType? navigationEvent) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onRelationshipValidationResult}
  ///Event fired when a relationship validation result is available.
  ///
  ///[relation] - Relation for which the result is available. Value previously passed to [PlatformChromeSafariBrowser.validateRelationship].
  ///
  ///[requestedOrigin] - Origin requested. Value previously passed to [PlatformChromeSafariBrowser.validateRelationship].
  ///
  ///[result] - Whether the relation was validated.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onRelationshipValidationResult.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsCallback.onRelationshipValidationResult',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onRelationshipValidationResult(int,android.net.Uri,boolean,android.os.Bundle)',
    ),
  ])
  void onRelationshipValidationResult(
      CustomTabsRelationType? relation, WebUri? requestedOrigin, bool result) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onWillOpenInBrowser}
  ///Event fired when the user opens the current page in the default browser by tapping the toolbar button.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onWillOpenInBrowser.supported_platforms}
  @SupportedPlatforms(platforms: [
    IOSPlatform(
      apiName:
          'SFSafariViewControllerDelegate.safariViewControllerWillOpenInBrowser',
      apiUrl:
          'https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/3650426-safariviewcontrollerwillopeninbr',
      available: '14.0',
    ),
  ])
  void onWillOpenInBrowser() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onMessageChannelReady}
  ///Called when the [PlatformChromeSafariBrowser] has requested a postMessage channel through
  ///[PlatformChromeSafariBrowser.requestPostMessageChannel] and the channel is ready for sending and receiving messages on both ends.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onMessageChannelReady.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsCallback.onMessageChannelReady',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onMessageChannelReady(android.os.Bundle)',
    ),
  ])
  void onMessageChannelReady() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onPostMessage}
  ///Called when a tab controlled by this [PlatformChromeSafariBrowser] has sent a postMessage.
  ///If [PlatformChromeSafariBrowser.postMessage] is called from a single thread, then the messages will be posted in the same order.
  ///When received on the client side, it is the client's responsibility to preserve the ordering further.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onPostMessage.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
      apiName: 'CustomTabsCallback.onPostMessage',
      apiUrl:
          'https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onPostMessage(java.lang.String,android.os.Bundle)',
    ),
  ])
  void onPostMessage(String message) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onVerticalScrollEvent}
  ///Called when a user scrolls the tab.
  ///
  ///[isDirectionUp] - `false` when the user scrolls farther down the page,
  ///and `true` when the user scrolls back up toward the top of the page.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onVerticalScrollEvent.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'EngagementSignalsCallback.onVerticalScrollEvent',
        apiUrl:
            'https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onVerticalScrollEvent(boolean,android.os.Bundle)'),
  ])
  void onVerticalScrollEvent(bool isDirectionUp) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onGreatestScrollPercentageIncreased}
  ///Called when a user has reached a greater scroll percentage on the page. The greatest scroll
  ///percentage is reset if the user navigates to a different page. If the current page's total
  ///height changes, this method will be called again only if the scroll progress reaches a
  ///higher percentage based on the new and current height of the page.
  ///
  ///[scrollPercentage] - An integer indicating the percent of scrollable progress
  ///the user hasmade down the current page.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onGreatestScrollPercentageIncreased.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName:
            'EngagementSignalsCallback.onGreatestScrollPercentageIncreased',
        apiUrl:
            'https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onGreatestScrollPercentageIncreased(int,android.os.Bundle)'),
  ])
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onSessionEnded}
  ///Called when a `CustomTabsSession` is ending or when no further Engagement Signals
  ///callbacks are expected to report whether any user action has occurred during the session.
  ///
  ///[didUserInteract] - Whether the user has interacted with the page in any way, e.g. scrolling.
  ///
  ///**NOTE**: available only if [PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable] returns `true`.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onSessionEnded.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(
        apiName: 'EngagementSignalsCallback.onSessionEnded',
        apiUrl:
            'https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onSessionEnded(boolean,android.os.Bundle)'),
  ])
  void onSessionEnded(bool didUserInteract) {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onClosed}
  ///Event fired when the [PlatformChromeSafariBrowser] is closed.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.onClosed.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
  ])
  void onClosed() {}

  ///{@template flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isMethodSupported(PlatformChromeSafariBrowserEventsMethod method,
          {TargetPlatform? platform}) =>
      _PlatformChromeSafariBrowserEventsMethodSupported.isMethodSupported(
          method,
          platform: platform);
}
