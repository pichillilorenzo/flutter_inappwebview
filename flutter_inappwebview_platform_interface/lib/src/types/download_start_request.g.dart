// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a download request of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
class DownloadStartRequest {
  ///Content-disposition http header, if present.
  String? contentDisposition;

  ///The file size reported by the server.
  int contentLength;

  ///The mimetype of the content reported by the server.
  String? mimeType;

  ///A suggested filename to use if saving the resource to disk.
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  String? textEncodingName;

  ///The full url to the content that should be downloaded.
  WebUri url;

  ///the user agent to be used for the download.
  String? userAgent;
  DownloadStartRequest(
      {this.contentDisposition,
      required this.contentLength,
      this.mimeType,
      this.suggestedFilename,
      this.textEncodingName,
      required this.url,
      this.userAgent});

  ///Gets a possible [DownloadStartRequest] instance from a [Map] value.
  static DownloadStartRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = DownloadStartRequest(
      contentDisposition: map['contentDisposition'],
      contentLength: map['contentLength'],
      mimeType: map['mimeType'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
      url: WebUri(map['url']),
      userAgent: map['userAgent'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "contentDisposition": contentDisposition,
      "contentLength": contentLength,
      "mimeType": mimeType,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
      "url": url.toString(),
      "userAgent": userAgent,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadStartRequest{contentDisposition: $contentDisposition, contentLength: $contentLength, mimeType: $mimeType, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName, url: $url, userAgent: $userAgent}';
  }
}
