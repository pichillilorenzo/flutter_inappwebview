// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_info.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information for a process in the [PlatformWebViewEnvironment].
class BrowserProcessInfo {
  ///A list of associated [FrameInfo]s which are actively running
  ///(showing or hiding UI elements) in the renderer process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2 1.0.2210.55+
  List<FrameInfo>? frameInfos;

  ///The kind of the process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  BrowserProcessKind kind;

  ///The process id of the process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  int? processId;
  BrowserProcessInfo({this.frameInfos, required this.kind, this.processId});

  ///Gets a possible [BrowserProcessInfo] instance from a [Map] value.
  static BrowserProcessInfo? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = BrowserProcessInfo(
      frameInfos: map['frameInfos'] != null
          ? List<FrameInfo>.from(
              map['frameInfos'].map(
                (e) => FrameInfo.fromMap(
                  e?.cast<String, dynamic>(),
                  enumMethod: enumMethod,
                )!,
              ),
            )
          : null,
      kind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => BrowserProcessKind.fromNativeValue(
          map['kind'],
        ),
        EnumMethod.value => BrowserProcessKind.fromValue(map['kind']),
        EnumMethod.name => BrowserProcessKind.byName(map['kind']),
      }!,
      processId: map['processId'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "frameInfos": frameInfos
          ?.map((e) => e.toMap(enumMethod: enumMethod))
          .toList(),
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
    return 'BrowserProcessInfo{frameInfos: $frameInfos, kind: $kind, processId: $processId}';
  }
}
