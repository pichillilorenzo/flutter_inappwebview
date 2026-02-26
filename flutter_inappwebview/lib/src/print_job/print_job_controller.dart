import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.supported_platforms}
class PrintJobController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.supported_platforms}
  PrintJobController({required String id})
    : this.fromPlatformCreationParams(
        params: PlatformPrintJobControllerCreationParams(id: id),
      );

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
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete.supported_platforms}
  PrintJobCompletionHandler? get onComplete => platform.onComplete;

  void set onComplete(PrintJobCompletionHandler? handler) {
    platform.onComplete = handler;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel.supported_platforms}
  Future<void> cancel() => platform.cancel();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.restart}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.restart.supported_platforms}
  Future<void> restart() => platform.restart();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss.supported_platforms}
  Future<void> dismiss({bool animated = true}) =>
      platform.dismiss(animated: animated);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo.supported_platforms}
  Future<PrintJobInfo?> getInfo() => platform.getInfo();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose.supported_platforms}
  void dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPrintJobController.static().isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformPrintJobController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.isMethodSupported}
  static bool isMethodSupported(
    PlatformPrintJobControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformPrintJobController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
