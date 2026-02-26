import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser}
///
///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.supported_platforms}
class ChromeSafariBrowser implements PlatformChromeSafariBrowserEvents {
  ///Constructs a [ChromeSafariBrowser].
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.supported_platforms}
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
    this.platform.eventHandler = this;
  }

  /// Implementation of [PlatformChromeSafariBrowser] for the current platform.
  final PlatformChromeSafariBrowser platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.open}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.open.supported_platforms}
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
    this.platform.eventHandler = this;
    return platform.open(
      url: url,
      headers: headers,
      otherLikelyURLs: otherLikelyURLs,
      options: options,
      settings: settings,
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.launchUrl}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.launchUrl.supported_platforms}
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.mayLaunchUrl}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.mayLaunchUrl.supported_platforms}
  Future<bool> mayLaunchUrl({WebUri? url, List<WebUri>? otherLikelyURLs}) =>
      platform.mayLaunchUrl(url: url, otherLikelyURLs: otherLikelyURLs);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.validateRelationship}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.validateRelationship.supported_platforms}
  Future<bool> validateRelationship({
    required CustomTabsRelationType relation,
    required WebUri origin,
  }) => platform.validateRelationship(relation: relation, origin: origin);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.close.supported_platforms}
  Future<void> close() => platform.close();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isOpened.supported_platforms}
  bool isOpened() => platform.isOpened();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setActionButton.supported_platforms}
  void setActionButton(ChromeSafariBrowserActionButton actionButton) =>
      platform.setActionButton(actionButton);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateActionButton.supported_platforms}
  Future<void> updateActionButton({
    required Uint8List icon,
    required String description,
  }) => platform.updateActionButton(icon: icon, description: description);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.setSecondaryToolbar.supported_platforms}
  void setSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) => platform.setSecondaryToolbar(secondaryToolbar);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.updateSecondaryToolbar.supported_platforms}
  Future<void> updateSecondaryToolbar(
    ChromeSafariBrowserSecondaryToolbar secondaryToolbar,
  ) => platform.updateSecondaryToolbar(secondaryToolbar);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItem.supported_platforms}
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) =>
      platform.addMenuItem(menuItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.addMenuItems.supported_platforms}
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) =>
      platform.addMenuItems(menuItems);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.requestPostMessageChannel}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.requestPostMessageChannel.supported_platforms}
  Future<bool> requestPostMessageChannel({
    required WebUri sourceOrigin,
    WebUri? targetOrigin,
  }) => platform.requestPostMessageChannel(
    sourceOrigin: sourceOrigin,
    targetOrigin: targetOrigin,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.postMessage}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.postMessage.supported_platforms}
  Future<CustomTabsPostMessageResultType> postMessage(String message) =>
      platform.postMessage(message);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isEngagementSignalsApiAvailable.supported_platforms}
  Future<bool> isEngagementSignalsApiAvailable() =>
      platform.isEngagementSignalsApiAvailable();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isAvailable.supported_platforms}
  static Future<bool> isAvailable() =>
      PlatformChromeSafariBrowser.static().isAvailable();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getMaxToolbarItems.supported_platforms}
  static Future<int> getMaxToolbarItems() =>
      PlatformChromeSafariBrowser.static().getMaxToolbarItems();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getPackageName}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.getPackageName.supported_platforms}
  static Future<String?> getPackageName({
    List<String>? packages,
    bool ignoreDefault = false,
  }) => PlatformChromeSafariBrowser.static().getPackageName(
    packages: packages,
    ignoreDefault: ignoreDefault,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.clearWebsiteData.supported_platforms}
  static Future<void> clearWebsiteData() =>
      PlatformChromeSafariBrowser.static().clearWebsiteData();

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.prewarmConnections}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.prewarmConnections.supported_platforms}
  static Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) =>
      PlatformChromeSafariBrowser.static().prewarmConnections(URLs);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.invalidatePrewarmingToken.supported_platforms}
  static Future<void> invalidatePrewarmingToken(
    PrewarmingToken prewarmingToken,
  ) => PlatformChromeSafariBrowser.static().invalidatePrewarmingToken(
    prewarmingToken,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.dispose.supported_platforms}
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformChromeSafariBrowser.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.isMethodSupported}
  static bool isMethodSupported(
    PlatformChromeSafariBrowserMethod property, {
    TargetPlatform? platform,
  }) => PlatformChromeSafariBrowser.static().isMethodSupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowserEvents.isMethodSupported}
  static bool isEventMethodSupported(
    PlatformChromeSafariBrowserEventsMethod method, {
    TargetPlatform? platform,
  }) => PlatformChromeSafariBrowserEvents.isMethodSupported(
    method,
    platform: platform,
  );
}
