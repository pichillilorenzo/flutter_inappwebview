import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'enum_method.dart';

part 'save_file_security_check_starting_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onSaveFileSecurityCheckStarting] event.
@ExchangeableObject()
class SaveFileSecurityCheckStartingResponse_ {
  ///Whether to cancel the save operation.
  bool? cancelSave;

  ///Whether to suppress the default policy check.
  bool? suppressDefaultPolicy;

  SaveFileSecurityCheckStartingResponse_({
    this.cancelSave,
    this.suppressDefaultPolicy,
  });
}
