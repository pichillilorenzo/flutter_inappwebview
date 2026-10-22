// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_progress.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the progress of a download handled natively by the WebView,
///used by the event [PlatformWebViewCreationParams.onDownloadProgress].
class DownloadProgress {
  ///The error description when [state] is [DownloadState_.FAILED].
  String? error;

  ///The number of bytes received so far.
  int receivedBytes;

  ///The path of the file being written, if known.
  String? resultFilePath;

  ///The state of the download.
  DownloadState state;

  ///The total number of bytes, or `null` when unknown.
  int? totalBytes;

  ///The url of the download.
  WebUri url;
  DownloadProgress({
    this.error,
    this.receivedBytes = 0,
    this.resultFilePath,
    required this.state,
    this.totalBytes,
    required this.url,
  });

  ///Gets a possible [DownloadProgress] instance from a [Map] value.
  static DownloadProgress? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = DownloadProgress(
      error: map['error'],
      resultFilePath: map['resultFilePath'],
      state: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => DownloadState.fromNativeValue(map['state']),
        EnumMethod.value => DownloadState.fromValue(map['state']),
        EnumMethod.name => DownloadState.byName(map['state']),
      }!,
      totalBytes: map['totalBytes'],
      url: WebUri(map['url']),
    );
    if (map['receivedBytes'] != null) {
      instance.receivedBytes = map['receivedBytes'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "error": error,
      "receivedBytes": receivedBytes,
      "resultFilePath": resultFilePath,
      "state": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => state.toNativeValue(),
        EnumMethod.value => state.toValue(),
        EnumMethod.name => state.name(),
      },
      "totalBytes": totalBytes,
      "url": url.toString(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadProgress{error: $error, receivedBytes: $receivedBytes, resultFilePath: $resultFilePath, state: $state, totalBytes: $totalBytes, url: $url}';
  }
}
