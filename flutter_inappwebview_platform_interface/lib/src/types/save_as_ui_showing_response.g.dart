// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_as_ui_showing_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onSaveAsUIShowing] event.
class SaveAsUIShowingResponse {
  ///Whether the save operation may replace an existing file.
  bool? allowReplace;

  ///Whether to cancel the Save As action.
  bool? cancel;

  ///The save-as kind for the operation.
  SaveAsKind? kind;

  ///The save file path to use.
  String? saveAsFilePath;

  ///Whether to suppress the default dialog.
  bool? suppressDefaultDialog;
  SaveAsUIShowingResponse({
    this.allowReplace,
    this.cancel,
    this.kind,
    this.saveAsFilePath,
    this.suppressDefaultDialog,
  });

  ///Gets a possible [SaveAsUIShowingResponse] instance from a [Map] value.
  static SaveAsUIShowingResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = SaveAsUIShowingResponse(
      allowReplace: map['allowReplace'],
      cancel: map['cancel'],
      kind: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => SaveAsKind.fromNativeValue(map['kind']),
        EnumMethod.value => SaveAsKind.fromValue(map['kind']),
        EnumMethod.name => SaveAsKind.byName(map['kind']),
      },
      saveAsFilePath: map['saveAsFilePath'],
      suppressDefaultDialog: map['suppressDefaultDialog'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "allowReplace": allowReplace,
      "cancel": cancel,
      "kind": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => kind?.toNativeValue(),
        EnumMethod.value => kind?.toValue(),
        EnumMethod.name => kind?.name(),
      },
      "saveAsFilePath": saveAsFilePath,
      "suppressDefaultDialog": suppressDefaultDialog,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SaveAsUIShowingResponse{allowReplace: $allowReplace, cancel: $cancel, kind: $kind, saveAsFilePath: $saveAsFilePath, suppressDefaultDialog: $suppressDefaultDialog}';
  }
}
