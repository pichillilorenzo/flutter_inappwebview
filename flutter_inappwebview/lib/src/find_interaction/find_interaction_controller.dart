import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController}
class FindInteractionController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController}
  FindInteractionController(
      {void Function(PlatformFindInteractionController controller,
              int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
          onFindResultReceived})
      : this.fromPlatformCreationParams(
            params: PlatformFindInteractionControllerCreationParams(
                onFindResultReceived: onFindResultReceived));

  /// Constructs a [FindInteractionController].
  ///
  /// See [FindInteractionController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  FindInteractionController.fromPlatformCreationParams({
    required PlatformFindInteractionControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformFindInteractionController(params));

  /// Constructs a [FindInteractionController] from a specific platform implementation.
  FindInteractionController.fromPlatform({required this.platform});

  /// Implementation of [PlatformFindInteractionController] for the current platform.
  final PlatformFindInteractionController platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.onFindResultReceived}
  void Function(PlatformFindInteractionController controller,
          int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting)?
      get onFindResultReceived => platform.onFindResultReceived;

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.findAll}
  Future<void> findAll({String? find}) => platform.findAll(find: find);

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.findNext}
  Future<void> findNext({bool forward = true}) =>
      platform.findNext(forward: forward);

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.clearMatches}
  Future<void> clearMatches() => platform.clearMatches();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.setSearchText}
  Future<void> setSearchText(String? searchText) =>
      platform.setSearchText(searchText);

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.getSearchText}
  Future<String?> getSearchText() => platform.getSearchText();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.isFindNavigatorVisible}
  Future<bool?> isFindNavigatorVisible() => platform.isFindNavigatorVisible();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.updateResultCount}
  Future<void> updateResultCount() => platform.updateResultCount();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.presentFindNavigator}
  Future<void> presentFindNavigator() => platform.presentFindNavigator();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.dismissFindNavigator}
  Future<void> dismissFindNavigator() => platform.dismissFindNavigator();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.getActiveFindSession}
  Future<FindSession?> getActiveFindSession() =>
      platform.getActiveFindSession();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.dispose}
  void dispose({bool isKeepAlive = false}) => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformFindInteractionController.static()
          .isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.isPropertySupported}
  static bool isPropertySupported(
          PlatformFindInteractionControllerCreationParamsProperty property,
          {TargetPlatform? platform}) =>
      PlatformFindInteractionController.static()
          .isPropertySupported(property, platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformFindInteractionController.isMethodSupported}
  static bool isMethodSupported(PlatformFindInteractionControllerMethod method,
          {TargetPlatform? platform}) =>
      PlatformFindInteractionController.static()
          .isMethodSupported(method, platform: platform);
}
