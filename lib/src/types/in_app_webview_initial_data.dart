import '../in_app_webview/webview.dart';

///Initial [data] as a content for an [WebView] instance, using [baseUrl] as the base URL for it.
class InAppWebViewInitialData {
  ///A String of data in the given encoding.
  String data;

  ///The MIME type of the data, e.g. "text/html". The default value is `"text/html"`.
  String mimeType;

  ///The encoding of the data. The default value is `"utf8"`.
  String encoding;

  ///The URL to use as the page's base URL. The default value is `about:blank`.
  late Uri baseUrl;

  ///Use [historyUrl] instead.
  @Deprecated('Use historyUrl instead')
  late Uri androidHistoryUrl;

  ///The URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///
  ///This parameter is used only on Android.
  late Uri historyUrl;

  InAppWebViewInitialData(
      {required this.data,
        this.mimeType = "text/html",
        this.encoding = "utf8",
        Uri? baseUrl,
        @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
        Uri? historyUrl}) {
    this.baseUrl = baseUrl == null ? Uri.parse("about:blank") : baseUrl;
    this.historyUrl = historyUrl == null
        ? (androidHistoryUrl == null
        ? Uri.parse("about:blank")
        : androidHistoryUrl)
        : historyUrl;
    // ignore: deprecated_member_use_from_same_package
    this.androidHistoryUrl = this.historyUrl;
  }

  ///Gets a possible [InAppWebViewInitialData] instance from a [Map] value.
  static InAppWebViewInitialData? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return InAppWebViewInitialData(
        data: map["data"],
        mimeType: map["mimeType"],
        encoding: map["encoding"],
        baseUrl: map["baseUrl"],
        // ignore: deprecated_member_use_from_same_package
        androidHistoryUrl: map["androidHistoryUrl"],
        historyUrl: map["historyUrl"]);
  }

  ///Converts instance to a map.
  Map<String, String> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl.toString(),
      "historyUrl": historyUrl.toString()
    };
  }

  ///Converts instance to a map.
  Map<String, String> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}