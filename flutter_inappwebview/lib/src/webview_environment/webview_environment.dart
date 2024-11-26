import 'dart:core';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment}
class WebViewEnvironment {
  /// Constructs a [WebViewEnvironment].
  ///
  /// See [WebViewEnvironment.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebViewEnvironment.fromPlatformCreationParams({
    required PlatformWebViewEnvironmentCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebViewEnvironment(params));

  /// Constructs a [WebViewEnvironment] from a specific platform implementation.
  WebViewEnvironment.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebViewEnvironment] for the current platform.
  final PlatformWebViewEnvironment platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.settings}
  WebViewEnvironmentSettings? get settings => platform.settings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported}
  Future<bool> isInterfaceSupported(WebViewInterface interface) =>
      platform.isInterfaceSupported(interface);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos}
  Future<List<BrowserProcessInfo>> getProcessInfos() =>
      platform.getProcessInfos();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getFailureReportFolderPath}
  Future<String?> getFailureReportFolderPath() =>
      platform.getFailureReportFolderPath();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create}
  static Future<WebViewEnvironment> create(
      {WebViewEnvironmentSettings? settings}) async {
    return WebViewEnvironment.fromPlatform(
        platform: await PlatformWebViewEnvironment.static()
            .create(settings: settings));
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  static Future<String?> getAvailableVersion(
          {String? browserExecutableFolder}) =>
      PlatformWebViewEnvironment.static().getAvailableVersion(
          browserExecutableFolder: browserExecutableFolder);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  static Future<int?> compareBrowserVersions(
          {required String version1, required String version2}) =>
      PlatformWebViewEnvironment.static()
          .compareBrowserVersions(version1: version1, version2: version2);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable}
  void Function()? get onNewBrowserVersionAvailable =>
      platform.onNewBrowserVersionAvailable;
  set onNewBrowserVersionAvailable(void Function()? value) =>
      platform.onNewBrowserVersionAvailable = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited}
  void Function(BrowserProcessExitedDetail detail)?
      get onBrowserProcessExited => platform.onBrowserProcessExited;
  set onBrowserProcessExited(
          void Function(BrowserProcessExitedDetail detail)? value) =>
      platform.onBrowserProcessExited = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged}
  void Function(BrowserProcessInfosChangedDetail detail)?
      get onProcessInfosChanged => platform.onProcessInfosChanged;
  set onProcessInfosChanged(
          void Function(BrowserProcessInfosChangedDetail detail)? value) =>
      platform.onProcessInfosChanged = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose}
  Future<void> dispose() => platform.dispose();
}
