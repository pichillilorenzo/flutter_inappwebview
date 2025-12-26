import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController}
class PrintJobController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController}
  PrintJobController({required String id})
      : this.fromPlatformCreationParams(
            params: PlatformPrintJobControllerCreationParams(id: id));

  /// Constructs a [PrintJobController].
  ///
  /// See [PrintJobController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  PrintJobController.fromPlatformCreationParams({
    required PlatformPrintJobControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformPrintJobController(params));

  /// Constructs a [PrintJobController] from a specific platform implementation.
  PrintJobController.fromPlatform({required this.platform});

  /// Implementation of [PlatformPrintJobController] for the current platform.
  final PlatformPrintJobController platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete}
  PrintJobCompletionHandler? get onComplete => platform.onComplete;

  void set onComplete(PrintJobCompletionHandler? handler) {
    platform.onComplete = handler;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel}
  Future<void> cancel() => platform.cancel();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.restart}
  Future<void> restart() => platform.restart();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss}
  Future<void> dismiss({bool animated = true}) =>
      platform.dismiss(animated: animated);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo}
  Future<PrintJobInfo?> getInfo() => platform.getInfo();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose}
  void dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPrintJobController.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.isPropertySupported}
  static bool isPropertySupported(dynamic property,
          {TargetPlatform? platform}) =>
      PlatformPrintJobController.static()
          .isPropertySupported(property, platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.isMethodSupported}
  static bool isMethodSupported(PlatformPrintJobControllerMethod method,
          {TargetPlatform? platform}) =>
      PlatformPrintJobController.static()
          .isMethodSupported(method, platform: platform);
}
