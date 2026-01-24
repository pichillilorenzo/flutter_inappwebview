import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';

part 'save_file_security_check_starting_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting] event.
@ExchangeableObject()
class SaveFileSecurityCheckStartingRequest_ {
  ///The document origin URI of the file save operation.
  WebUri? documentOriginUri;

  ///The file extension to be saved.
  String? fileExtension;

  ///The full file path of the file to be saved.
  String? filePath;

  ///Whether to cancel the save operation.
  bool? cancelSave;

  ///Whether to suppress the default policy check.
  bool? suppressDefaultPolicy;

  SaveFileSecurityCheckStartingRequest_({
    this.documentOriginUri,
    this.fileExtension,
    this.filePath,
    this.cancelSave,
    this.suppressDefaultPolicy,
  });
}
