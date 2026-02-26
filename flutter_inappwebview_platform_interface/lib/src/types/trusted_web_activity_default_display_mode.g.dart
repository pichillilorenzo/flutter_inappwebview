// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_web_activity_default_display_mode.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the default display mode of a Trusted Web Activity.
///The system UI (status bar, navigation bar) is shown, and the browser toolbar is hidden while the user is on a verified origin.
class TrustedWebActivityDefaultDisplayMode
    implements TrustedWebActivityDisplayMode {
  static final String _type = "DEFAULT_MODE";
  TrustedWebActivityDefaultDisplayMode();
  @ExchangeableObjectMethod(toMapMergeWith: true)
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"type": _type};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {..._toMapMergeWith(enumMethod: enumMethod)};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'TrustedWebActivityDefaultDisplayMode{}';
  }
}
