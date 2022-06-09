// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a download request of the WebView used by the event [WebView.onDownloadStartRequest].
class DownloadStartRequest {
  ///The full url to the content that should be downloaded.
  Uri url;

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
  DownloadStartRequest(
      {required this.url,
      this.userAgent,
      this.contentDisposition,
      this.mimeType,
      required this.contentLength,
      this.suggestedFilename,
      this.textEncodingName});

  ///Gets a possible [DownloadStartRequest] instance from a [Map] value.
  static DownloadStartRequest? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = DownloadStartRequest(
      url: Uri.parse(map['url']),
      userAgent: map['userAgent'],
      contentDisposition: map['contentDisposition'],
      mimeType: map['mimeType'],
      contentLength: map['contentLength'],
      suggestedFilename: map['suggestedFilename'],
      textEncodingName: map['textEncodingName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "url": url.toString(),
      "userAgent": userAgent,
      "contentDisposition": contentDisposition,
      "mimeType": mimeType,
      "contentLength": contentLength,
      "suggestedFilename": suggestedFilename,
      "textEncodingName": textEncodingName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadStartRequest{url: $url, userAgent: $userAgent, contentDisposition: $contentDisposition, mimeType: $mimeType, contentLength: $contentLength, suggestedFilename: $suggestedFilename, textEncodingName: $textEncodingName}';
  }
}
