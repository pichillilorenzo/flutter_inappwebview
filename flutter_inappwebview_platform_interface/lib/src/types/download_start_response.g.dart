// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_start_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing a download response of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
class DownloadStartResponse {
  ///the user agent to be used for the download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  DownloadStartResponseAction? action;

  ///Set this flag to `true` to hide the default download dialog for this download.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows
  bool handled;
  DownloadStartResponse({this.action, required this.handled});

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
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'DownloadStartResponse{action: $action, handled: $handled}';
  }
}
