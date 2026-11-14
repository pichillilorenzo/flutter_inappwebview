import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformWebNotificationController}
///
///{@macro drago_inappwebview.PlatformWebNotificationController.supported_platforms}
class WebNotificationController {
  ///{@macro drago_inappwebview.PlatformWebNotificationController}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.supported_platforms}
  WebNotificationController({
    required String id,
    required WebNotification notification,
  }) : this.fromPlatformCreationParams(
         params: PlatformWebNotificationControllerCreationParams(
           id: id,
           notification: notification,
         ),
       );

  /// Constructs a [WebNotificationController].
  ///
  /// See [WebNotificationController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebNotificationController.fromPlatformCreationParams({
    required PlatformWebNotificationControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebNotificationController(params));

  /// Constructs a [WebNotificationController] from a specific platform implementation.
  WebNotificationController.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebNotificationController] for the current platform.
  final PlatformWebNotificationController platform;

  ///{@macro drago_inappwebview.PlatformWebNotificationControllerCreationParams.id}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationControllerCreationParams.id.supported_platforms}
  String get id => platform.id;

  ///{@macro drago_inappwebview.PlatformWebNotificationControllerCreationParams.notification}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationControllerCreationParams.notification.supported_platforms}
  WebNotification get notification => platform.notification;

  ///{@macro drago_inappwebview.PlatformWebNotificationController.onClose}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.onClose.supported_platforms}
  WebNotificationCloseHandler? get onClose => platform.onClose;

  set onClose(WebNotificationCloseHandler? handler) {
    platform.onClose = handler;
  }

  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportShown}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportShown.supported_platforms}
  Future<void> reportShown() => platform.reportShown();

  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportClicked}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportClicked.supported_platforms}
  Future<void> reportClicked() => platform.reportClicked();

  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportClosed}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.reportClosed.supported_platforms}
  Future<void> reportClosed() => platform.reportClosed();

  ///{@macro drago_inappwebview.PlatformWebNotificationController.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformWebNotificationController.dispose.supported_platforms}
  void dispose() => platform.dispose();

  ///{@macro drago_inappwebview.PlatformWebNotificationControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebNotificationController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro drago_inappwebview.PlatformWebNotificationController.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebNotificationController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformWebNotificationController.isMethodSupported}
  static bool isMethodSupported(
    PlatformWebNotificationControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebNotificationController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
