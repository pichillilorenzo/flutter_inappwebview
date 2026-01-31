import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.supported_platforms}
class WebNotificationController {
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.supported_platforms}
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id.supported_platforms}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification.supported_platforms}
  WebNotification get notification => platform.notification;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.onClose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.onClose.supported_platforms}
  WebNotificationCloseHandler? get onClose => platform.onClose;

  void set onClose(WebNotificationCloseHandler? handler) {
    platform.onClose = handler;
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportShown}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportShown.supported_platforms}
  Future<void> reportShown() => platform.reportShown();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClicked}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClicked.supported_platforms}
  Future<void> reportClicked() => platform.reportClicked();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClosed}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClosed.supported_platforms}
  Future<void> reportClosed() => platform.reportClosed();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.dispose}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.dispose.supported_platforms}
  void dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformWebNotificationController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.isPropertySupported}
  static bool isPropertySupported(
    dynamic property, {
    TargetPlatform? platform,
  }) => PlatformWebNotificationController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.isMethodSupported}
  static bool isMethodSupported(
    PlatformWebNotificationControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformWebNotificationController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
