import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'save_as_kind.dart';
import 'enum_method.dart';

part 'save_as_ui_showing_request.g.dart';

///Class that represents the request used by the [PlatformWebViewCreationParams.onSaveAsUIShowing] event.
@ExchangeableObject()
class SaveAsUIShowingRequest_ {
  ///The MIME type of content to be saved.
  String? contentMimeType;

  ///Whether to cancel the Save As action.
  bool? cancel;

  ///Whether to suppress the default dialog.
  bool? suppressDefaultDialog;

  ///The suggested save file path.
  String? saveAsFilePath;

  ///Whether the save operation may replace an existing file.
  bool? allowReplace;

  ///The save-as kind for the operation.
  SaveAsKind_? kind;

  SaveAsUIShowingRequest_({
    this.contentMimeType,
    this.cancel,
    this.suppressDefaultDialog,
    this.saveAsFilePath,
    this.allowReplace,
    this.kind,
  });
}
