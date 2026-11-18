import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../web_uri.dart';
import '../in_app_webview/platform_webview.dart';
import 'download_state.dart';
import 'enum_method.dart';

part 'download_progress.g.dart';

///Class representing the progress of a download handled natively by the WebView,
///used by the event [PlatformWebViewCreationParams.onDownloadProgress].
@ExchangeableObject()
class DownloadProgress_ {
  ///The url of the download.
  WebUri url;

  ///The path of the file being written, if known.
  String? resultFilePath;

  ///The number of bytes received so far.
  int receivedBytes;

  ///The total number of bytes, or `null` when unknown.
  int? totalBytes;

  ///The state of the download.
  DownloadState_ state;

  ///The error description when [state] is [DownloadState_.FAILED].
  String? error;

  DownloadProgress_({
    required this.url,
    this.resultFilePath,
    this.receivedBytes = 0,
    this.totalBytes,
    required this.state,
    this.error,
  });
}
