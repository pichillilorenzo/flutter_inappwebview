import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import '../in_app_webview/in_app_webview_controller.dart';

///Class representing a print job eventually returned by [InAppWebViewController.printCurrentPage].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class PrintJobController {
  PrintJobController({required String id, PrintJobCompletionHandler onComplete})
      : this.fromPlatformCreationParams(
            params: PlatformPrintJobControllerCreationParams(
                id: id, onComplete: onComplete));

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

  ///Cancels this print job.
  ///You can request cancellation of a queued, started, blocked, or failed print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.cancel](https://developer.android.com/reference/android/print/PrintJob#cancel()))
  Future<void> cancel() => platform.cancel();

  ///Restarts this print job.
  ///You can request restart of a failed print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.restart](https://developer.android.com/reference/android/print/PrintJob#restart()))
  Future<void> restart() => platform.restart();

  ///Dismisses the printing-options sheet or popover.
  ///
  ///You should dismiss the printing options when they are presented in a sheet or
  ///animated from a rectangle and the user changes the orientation of the device.
  ///(This, of course, assumes your application responds to orientation changes.)
  ///You should then present the printing options again once the new orientation takes effect.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Future<void> dismiss({bool animated = true}) =>
      platform.dismiss(animated: animated);

  ///Gets the [PrintJobInfo] that describes this job.
  ///
  ///**NOTE**: The returned info object is a snapshot of the
  ///current print job state. Every call to this method returns a fresh
  ///info object that reflects the current print job state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.getInfo](https://developer.android.com/reference/android/print/PrintJob#getInfo()))
  ///- iOS
  ///- MacOS
  Future<PrintJobInfo?> getInfo() => platform.getInfo();

  ///Disposes the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void dispose() => platform.dispose();
}
