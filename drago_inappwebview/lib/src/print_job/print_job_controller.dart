import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformPrintJobController}
///
///{@macro drago_inappwebview.PlatformPrintJobController.supported_platforms}
class PrintJobController {
  ///{@macro drago_inappwebview.PlatformPrintJobController}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.supported_platforms}
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

  ///{@macro drago_inappwebview.PlatformPrintJobController.id}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.id.supported_platforms}
  String get id => platform.id;

  ///{@macro drago_inappwebview.PlatformPrintJobController.onComplete}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.onComplete.supported_platforms}
  PrintJobCompletionHandler? get onComplete => platform.onComplete;

  set onComplete(PrintJobCompletionHandler? handler) {
    platform.onComplete = handler;
  }

  ///{@macro drago_inappwebview.PlatformPrintJobController.cancel}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.cancel.supported_platforms}
  Future<void> cancel() => platform.cancel();

  ///{@macro drago_inappwebview.PlatformPrintJobController.restart}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.restart.supported_platforms}
  Future<void> restart() => platform.restart();

  ///{@macro drago_inappwebview.PlatformPrintJobController.dismiss}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.dismiss.supported_platforms}
  Future<void> dismiss({bool animated = true}) =>
      platform.dismiss(animated: animated);

  ///{@macro drago_inappwebview.PlatformPrintJobController.getInfo}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.getInfo.supported_platforms}
  Future<PrintJobInfo?> getInfo() => platform.getInfo();

  ///{@macro drago_inappwebview.PlatformPrintJobController.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformPrintJobController.dispose.supported_platforms}
  void dispose() => platform.dispose();

  ///{@macro drago_inappwebview.PlatformPrintJobControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPrintJobController.static().isClassSupported(platform: platform);

  ///{@macro drago_inappwebview.PlatformPrintJobController.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformPrintJobController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformPrintJobController.isMethodSupported}
  static bool isMethodSupported(
    PlatformPrintJobControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformPrintJobController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
