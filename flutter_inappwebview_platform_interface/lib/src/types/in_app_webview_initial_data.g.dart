// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_app_webview_initial_data.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Initial [data] as a content for an `WebView` instance, using [baseUrl] as the base URL for it.
class InAppWebViewInitialData {
  ///Use [historyUrl] instead.
  @Deprecated('Use historyUrl instead')
  Uri? androidHistoryUrl;

  ///The URL to use as the page's base URL. If `null` defaults to `about:blank`.
  WebUri? baseUrl;

  ///A String of data in the given encoding.
  String data;

  ///The encoding of the data. The default value is `"utf8"`.
  String encoding;

  ///The URL to use as the history entry. If `null` defaults to `about:blank`. If non-null, this must be a valid URL.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  WebUri? historyUrl;

  ///The MIME type of the data, e.g. "text/html". The default value is `"text/html"`.
  String mimeType;
  InAppWebViewInitialData({
    @Deprecated('Use historyUrl instead') this.androidHistoryUrl,
    this.baseUrl,
    required this.data,
    this.encoding = "utf8",
    this.historyUrl,
    this.mimeType = "text/html",
  }) {
    historyUrl =
        historyUrl ??
        (androidHistoryUrl != null ? WebUri.uri(androidHistoryUrl!) : null);
  }

  ///Gets a possible [InAppWebViewInitialData] instance from a [Map] value.
  static InAppWebViewInitialData? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = InAppWebViewInitialData(
      androidHistoryUrl: map['historyUrl'] != null
          ? Uri.tryParse(map['historyUrl'])
          : null,
      baseUrl: map['baseUrl'] != null ? WebUri(map['baseUrl']) : null,
      data: map['data'],
      historyUrl: map['historyUrl'] != null ? WebUri(map['historyUrl']) : null,
    );
    if (map['encoding'] != null) {
      instance.encoding = map['encoding'];
    }
    if (map['mimeType'] != null) {
      instance.mimeType = map['mimeType'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "baseUrl": baseUrl?.toString(),
      "data": data,
      "encoding": encoding,
      "historyUrl": historyUrl?.toString(),
      "mimeType": mimeType,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'InAppWebViewInitialData{baseUrl: $baseUrl, data: $data, encoding: $encoding, historyUrl: $historyUrl, mimeType: $mimeType}';
  }
}
