import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'web_resource_context.g.dart';

///Constants that describe the web resource request contexts.
@ExchangeableEnum()
class WebResourceContext_ {
  // ignore: unused_field
  final int _value;
  const WebResourceContext_._internal(this._value);

  ///All resources.
  static const ALL = WebResourceContext_._internal(0);

  ///Document resource.
  static const DOCUMENT = WebResourceContext_._internal(1);

  ///CSS resource.
  static const STYLESHEET = WebResourceContext_._internal(2);

  ///Image resource.
  static const IMAGE = WebResourceContext_._internal(3);

  ///Media resource.
  static const MEDIA = WebResourceContext_._internal(4);

  ///Font resource.
  static const FONT = WebResourceContext_._internal(5);

  ///Script resource.
  static const SCRIPT = WebResourceContext_._internal(6);

  ///XML HTTP request resource.
  static const XML_HTTP_REQUEST = WebResourceContext_._internal(7);

  ///Fetch API resource.
  static const FETCH = WebResourceContext_._internal(8);

  ///TextTrack resource.
  static const TEXT_TRACK = WebResourceContext_._internal(9);

  ///EventSource resource.
  static const EVENT_SOURCE = WebResourceContext_._internal(10);

  ///WebSocket resource.
  static const WEBSOCKET = WebResourceContext_._internal(11);

  ///Web App Manifest resource.
  static const MANIFEST = WebResourceContext_._internal(12);

  ///Signed HTTP Exchange resource.
  static const SIGNED_EXCHANGE = WebResourceContext_._internal(13);

  ///Ping request.
  static const PING = WebResourceContext_._internal(14);

  ///CSP Violation Report resource.
  static const CSP_VIOLATION_REPORT = WebResourceContext_._internal(15);

  ///Other resource.
  static const OTHER = WebResourceContext_._internal(16);
}
