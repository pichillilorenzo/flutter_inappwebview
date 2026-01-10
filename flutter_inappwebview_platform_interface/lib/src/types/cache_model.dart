import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'cache_model.g.dart';

///Cache model for WebKitWebContext.
///
///Determines how caching is handled for web content.
@ExchangeableEnum()
class CacheModel_ {
  // ignore: unused_field
  final int _value;
  const CacheModel_._internal(this._value);

  ///Disable the cache completely, which is useful for ephemeral applications
  ///or applications without a persistent data storage.
  ///Using this cache model can have important security implications for your application.
  ///All pages are loaded from the server without caching.
  @EnumSupportedPlatforms(
    platforms: [
      EnumLinuxPlatform(
        apiName: 'WEBKIT_CACHE_MODEL_DOCUMENT_VIEWER',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html',
        value: 0,
      ),
    ],
  )
  static const DOCUMENT_VIEWER = CacheModel_._internal(0);

  ///Improves document load speed substantially by caching a very large number of resources
  ///and previously visited content. This mode is optimal for web browser applications.
  @EnumSupportedPlatforms(
    platforms: [
      EnumLinuxPlatform(
        apiName: 'WEBKIT_CACHE_MODEL_WEB_BROWSER',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html',
        value: 1,
      ),
    ],
  )
  static const WEB_BROWSER = CacheModel_._internal(1);

  ///A cache model optimized for viewing a series of local files, such as ebooks,
  ///without browsing a variety of online content.
  @EnumSupportedPlatforms(
    platforms: [
      EnumLinuxPlatform(
        apiName: 'WEBKIT_CACHE_MODEL_DOCUMENT_BROWSER',
        apiUrl:
            'https://wpewebkit.org/reference/stable/wpe-webkit-2.0/enum.CacheModel.html',
        value: 2,
      ),
    ],
  )
  static const DOCUMENT_BROWSER = CacheModel_._internal(2);
}
