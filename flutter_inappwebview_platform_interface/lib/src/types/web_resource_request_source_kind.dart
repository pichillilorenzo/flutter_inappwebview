import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_resource_request_source_kind.g.dart';

///Constants that describe the source kinds for web resource requests.
@ExchangeableEnum()
class WebResourceRequestSourceKind_ {
  // ignore: unused_field
  final int _value;
  const WebResourceRequestSourceKind_._internal(this._value);

  ///No request source kind.
  static const NONE = WebResourceRequestSourceKind_._internal(0x0);

  ///Request originated from a document.
  static const DOCUMENT = WebResourceRequestSourceKind_._internal(0x1);

  ///Request originated from a shared worker.
  static const SHARED_WORKER = WebResourceRequestSourceKind_._internal(0x2);

  ///Request originated from a service worker.
  static const SERVICE_WORKER = WebResourceRequestSourceKind_._internal(0x4);

  ///All request source kinds.
  static const ALL = WebResourceRequestSourceKind_._internal(0xFFFFFFFF);
}
