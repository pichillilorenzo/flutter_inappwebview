import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [WindowsWebViewEnvironment].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class WindowsWebViewEnvironmentCreationParams
    extends PlatformWebViewEnvironmentCreationParams {
  /// Creates a new [WindowsInAppWebViewControllerCreationParams] instance.
  const WindowsWebViewEnvironmentCreationParams({super.settings});

  /// Creates a [WindowsInAppWebViewControllerCreationParams] instance based on [PlatformInAppWebViewControllerCreationParams].
  factory WindowsWebViewEnvironmentCreationParams.fromPlatformWebViewEnvironmentCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewEnvironmentCreationParams params,
  ) {
    return WindowsWebViewEnvironmentCreationParams(settings: params.settings);
  }
}

///Controls a WebView Environment used by WebView instances.
///
///**Officially Supported Platforms/Implementations**:
///- Windows
class WindowsWebViewEnvironment extends PlatformWebViewEnvironment
    with ChannelController {
  static final MethodChannel _staticChannel = MethodChannel(
    'com.pichillilorenzo/flutter_webview_environment',
  );

  @override
  final String id = IdGenerator.generate();

  WindowsWebViewEnvironment(PlatformWebViewEnvironmentCreationParams params)
    : super.implementation(
        params is WindowsWebViewEnvironmentCreationParams
            ? params
            : WindowsWebViewEnvironmentCreationParams.fromPlatformWebViewEnvironmentCreationParams(
                params,
              ),
      );

  static final WindowsWebViewEnvironment _staticValue =
      WindowsWebViewEnvironment(WindowsWebViewEnvironmentCreationParams());

  factory WindowsWebViewEnvironment.static() {
    return _staticValue;
  }

  _debugLog(String method, dynamic args) {
    debugLog(
      className: this.runtimeType.toString(),
      id: id,
      debugLoggingSettings: PlatformWebViewEnvironment.debugLoggingSettings,
      method: method,
      args: args,
    );
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (PlatformWebViewEnvironment.debugLoggingSettings.enabled) {
      _debugLog(call.method, call.arguments);
    }

    switch (call.method) {
      case 'onNewBrowserVersionAvailable':
        if (onNewBrowserVersionAvailable != null) {
          onNewBrowserVersionAvailable?.call();
        }
        break;
      case 'onBrowserProcessExited':
        if (onBrowserProcessExited != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          final detail = BrowserProcessExitedDetail.fromMap(arguments)!;
          onBrowserProcessExited?.call(detail);
        }
        break;
      case 'onProcessInfosChanged':
        if (onProcessInfosChanged != null) {
          Map<String, dynamic> arguments = call.arguments
              .cast<String, dynamic>();
          final detail = BrowserProcessInfosChangedDetail.fromMap(arguments)!;
          onProcessInfosChanged?.call(detail);
        }
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  Future<bool> isInterfaceSupported(WebViewInterface interface) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('interface', () => interface.toNativeValue());
    return await channel?.invokeMethod<bool>('isInterfaceSupported', args) ??
        false;
  }

  @override
  Future<List<BrowserProcessInfo>> getProcessInfos() async {
    // The shared channel getter asserts when disposed in debug builds.
    final environmentChannel = disposed ? null : channel;
    if (environmentChannel == null) {
      throw PlatformException(
        code: 'webview_environment_unavailable',
        message:
            'The WebView environment has not been created or was disposed.',
        details: {'stage': 'channel'},
      );
    }
    Map<String, dynamic> args = <String, dynamic>{};
    final result = await environmentChannel.invokeMethod<Object?>(
      'getProcessInfos',
      args,
    );
    if (result is! List) {
      throw PlatformException(
        code: 'process_info_collection_failed',
        message: 'The native process collection returned no snapshot.',
        details: {'stage': 'methodChannel.result'},
      );
    }
    try {
      return result.map((e) {
        if (e is! Map) {
          throw const FormatException('Process information must be a map.');
        }
        return BrowserProcessInfo.fromMap(e.cast<String, dynamic>())!;
      }).toList();
    } catch (error) {
      if (error is! TypeError &&
          error is! NoSuchMethodError &&
          error is! FormatException) {
        rethrow;
      }
      throw PlatformException(
        code: 'process_info_collection_failed',
        message: 'The native process snapshot contains invalid information.',
        details: {'stage': 'methodChannel.decode'},
      );
    }
  }

  @override
  Future<String?> getFailureReportFolderPath() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<String>(
      'getFailureReportFolderPath',
      args,
    );
  }

  @override
  Future<WindowsWebViewEnvironment> create({
    WebViewEnvironmentSettings? settings,
  }) async {
    final env = WindowsWebViewEnvironment(
      WindowsWebViewEnvironmentCreationParams(settings: settings),
    );

    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('id', () => env.id);
    args.putIfAbsent('settings', () => env.settings?.toMap());
    await _staticChannel.invokeMethod('create', args);

    env.channel = MethodChannel(
      'com.pichillilorenzo/flutter_webview_environment_${env.id}',
    );
    env.handler = env.handleMethod;
    env.initMethodCallHandler();
    return env;
  }

  @override
  Future<WebViewEnvironmentPrewarmResult?> prewarm({
    WebViewEnvironmentSettings? settings,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('settings', () => settings?.toMap());
    final stopwatch = Stopwatch()..start();
    try {
      final result = await _staticChannel
          .invokeMethod<Map<dynamic, dynamic>>('prewarm', args)
          .timeout(const Duration(seconds: 31));
      return WebViewEnvironmentPrewarmResult.fromMap(
        result?.cast<String, dynamic>(),
      );
    } on TimeoutException {
      return WebViewEnvironmentPrewarmResult(
        status: 'timeout',
        duration: stopwatch.elapsed,
      );
    } catch (_) {
      // Prewarming is optional, including with an older/missing native plugin.
      return WebViewEnvironmentPrewarmResult(
        status: 'unavailable',
        duration: stopwatch.elapsed,
      );
    }
  }

  @override
  Future<String?> getAvailableVersion({String? browserExecutableFolder}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('browserExecutableFolder', () => browserExecutableFolder);
    return await _staticChannel.invokeMethod<String>(
      'getAvailableVersion',
      args,
    );
  }

  @override
  Future<int?> compareBrowserVersions({
    required String version1,
    required String version2,
  }) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('version1', () => version1);
    args.putIfAbsent('version2', () => version2);
    return await _staticChannel.invokeMethod<int>(
      'compareBrowserVersions',
      args,
    );
  }

  @override
  Future<void> dispose() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('dispose', args);
    disposeChannel();
  }
}

extension InternalWindowsWebViewEnvironment on WindowsWebViewEnvironment {
  get handleMethod => _handleMethod;
}
