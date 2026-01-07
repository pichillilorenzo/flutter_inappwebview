import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../in_app_webview/in_app_webview_controller.dart';

/// Implementation of [PlatformFindInteractionController] for Linux.
class LinuxFindInteractionController extends PlatformFindInteractionController {
  /// Creates a new [LinuxFindInteractionController].
  LinuxFindInteractionController(
    PlatformFindInteractionControllerCreationParams params,
  ) : super.implementation(params);

  /// Creates a new [LinuxFindInteractionController] to access static methods.
  LinuxFindInteractionController.static()
      : super.implementation(
          const PlatformFindInteractionControllerCreationParams(),
        );

  LinuxInAppWebViewController? _controller;

  void setController(LinuxInAppWebViewController controller) {
    _controller = controller;
  }

  @override
  Future<void> findAll({String? find}) async {
    if (_controller != null) {
      await _controller!.findAll(find: find);
    }
  }

  @override
  Future<void> findNext({bool forward = true}) async {
    if (_controller != null) {
      await _controller!.findNext(forward: forward);
    }
  }

  @override
  Future<void> clearMatches() async {
    if (_controller != null) {
      await _controller!.clearMatches();
    }
  }

  @override
  Future<void> setSearchText(String? searchText) async {
    if (_controller != null) {
      await _controller!.setSearchText(searchText);
    }
  }

  @override
  Future<String?> getSearchText() async {
    if (_controller != null) {
      return await _controller!.getSearchText();
    }
    return null;
  }

  @override
  Future<FindSession?> getActiveFindSession() async {
    if (_controller != null) {
      return await _controller!.getActiveFindSession();
    }
    return null;
  }
  
  @override
  void dispose({bool isKeepAlive = false}) {
    _controller = null;
  }
}
