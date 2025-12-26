// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_process_infos_changed_detail.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///An object that contains information for the [PlatformWebViewEnvironment.onProcessInfosChanged] event.
class BrowserProcessInfosChangedDetail {
  ///The kind of the process.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  List<BrowserProcessInfo> infos;
  BrowserProcessInfosChangedDetail({this.infos = const []});

  ///Gets a possible [BrowserProcessInfosChangedDetail] instance from a [Map] value.
  static BrowserProcessInfosChangedDetail? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = BrowserProcessInfosChangedDetail();
    if (map['infos'] != null) {
      instance.infos = List<BrowserProcessInfo>.from(map['infos'].map((e) =>
          BrowserProcessInfo.fromMap(e?.cast<String, dynamic>(),
              enumMethod: enumMethod)!));
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "infos": infos.map((e) => e.toMap(enumMethod: enumMethod)).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'BrowserProcessInfosChangedDetail{infos: $infos}';
  }
}
