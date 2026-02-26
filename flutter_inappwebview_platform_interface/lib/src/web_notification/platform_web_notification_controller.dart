import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import '../types/web_notification.dart';

// ignore: uri_has_not_been_generated
part 'platform_web_notification_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebNotificationController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [WindowsPlatform()])
@immutable
class PlatformWebNotificationControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebNotificationController].
  const PlatformWebNotificationControllerCreationParams({
    required this.id,
    required this.notification,
  });

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id}
  ///Web notification ID.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  final String id;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification}
  ///The notification data.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  final WebNotification notification;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebNotificationControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebNotificationControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformWebNotificationControllerCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );
}

///A completion handler for the [PlatformWebNotificationController.onClose] event.
typedef WebNotificationCloseHandler = Future<void> Function()?;

///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController}
///Class representing a web notification controller.
///
///This class provides methods to report the notification has been displayed, clicked, or closed
///as required by the [ICoreWebView2Notification](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46) interface.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.supported_platforms}
@SupportedPlatforms(platforms: [WindowsPlatform()])
abstract class PlatformWebNotificationController extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformWebNotificationController]
  factory PlatformWebNotificationController(
    PlatformWebNotificationControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebNotificationController webNotificationController =
        InAppWebViewPlatform.instance!.createPlatformWebNotificationController(
          params,
        );
    PlatformInterface.verify(webNotificationController, _token);
    return webNotificationController;
  }

  /// Creates a new empty [PlatformWebNotificationController] to access static methods.
  factory PlatformWebNotificationController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebNotificationController webNotificationControllerStatic =
        InAppWebViewPlatform.instance!
            .createPlatformWebNotificationControllerStatic();
    PlatformInterface.verify(webNotificationControllerStatic, _token);
    return webNotificationControllerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformWebNotificationController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebNotificationController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebNotificationController].
  final PlatformWebNotificationControllerCreationParams params;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.id.supported_platforms}
  String get id => params.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.notification.supported_platforms}
  WebNotification get notification => params.notification;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.onClose}
  ///Event fired when the notification is closed by the web code, such as through `notification.close()`.
  ///
  ///You don't need to call [reportClosed] since this is coming from the web code.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.onClose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Notification.add_CloseRequested',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#add_closerequested',
      ),
    ],
  )
  WebNotificationCloseHandler? onClose;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportShown}
  ///The host may run this to report the notification has been displayed
  ///and it will cause the [show](https://developer.mozilla.org/docs/Web/API/Notification/show_event) event
  ///to be raised for non-persistent notifications.
  ///
  ///You must not run this unless you are handling the `onNotificationReceived` event.
  ///Returns `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)` if `handled` is `false` when this is called.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportShown.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Notification.ReportShown',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportshown',
      ),
    ],
  )
  Future<void> reportShown() {
    throw UnimplementedError(
      'reportShown is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClicked}
  ///The host may run this to report the notification has been clicked,
  ///and it will cause the [click](https://developer.mozilla.org/docs/Web/API/Notification/click_event) event
  ///to be raised for non-persistent notifications and the
  ///[notificationclick](https://developer.mozilla.org/docs/Web/API/ServiceWorkerGlobalScope/notificationclick_event)
  ///event for persistent notifications.
  ///
  ///You must not run this unless you are handling the `onNotificationReceived` event.
  ///Returns `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)` if `handled` is `false` or [reportShown] has not been run when this is called.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClicked.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Notification.ReportClicked',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportclicked',
      ),
    ],
  )
  Future<void> reportClicked() {
    throw UnimplementedError(
      'reportClicked is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClosed}
  ///The host may run this to report the notification was dismissed,
  ///and it will cause the [close](https://developer.mozilla.org/docs/Web/API/Notification/close_event) event
  ///to be raised for non-persistent notifications and the
  ///[notificationclose](https://developer.mozilla.org/docs/Web/API/ServiceWorkerGlobalScope/notificationclose_event)
  ///event for persistent notifications.
  ///
  ///You must not run this unless you are handling the `onNotificationReceived` event.
  ///Returns `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)` if `handled` is `false` or [reportShown] has not been run when this is called.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.reportClosed.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      WindowsPlatform(
        apiName: 'ICoreWebView2Notification.ReportClosed',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2notification?view=webview2-1.0.3595.46#reportclosed',
      ),
    ],
  )
  Future<void> reportClosed() {
    throw UnimplementedError(
      'reportClosed is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.dispose}
  ///Disposes the web notification controller.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationController.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  @override
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebNotificationControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///The property should be one of the [PlatformWebNotificationControllerProperty] or [PlatformWebNotificationControllerCreationParamsProperty] values.
  ///{@endtemplate}
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformWebNotificationControllerCreationParamsProperty
      ? params.isPropertySupported(property, platform: platform)
      : _PlatformWebNotificationControllerPropertySupported.isPropertySupported(
          property,
          platform: platform,
        );

  ///{@template flutter_inappwebview_platform_interface.PlatformWebNotificationController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebNotificationControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebNotificationControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
