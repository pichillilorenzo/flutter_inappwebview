// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_key_status.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Contains the information packed into the LPARAM sent to a Win32 key event.
class PhysicalKeyStatus {
  ///Indicates that the key is an extended key.
  bool isExtendedKey;

  ///Indicates that the key was released.
  bool isKeyReleased;

  ///Indicates that a menu key is held down (context code).
  bool isMenuKeyDown;

  ///Specifies the repeat count for the current message.
  int repeatCount;

  ///Specifies the scan code.
  int scanCode;

  ///Indicates that the key was held down.
  bool wasKeyDown;
  PhysicalKeyStatus(
      {required this.isExtendedKey,
      required this.isKeyReleased,
      required this.isMenuKeyDown,
      required this.repeatCount,
      required this.scanCode,
      required this.wasKeyDown});

  ///Gets a possible [PhysicalKeyStatus] instance from a [Map] value.
  static PhysicalKeyStatus? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PhysicalKeyStatus(
      isExtendedKey: map['isExtendedKey'],
      isKeyReleased: map['isKeyReleased'],
      isMenuKeyDown: map['isMenuKeyDown'],
      repeatCount: map['repeatCount'],
      scanCode: map['scanCode'],
      wasKeyDown: map['wasKeyDown'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "isExtendedKey": isExtendedKey,
      "isKeyReleased": isKeyReleased,
      "isMenuKeyDown": isMenuKeyDown,
      "repeatCount": repeatCount,
      "scanCode": scanCode,
      "wasKeyDown": wasKeyDown,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PhysicalKeyStatus{isExtendedKey: $isExtendedKey, isKeyReleased: $isKeyReleased, isMenuKeyDown: $isMenuKeyDown, repeatCount: $repeatCount, scanCode: $scanCode, wasKeyDown: $wasKeyDown}';
  }
}
