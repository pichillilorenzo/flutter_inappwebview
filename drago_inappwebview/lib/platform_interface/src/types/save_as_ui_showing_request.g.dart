// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_as_ui_showing_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onSaveAsUIShowing] event.
class SaveAsUIShowingRequest {
  ///Whether the save operation may replace an existing file.
  bool? allowReplace;

  ///Whether to cancel the Save As action.
  bool? cancel;

  ///The MIME type of content to be saved.
  String? contentMimeType;

  ///The save-as kind for the operation.
  SaveAsKind? kind;

  ///The suggested save file path.
  String? saveAsFilePath;

  ///Whether to suppress the default dialog.
  bool? suppressDefaultDialog;
  SaveAsUIShowingRequest({
    this.allowReplace,
    this.cancel,
    this.contentMimeType,
    this.kind,
    this.saveAsFilePath,
    this.suppressDefaultDialog,
  });

  ///Gets a possible [SaveAsUIShowingRequest] instance from a [Map] value.
  static SaveAsUIShowingRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = SaveAsUIShowingRequest(
      allowReplace: map['allowReplace'],
      cancel: map['cancel'],
      contentMimeType: map['contentMimeType'],
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
      "contentMimeType": contentMimeType,
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
    return 'SaveAsUIShowingRequest{allowReplace: $allowReplace, cancel: $cancel, contentMimeType: $contentMimeType, kind: $kind, saveAsFilePath: $saveAsFilePath, suppressDefaultDialog: $suppressDefaultDialog}';
  }
}
