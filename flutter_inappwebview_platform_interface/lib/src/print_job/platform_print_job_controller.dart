import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import '../types/print_job_info.dart';

///A completion handler for the [PlatformPrintJobController].
typedef PrintJobCompletionHandler = Future<void> Function(
    bool completed, String? error)?;

/// Object specifying creation parameters for creating a [PlatformPrintJobController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformPrintJobControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformPrintJobController].
  const PlatformPrintJobControllerCreationParams(
      {required this.id});

  ///{@macro flutter_inappwebview_platform_interface.PlatformPrintJobController.id}
  final String id;
}

///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController}
///Class representing a print job eventually returned by [PlatformInAppWebViewController.printCurrentPage].
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///{@endtemplate}
abstract class PlatformPrintJobController extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformPrintJobController]
  factory PlatformPrintJobController(
      PlatformPrintJobControllerCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformPrintJobController printJobController =
        InAppWebViewPlatform.instance!.createPlatformPrintJobController(params);
    PlatformInterface.verify(printJobController, _token);
    return printJobController;
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

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.id}
  ///Print job ID.
  ///{@endtemplate}
  String get id => params.id;

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.onComplete}
  ///A completion handler used to handle the conclusion of the print job (for instance, to reset state) and to handle any errors encountered in printing.
  ///
  ///**NOTE for Android**: `completed` is always `true` and `error` is always `null`.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintDocumentAdapter.onFinish](https://developer.android.com/reference/android/print/PrintDocumentAdapter#onFinish()))
  ///- iOS ([Official API - UIPrintInteractionController.CompletionHandler](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/completionhandler))
  ///- MacOS ([Official API - NSPrintOperation.runModal](https://developer.apple.com/documentation/appkit/nsprintoperation/1532065-runmodal))
  ///{@endtemplate}
  PrintJobCompletionHandler? onComplete;

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.cancel}
  ///Cancels this print job.
  ///You can request cancellation of a queued, started, blocked, or failed print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.cancel](https://developer.android.com/reference/android/print/PrintJob#cancel()))
  ///{@endtemplate}
  Future<void> cancel() {
    throw UnimplementedError(
        'cancel is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.restart}
  ///Restarts this print job.
  ///You can request restart of a failed print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.restart](https://developer.android.com/reference/android/print/PrintJob#restart()))
  ///{@endtemplate}
  Future<void> restart() {
    throw UnimplementedError(
        'restart is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dismiss}
  ///Dismisses the printing-options sheet or popover.
  ///
  ///You should dismiss the printing options when they are presented in a sheet or
  ///animated from a rectangle and the user changes the orientation of the device.
  ///(This, of course, assumes your application responds to orientation changes.)
  ///You should then present the printing options again once the new orientation takes effect.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS
  ///{@endtemplate}
  Future<void> dismiss({bool animated = true}) {
    throw UnimplementedError(
        'dismiss is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.getInfo}
  ///Gets the [PrintJobInfo] that describes this job.
  ///
  ///**NOTE**: The returned info object is a snapshot of the
  ///current print job state. Every call to this method returns a fresh
  ///info object that reflects the current print job state.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.getInfo](https://developer.android.com/reference/android/print/PrintJob#getInfo()))
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  Future<PrintJobInfo?> getInfo() {
    throw UnimplementedError(
        'getInfo is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformPrintJobController.dispose}
  ///Disposes the print job.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///{@endtemplate}
  @override
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }
}
