// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_file_security_check_starting_request.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the request used by the [PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting] event.
class SaveFileSecurityCheckStartingRequest {
  ///Whether to cancel the save operation.
  bool? cancelSave;

  ///The document origin URI of the file save operation.
  WebUri? documentOriginUri;

  ///The file extension to be saved.
  String? fileExtension;

  ///The full file path of the file to be saved.
  String? filePath;

  ///Whether to suppress the default policy check.
  bool? suppressDefaultPolicy;
  SaveFileSecurityCheckStartingRequest({
    this.cancelSave,
    this.documentOriginUri,
    this.fileExtension,
    this.filePath,
    this.suppressDefaultPolicy,
  });

  ///Gets a possible [SaveFileSecurityCheckStartingRequest] instance from a [Map] value.
  static SaveFileSecurityCheckStartingRequest? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = SaveFileSecurityCheckStartingRequest(
      cancelSave: map['cancelSave'],
      documentOriginUri: map['documentOriginUri'] != null
          ? WebUri(map['documentOriginUri'])
          : null,
      fileExtension: map['fileExtension'],
      filePath: map['filePath'],
      suppressDefaultPolicy: map['suppressDefaultPolicy'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "cancelSave": cancelSave,
      "documentOriginUri": documentOriginUri?.toString(),
      "fileExtension": fileExtension,
      "filePath": filePath,
      "suppressDefaultPolicy": suppressDefaultPolicy,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'SaveFileSecurityCheckStartingRequest{cancelSave: $cancelSave, documentOriginUri: $documentOriginUri, fileExtension: $fileExtension, filePath: $filePath, suppressDefaultPolicy: $suppressDefaultPolicy}';
  }
}
