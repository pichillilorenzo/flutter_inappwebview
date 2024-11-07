import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../types/enum_method.dart';

part 'web_storage_item.g.dart';

///Class that represents a single web storage item of the JavaScript `window.sessionStorage` and `window.localStorage` objects.
@ExchangeableObject()
class WebStorageItem_ {
  ///Item key.
  String? key;

  ///Item value.
  dynamic value;

  WebStorageItem_({this.key, this.value});
}
