import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.supported_platforms}
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
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.settings}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.settings.supported_platforms}
  WebViewEnvironmentSettings? get settings => platform.settings;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isInterfaceSupported.supported_platforms}
  Future<bool> isInterfaceSupported(WebViewInterface interface) =>
      platform.isInterfaceSupported(interface);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getProcessInfos.supported_platforms}
  Future<List<BrowserProcessInfo>> getProcessInfos() =>
      platform.getProcessInfos();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getFailureReportFolderPath}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getFailureReportFolderPath.supported_platforms}
  Future<String?> getFailureReportFolderPath() =>
      platform.getFailureReportFolderPath();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.create.supported_platforms}
  static Future<WebViewEnvironment> create({
    WebViewEnvironmentSettings? settings,
  }) async {
    return WebViewEnvironment.fromPlatform(
      platform: await PlatformWebViewEnvironment.static().create(
        settings: settings,
      ),
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion.supported_platforms}
  static Future<String?> getAvailableVersion({
    String? browserExecutableFolder,
  }) => PlatformWebViewEnvironment.static().getAvailableVersion(
    browserExecutableFolder: browserExecutableFolder,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getAvailableVersion.supported_platforms}
  static Future<int?> compareBrowserVersions({
    required String version1,
    required String version2,
  }) => PlatformWebViewEnvironment.static().compareBrowserVersions(
    version1: version1,
    version2: version2,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onNewBrowserVersionAvailable.supported_platforms}
  void Function()? get onNewBrowserVersionAvailable =>
      platform.onNewBrowserVersionAvailable;
  set onNewBrowserVersionAvailable(void Function()? value) =>
      platform.onNewBrowserVersionAvailable = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onBrowserProcessExited.supported_platforms}
  void Function(BrowserProcessExitedDetail detail)?
  get onBrowserProcessExited => platform.onBrowserProcessExited;
  set onBrowserProcessExited(
    void Function(BrowserProcessExitedDetail detail)? value,
  ) => platform.onBrowserProcessExited = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.onProcessInfosChanged.supported_platforms}
  void Function(BrowserProcessInfosChangedDetail detail)?
  get onProcessInfosChanged => platform.onProcessInfosChanged;
  set onProcessInfosChanged(
    void Function(BrowserProcessInfosChangedDetail detail)? value,
  ) => platform.onProcessInfosChanged = value;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getCacheModel}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getCacheModel.supported_platforms}
  Future<CacheModel?> getCacheModel() => platform.getCacheModel();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isSpellCheckingEnabled}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isSpellCheckingEnabled.supported_platforms}
  Future<bool> isSpellCheckingEnabled() => platform.isSpellCheckingEnabled();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getSpellCheckingLanguages}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.getSpellCheckingLanguages.supported_platforms}
  Future<List<String>> getSpellCheckingLanguages() =>
      platform.getSpellCheckingLanguages();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isAutomationAllowed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isAutomationAllowed.supported_platforms}
  Future<bool> isAutomationAllowed() => platform.isAutomationAllowed();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.dispose.supported_platforms}
  Future<void> dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironmentCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebViewEnvironment.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebViewEnvironment.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebViewEnvironment.isMethodSupported}
  static bool isMethodSupported(
    PlatformWebViewEnvironmentMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebViewEnvironment.static().isMethodSupported(
    method,
    platform: platform,
  );
}
