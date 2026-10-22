import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformChromeSafariBrowser}
///
///{@macro drago_inappwebview.PlatformChromeSafariBrowser.supported_platforms}
class ChromeSafariBrowser implements PlatformChromeSafariBrowserEvents {
  ///Constructs a [ChromeSafariBrowser].
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.supported_platforms}
  ChromeSafariBrowser()
    : this.fromPlatformCreationParams(
        PlatformChromeSafariBrowserCreationParams(),
      );

  /// Constructs a [ChromeSafariBrowser] from creation params for a specific
  /// platform.
  ChromeSafariBrowser.fromPlatformCreationParams(
    PlatformChromeSafariBrowserCreationParams params,
  ) : this.fromPlatform(PlatformChromeSafariBrowser(params));

  /// Constructs a [ChromeSafariBrowser] from a specific platform
  /// implementation.
  ChromeSafariBrowser.fromPlatform(this.platform) {
    platform.eventHandler = this;
  }

  /// Implementation of [PlatformChromeSafariBrowser] for the current platform.
  final PlatformChromeSafariBrowser platform;

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.id}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.id.supported_platforms}
  String get id => platform.id;

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.open}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.open.supported_platforms}
  Future<void> open({
    WebUri? url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
    @Deprecated('Use settings instead')
    // ignore: deprecated_member_use_from_same_package
    ChromeSafariBrowserClassOptions? options,
    ChromeSafariBrowserSettings? settings,
  }) {
    platform.eventHandler = this;
    return platform.open(
      url: url,
      headers: headers,
      otherLikelyURLs: otherLikelyURLs,
      options: options,
      settings: settings,
    );
  }

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.launchUrl}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.launchUrl.supported_platforms}
  Future<void> launchUrl({
    required WebUri url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
  }) => platform.launchUrl(
    url: url,
    headers: headers,
    otherLikelyURLs: otherLikelyURLs,
    referrer: referrer,
  );

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.mayLaunchUrl}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.mayLaunchUrl.supported_platforms}
  Future<bool> mayLaunchUrl({WebUri? url, List<WebUri>? otherLikelyURLs}) =>
      platform.mayLaunchUrl(url: url, otherLikelyURLs: otherLikelyURLs);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.validateRelationship}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.validateRelationship.supported_platforms}
  Future<bool> validateRelationship({
    required CustomTabsRelationType relation,
    required WebUri origin,
  }) => platform.validateRelationship(relation: relation, origin: origin);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.close}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isOpened}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isOpened.supported_platforms}
  bool isOpened() => platform.isOpened();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.setActionButton}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.setActionButton.supported_platforms}
  void setActionButton(ChromeSafariBrowserActionButton actionButton) =>
      platform.setActionButton(actionButton);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.updateActionButton}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.updateActionButton.supported_platforms}
  Future<void> updateActionButton({
    required Uint8List icon,
    required String description,
  }) => platform.updateActionButton(icon: icon, description: description);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.setSecondaryToolbar}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.setSecondaryToolbar.supported_platforms}
  void setSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) => platform.setSecondaryToolbar(secondaryToolbar);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.updateSecondaryToolbar}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.updateSecondaryToolbar.supported_platforms}
  Future<void> updateSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) => platform.updateSecondaryToolbar(secondaryToolbar);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.addMenuItem}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.addMenuItem.supported_platforms}
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) =>
      platform.addMenuItem(menuItem);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.addMenuItems}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.addMenuItems.supported_platforms}
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) =>
      platform.addMenuItems(menuItems);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.requestPostMessageChannel}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.requestPostMessageChannel.supported_platforms}
  Future<bool> requestPostMessageChannel({
    required WebUri sourceOrigin,
    WebUri? targetOrigin,
  }) => platform.requestPostMessageChannel(
    sourceOrigin: sourceOrigin,
    targetOrigin: targetOrigin,
  );

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.postMessage}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.postMessage.supported_platforms}
  Future<CustomTabsPostMessageResultType> postMessage(String message) =>
      platform.postMessage(message);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable.supported_platforms}
  Future<bool> isEngagementSignalsApiAvailable() =>
      platform.isEngagementSignalsApiAvailable();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isAvailable}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isAvailable.supported_platforms}
  static Future<bool> isAvailable() =>
      PlatformChromeSafariBrowser.static().isAvailable();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.getMaxToolbarItems}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.getMaxToolbarItems.supported_platforms}
  static Future<int> getMaxToolbarItems() =>
      PlatformChromeSafariBrowser.static().getMaxToolbarItems();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.getPackageName}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.getPackageName.supported_platforms}
  static Future<String?> getPackageName({
    List<String>? packages,
    bool ignoreDefault = false,
  }) => PlatformChromeSafariBrowser.static().getPackageName(
    packages: packages,
    ignoreDefault: ignoreDefault,
  );

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.clearWebsiteData}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.clearWebsiteData.supported_platforms}
  static Future<void> clearWebsiteData() =>
      PlatformChromeSafariBrowser.static().clearWebsiteData();

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.prewarmConnections}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.prewarmConnections.supported_platforms}
  static Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) =>
      PlatformChromeSafariBrowser.static().prewarmConnections(URLs);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.invalidatePrewarmingToken}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.invalidatePrewarmingToken.supported_platforms}
  static Future<void> invalidatePrewarmingToken(
    PrewarmingToken prewarmingToken,
  ) => PlatformChromeSafariBrowser.static().invalidatePrewarmingToken(
    prewarmingToken,
  );

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.dispose.supported_platforms}
  @mustCallSuper
  void dispose() => platform.dispose();

  @override
  void onClosed() {}

  @override
  void onCompletedInitialLoad(bool? didLoadSuccessfully) {}

  @override
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {}

  @override
  void onInitialLoadDidRedirect(WebUri? url) {}

  @override
  void onMessageChannelReady() {}

  @override
  void onNavigationEvent(CustomTabsNavigationEventType? navigationEvent) {}

  @override
  void onOpened() {}

  @override
  void onPostMessage(String message) {}

  @override
  void onRelationshipValidationResult(
    CustomTabsRelationType? relation,
    WebUri? requestedOrigin,
    bool result,
  ) {}

  @override
  void onServiceConnected() {}

  @override
  void onSessionEnded(bool didUserInteract) {}

  @override
  void onVerticalScrollEvent(bool isDirectionUp) {}

  @override
  void onWillOpenInBrowser() {}

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformChromeSafariBrowser.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowser.isMethodSupported}
  static bool isMethodSupported(
    PlatformChromeSafariBrowserMethod property, {
    TargetPlatform? platform,
  }) => PlatformChromeSafariBrowser.static().isMethodSupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformChromeSafariBrowserEvents.isMethodSupported}
  static bool isEventMethodSupported(
    PlatformChromeSafariBrowserEventsMethod method, {
    TargetPlatform? platform,
  }) => PlatformChromeSafariBrowserEvents.isMethodSupported(
    method,
    platform: platform,
  );
}
