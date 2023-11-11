import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/src/util.dart';
import '../types/print_job_info.dart';
import '../in_app_webview/in_app_webview_controller.dart';

///A completion handler for the [PrintJobController].
typedef PrintJobCompletionHandler = Future<void> Function(
    bool completed, String? error)?;

///Class representing a print job eventually returned by [InAppWebViewController.printCurrentPage].
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class PrintJobController extends ChannelController {
  ///Print job ID.
  final String id;

  ///A completion handler used to handle the conclusion of the print job (for instance, to reset state) and to handle any errors encountered in printing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - UIPrintInteractionController.CompletionHandler](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/completionhandler))
  ///- MacOS ([Official API - NSPrintOperation.runModal](https://developer.apple.com/documentation/appkit/nsprintoperation/1532065-runmodal))
  PrintJobCompletionHandler onComplete;

  PrintJobController({required this.id}) {
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_printjobcontroller_$id');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onComplete":
        bool completed = call.arguments["completed"];
        String? error = call.arguments["error"];
        if (onComplete != null) {
          onComplete!(completed, error);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
  }

  ///Cancels this print job.
  ///You can request cancellation of a queued, started, blocked, or failed print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.cancel](https://developer.android.com/reference/android/print/PrintJob#cancel()))
  Future<void> cancel() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('cancel', args);
  }

  ///Restarts this print job.
  ///You can request restart of a failed print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintJob.restart](https://developer.android.com/reference/android/print/PrintJob#restart()))
  Future<void> restart() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('restart', args);
  }

  ///Dismisses the printing-options sheet or popover.
  ///
  ///You should dismiss the printing options when they are presented in a sheet or
  ///animated from a rectangle and the user changes the orientation of the device.
  ///(This, of course, assumes your application responds to orientation changes.)
  ///You should then present the printing options again once the new orientation takes effect.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS
  Future<void> dismiss({bool animated: true}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("animated", () => animated);
    await channel?.invokeMethod('dismiss', args);
  }

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
  Future<PrintJobInfo?> getInfo() async {
    Map<String, dynamic> args = <String, dynamic>{};
    Map<String, dynamic>? infoMap =
        (await channel?.invokeMethod('getInfo', args))
            ?.cast<String, dynamic>();
    return PrintJobInfo.fromMap(infoMap);
  }

  ///Disposes the print job.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  @override
  Future<void> dispose() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('dispose', args);
    disposeChannel();
  }
}
