import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'physical_key_status.g.dart';

///Contains the information packed into the LPARAM sent to a Win32 key event.
@ExchangeableObject()
class PhysicalKeyStatus_ {
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

  @ExchangeableObjectConstructor()
  PhysicalKeyStatus_({
    required this.isExtendedKey,
    required this.isKeyReleased,
    required this.isMenuKeyDown,
    required this.repeatCount,
    required this.scanCode,
    required this.wasKeyDown,
  });
}
