import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import '../types/print_job_info.dart';

// ignore: uri_has_not_been_generated
part 'platform_print_job_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformPrintJobController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ],
)
@immutable
class PlatformPrintJobControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPrintJobController].
  const PlatformPrintJobControllerCreationParams({required this.id});

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.id}
  ///Print job ID.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.id.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  final String id;

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformPrintJobControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformPrintJobControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformPrintJobControllerCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );
}

///A completion handler for the [PlatformPrintJobController].
typedef PrintJobCompletionHandler =
    Future<void> Function(bool completed, String? error)?;

///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController}
///Class representing a print job eventually returned by [PlatformInAppWebViewController.printCurrentPage].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    WindowsPlatform(),
  ],
)
abstract class PlatformPrintJobController extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformPrintJobController]
  factory PlatformPrintJobController(
    PlatformPrintJobControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPrintJobController printJobController = InAppWebViewPlatform
        .instance!
        .createPlatformPrintJobController(params);
    PlatformInterface.verify(printJobController, _token);
    return printJobController;
  }

  /// Creates a new empty [PlatformPrintJobController] to access static methods.
  factory PlatformPrintJobController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPrintJobController printJobControllerStatic =
        InAppWebViewPlatform.instance!.createPlatformPrintJobControllerStatic();
    PlatformInterface.verify(printJobControllerStatic, _token);
    return printJobControllerStatic;
  }

  /// Used by the platform implementation to create a new [PlatformPrintJobController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformPrintJobController.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformPrintJobController].
  final PlatformPrintJobControllerCreationParams params;

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.id.supported_platforms}
  String get id => params.id;

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete}
  ///A completion handler used to handle the conclusion of the print job (for instance, to reset state) and to handle any errors encountered in printing.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'PrintDocumentAdapter.onFinish',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintDocumentAdapter#onFinish()',
        note: '`completed` is always `true` and `error` is always `null`.',
      ),
      IOSPlatform(
        apiName: 'UIPrintInteractionController.CompletionHandler',
        apiUrl:
            'https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/completionhandler',
      ),
      MacOSPlatform(
        apiName: 'NSPrintOperation.runModal',
        apiUrl:
            'https://developer.apple.com/documentation/appkit/nsprintoperation/1532065-runmodal',
      ),
      WindowsPlatform(),
    ],
  )
  PrintJobCompletionHandler? onComplete;

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel}
  ///Cancels this print job.
  ///You can request cancellation of a queued, started, blocked, or failed print job.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'PrintJob.cancel',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJob#cancel()',
      ),
    ],
  )
  Future<void> cancel() {
    throw UnimplementedError(
      'cancel is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.restart}
  ///Restarts this print job.
  ///You can request restart of a failed print job.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.restart.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'PrintJob.restart',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJob#restart()',
      ),
    ],
  )
  Future<void> restart() {
    throw UnimplementedError(
      'restart is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss}
  ///Dismisses the printing-options sheet or popover.
  ///
  ///You should dismiss the printing options when they are presented in a sheet or
  ///animated from a rectangle and the user changes the orientation of the device.
  ///(This, of course, assumes your application responds to orientation changes.)
  ///You should then present the printing options again once the new orientation takes effect.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss.supported_platforms}
  @SupportedPlatforms(platforms: [IOSPlatform()])
  Future<void> dismiss({bool animated = true}) {
    throw UnimplementedError(
      'dismiss is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo}
  ///Gets the [PrintJobInfo] that describes this job.
  ///
  ///**NOTE**: The returned info object is a snapshot of the
  ///current print job state. Every call to this method returns a fresh
  ///info object that reflects the current print job state.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'PrintJob.getInfo',
        apiUrl:
            'https://developer.android.com/reference/android/print/PrintJob#getInfo()',
      ),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  Future<PrintJobInfo?> getInfo() {
    throw UnimplementedError(
      'getInfo is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose}
  ///Disposes the print job.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  @override
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///The property should be one of the [PlatformPrintJobControllerProperty] or [PlatformPrintJobControllerCreationParamsProperty] values.
  ///{@endtemplate}
  bool isPropertySupported(dynamic property, {TargetPlatform? platform}) =>
      property is PlatformPrintJobControllerCreationParamsProperty
      ? params.isPropertySupported(property, platform: platform)
      : _PlatformPrintJobControllerPropertySupported.isPropertySupported(
          property,
          platform: platform,
        );

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformPrintJobControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformPrintJobControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
