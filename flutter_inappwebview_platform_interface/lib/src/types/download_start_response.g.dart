// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a download response of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
class DownloadStartResponse {
  ///Action to take for the download request.
  ///
  ///If canceled, the download save dialog is not displayed regardless of the [handled] property.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  DownloadStartResponseAction? action;

  ///Set this flag to `true` to hide the default download dialog for this download.
  ///
  ///The download will progress as normal if it is not canceled, there will just be no default UI shown.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  bool handled;

  ///The path to the file.
  ///
  ///If setting the path, the host should ensure that it is an absolute path,
  ///including the file name, and that the path does not point to an existing file.
  ///If the path points to an existing file, the file will be overwritten.
  ///If the directory does not exist, it is created.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  String? resultFilePath;
  DownloadStartResponse(
      {this.action, required this.handled, this.resultFilePath});

  ///Gets a possible [DownloadStartResponse] instance from a [Map] value.
  static DownloadStartResponse? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = DownloadStartResponse(
      action: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          DownloadStartResponseAction.fromNativeValue(map['action']),
        EnumMethod.value =>
          DownloadStartResponseAction.fromValue(map['action']),
        EnumMethod.name => DownloadStartResponseAction.byName(map['action'])
      },
      handled: map['handled'],
      resultFilePath: map['resultFilePath'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name()
      },
      "handled": handled,
      "resultFilePath": resultFilePath,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadStartResponse{action: $action, handled: $handled, resultFilePath: $resultFilePath}';
  }
}
