// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_exited_detail.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information for the [PlatformWebViewEnvironment.onBrowserProcessExited] event.
class BrowserProcessExitedDetail {
  ///The kind of browser process exit that has occurred.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  BrowserProcessExitKind kind;

  ///The process ID of the browser process that has exited.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  int? processId;
  BrowserProcessExitedDetail({required this.kind, this.processId});

  ///Gets a possible [BrowserProcessExitedDetail] instance from a [Map] value.
  static BrowserProcessExitedDetail? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = BrowserProcessExitedDetail(
      kind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => BrowserProcessExitKind.fromNativeValue(
          map['kind'],
        ),
        EnumMethod.value => BrowserProcessExitKind.fromValue(map['kind']),
        EnumMethod.name => BrowserProcessExitKind.byName(map['kind']),
      }!,
      processId: map['processId'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "kind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => kind.toNativeValue(),
        EnumMethod.value => kind.toValue(),
        EnumMethod.name => kind.name(),
      },
      "processId": processId,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'BrowserProcessExitedDetail{kind: $kind, processId: $processId}';
  }
}
