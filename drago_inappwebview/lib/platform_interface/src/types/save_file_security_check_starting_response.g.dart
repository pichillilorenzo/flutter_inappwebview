// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_file_security_check_starting_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting] event.
class SaveFileSecurityCheckStartingResponse {
  ///Whether to cancel the save operation.
  bool? cancelSave;

  ///Whether to suppress the default policy check.
  bool? suppressDefaultPolicy;
  SaveFileSecurityCheckStartingResponse({
    this.cancelSave,
    this.suppressDefaultPolicy,
  });

  ///Gets a possible [SaveFileSecurityCheckStartingResponse] instance from a [Map] value.
  static SaveFileSecurityCheckStartingResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = SaveFileSecurityCheckStartingResponse(
      cancelSave: map['cancelSave'],
      suppressDefaultPolicy: map['suppressDefaultPolicy'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "cancelSave": cancelSave,
      "suppressDefaultPolicy": suppressDefaultPolicy,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SaveFileSecurityCheckStartingResponse{cancelSave: $cancelSave, suppressDefaultPolicy: $suppressDefaultPolicy}';
  }
}
