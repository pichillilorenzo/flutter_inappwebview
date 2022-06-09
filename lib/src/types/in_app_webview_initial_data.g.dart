// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_initial_data.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Initial [data] as a content for an [WebView] instance, using [baseUrl] as the base URL for it.
class InAppWebViewInitialData {
  ///A String of data in the given encoding.
  String data;

  ///The MIME type of the data, e.g. "text/html". The default value is `"text/html"`.
  String mimeType;

  ///The encoding of the data. The default value is `"utf8"`.
  String encoding;

  ///The URL to use as the page's base URL. If `null` defaults to `about:blank`.
  Uri? baseUrl;

  ///Use [historyUrl] instead.
  @Deprecated('Use historyUrl instead')
  Uri? androidHistoryUrl;

  ///The URL to use as the history entry. If `null` defaults to `about:blank`. If non-null, this must be a valid URL.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  Uri? historyUrl;
  InAppWebViewInitialData(
      {required this.data,
      this.mimeType = "text/html",
      this.encoding = "utf8",
      this.baseUrl,
      @Deprecated('Use historyUrl instead') this.androidHistoryUrl,
      this.historyUrl}) {
    historyUrl = historyUrl ?? androidHistoryUrl;
  }

  ///Gets a possible [InAppWebViewInitialData] instance from a [Map] value.
  static InAppWebViewInitialData? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewInitialData(
      data: map['data'],
      baseUrl: map['baseUrl'] != null ? Uri.parse(map['baseUrl']) : null,
      androidHistoryUrl:
          map['historyUrl'] != null ? Uri.parse(map['historyUrl']) : null,
      historyUrl:
          map['historyUrl'] != null ? Uri.parse(map['historyUrl']) : null,
    );
    instance.mimeType = map['mimeType'];
    instance.encoding = map['encoding'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "mimeType": mimeType,
      "encoding": encoding,
      "baseUrl": baseUrl?.toString(),
      "historyUrl": historyUrl?.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppWebViewInitialData{data: $data, mimeType: $mimeType, encoding: $encoding, baseUrl: $baseUrl, historyUrl: $historyUrl}';
  }
}
