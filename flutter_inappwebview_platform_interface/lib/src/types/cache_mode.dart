import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'cache_mode.g.dart';

///Class used to override the way the cache is used.
@ExchangeableEnum()
class CacheMode_ {
  // ignore: unused_field
  final int _value;
  const CacheMode_._internal(this._value);

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = const CacheMode_._internal(-1);

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = const CacheMode_._internal(1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = const CacheMode_._internal(2);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = const CacheMode_._internal(3);
}

///An Android-specific class used to override the way the cache is used.
///Use [CacheMode] instead.
@Deprecated("Use CacheMode instead")
@ExchangeableEnum()
class AndroidCacheMode_ {
  // ignore: unused_field
  final int _value;
  const AndroidCacheMode_._internal(this._value);

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = const AndroidCacheMode_._internal(-1);

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = const AndroidCacheMode_._internal(1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = const AndroidCacheMode_._internal(2);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = const AndroidCacheMode_._internal(3);
}
