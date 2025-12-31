import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_storage/platform_web_storage.dart';

part 'web_storage_type.g.dart';

///Class that represents the type of Web Storage: `localStorage` or `sessionStorage`.
///Used by the [PlatformStorage] class.
@ExchangeableEnum()
class WebStorageType_ {
  // ignore: unused_field
  final String _value;
  const WebStorageType_._internal(this._value);

  ///`window.localStorage`: same as [SESSION_STORAGE], but persists even when the browser is closed and reopened.
  static const LOCAL_STORAGE = const WebStorageType_._internal("localStorage");

  ///`window.sessionStorage`: maintains a separate storage area for each given origin that's available for the duration
  ///of the page session (as long as the browser is open, including page reloads and restores).
  static const SESSION_STORAGE = const WebStorageType_._internal(
    "sessionStorage",
  );
}
