// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accelerator_key_pressed_detail.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents details of the [PlatformWebViewCreationParams.onAcceleratorKeyPressed] event.
class AcceleratorKeyPressedDetail {
  int? keyEventKind;
  PhysicalKeyStatus? physicalKeyStatus;
  int? virtualKey;
  AcceleratorKeyPressedDetail(
      {this.keyEventKind, this.physicalKeyStatus, this.virtualKey});

  ///Gets a possible [AcceleratorKeyPressedDetail] instance from a [Map] value.
  static AcceleratorKeyPressedDetail? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = AcceleratorKeyPressedDetail(
      keyEventKind: map['keyEventKind'],
      physicalKeyStatus: PhysicalKeyStatus.fromMap(
          map['physicalKeyStatus']?.cast<String, dynamic>(),
          enumMethod: enumMethod),
      virtualKey: map['virtualKey'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "keyEventKind": keyEventKind,
      "physicalKeyStatus": physicalKeyStatus?.toMap(enumMethod: enumMethod),
      "virtualKey": virtualKey,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AcceleratorKeyPressedDetail{keyEventKind: $keyEventKind, physicalKeyStatus: $physicalKeyStatus, virtualKey: $virtualKey}';
  }
}
