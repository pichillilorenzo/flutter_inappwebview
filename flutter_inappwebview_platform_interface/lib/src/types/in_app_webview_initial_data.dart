import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';

part 'in_app_webview_initial_data.g.dart';

///Initial [data] as a content for an `WebView` instance, using [baseUrl] as the base URL for it.
@ExchangeableObject()
class InAppWebViewInitialData_ {
  ///A String of data in the given encoding.
  String data;

  ///The MIME type of the data, e.g. "text/html". The default value is `"text/html"`.
  String mimeType;

  ///The encoding of the data. The default value is `"utf8"`.
  String encoding;

  ///The URL to use as the page's base URL. If `null` defaults to `about:blank`.
  WebUri? baseUrl;

  ///Use [historyUrl] instead.
  @Deprecated('Use historyUrl instead')
  Uri? androidHistoryUrl;

  ///The URL to use as the history entry. If `null` defaults to `about:blank`. If non-null, this must be a valid URL.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  WebUri? historyUrl;

  InAppWebViewInitialData_({
    required this.data,
    this.mimeType = "text/html",
    this.encoding = "utf8",
    this.baseUrl,
    @Deprecated('Use historyUrl instead') this.androidHistoryUrl,
    this.historyUrl,
  });
}
