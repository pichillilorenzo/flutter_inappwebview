import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';
import 'physical_key_status.dart';

part 'accelerator_key_pressed_detail.g.dart';

///Class that represents details of the [PlatformWebViewCreationParams.onAcceleratorKeyPressed] event.
@ExchangeableObject()
class AcceleratorKeyPressedDetail_ {
  int? keyEventKind;
  PhysicalKeyStatus_? physicalKeyStatus;
  int? virtualKey;

  @ExchangeableObjectConstructor()
  AcceleratorKeyPressedDetail_(
      {this.keyEventKind, this.physicalKeyStatus, this.virtualKey});
}
