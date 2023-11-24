import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import '../in_app_webview/platform_webview.dart';

part 'download_start_request.g.dart';

///Class representing a download request of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
@ExchangeableObject()
class DownloadStartRequest_ {
  ///The full url to the content that should be downloaded.
  WebUri url;

  ///the user agent to be used for the download.
  String? userAgent;

  ///Content-disposition http header, if present.
  String? contentDisposition;

  ///The mimetype of the content reported by the server.
  String? mimeType;

  ///The file size reported by the server.
  int contentLength;

  ///A suggested filename to use if saving the resource to disk.
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  String? textEncodingName;

  DownloadStartRequest_(
      {required this.url,
      this.userAgent,
      this.contentDisposition,
      this.mimeType,
      required this.contentLength,
      this.suggestedFilename,
      this.textEncodingName});
}
