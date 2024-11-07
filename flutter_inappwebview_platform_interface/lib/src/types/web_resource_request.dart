import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import 'enum_method.dart';

part 'web_resource_request.g.dart';

///Class representing a resource request of the `WebView`.
@ExchangeableObject()
class WebResourceRequest_ {
  ///The URL for which the resource request was made.
  WebUri url;

  ///The headers associated with the request.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `null`.
  Map<String, String>? headers;

  ///The method associated with the request, for example `GET`.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always "GET".
  String? method;

  ///Gets whether a gesture (such as a click) was associated with the request.
  ///For security reasons in certain situations this method may return `false` even though
  ///the sequence of events which caused the request to be created was initiated by a user
  ///gesture.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? hasGesture;

  ///Whether the request was made in order to fetch the main frame's document.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `true`.
  bool? isForMainFrame;

  ///Whether the request was a result of a server-side redirect.
  ///
  ///**NOTE**: available on Android 21+. For Android < 21 it will be always `false`.
  bool? isRedirect;

  WebResourceRequest_(
      {required this.url,
      this.headers,
      this.method,
      this.hasGesture,
      this.isForMainFrame,
      this.isRedirect});
}
