import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'url_request_cache_policy.g.dart';

///Class that represents the constants used to specify interaction with the cached responses.
@ExchangeableEnum()
class URLRequestCachePolicy_ {
  // ignore: unused_field
  final int _value;
  const URLRequestCachePolicy_._internal(this._value);

  ///Use the caching logic defined in the protocol implementation, if any, for a particular URL load request.
  ///This is the default policy for URL load requests.
  static const USE_PROTOCOL_CACHE_POLICY =
      const URLRequestCachePolicy_._internal(0);

  ///The URL load should be loaded only from the originating source.
  ///This policy specifies that no existing cache data should be used to satisfy a URL load request.
  ///
  ///**NOTE**: Always use this policy if you are making HTTP or HTTPS byte-range requests.
  static const RELOAD_IGNORING_LOCAL_CACHE_DATA =
      const URLRequestCachePolicy_._internal(1);

  ///Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data.
  static const RETURN_CACHE_DATA_ELSE_LOAD =
      const URLRequestCachePolicy_._internal(2);

  ///Use existing cache data, regardless or age or expiration date, and fail if no cached data is available.
  ///
  ///If there is no existing data in the cache corresponding to a URL load request,
  ///no attempt is made to load the data from the originating source, and the load is considered to have failed.
  ///This constant specifies a behavior that is similar to an “offline” mode.
  static const RETURN_CACHE_DATA_DONT_LOAD =
      const URLRequestCachePolicy_._internal(3);

  ///Ignore local cache data, and instruct proxies and other intermediates to disregard their caches so far as the protocol allows.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA =
      const URLRequestCachePolicy_._internal(4);

  ///Use cache data if the origin source can validate it; otherwise, load from the origin.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_REVALIDATING_CACHE_DATA =
      const URLRequestCachePolicy_._internal(5);
}

///An iOS-specific Class that represents the constants used to specify interaction with the cached responses.
///Use [URLRequestCachePolicy] instead.
@Deprecated("Use URLRequestCachePolicy instead")
@ExchangeableEnum()
class IOSURLRequestCachePolicy_ {
  // ignore: unused_field
  final int _value;
  const IOSURLRequestCachePolicy_._internal(this._value);

  ///Use the caching logic defined in the protocol implementation, if any, for a particular URL load request.
  ///This is the default policy for URL load requests.
  static const USE_PROTOCOL_CACHE_POLICY =
      const IOSURLRequestCachePolicy_._internal(0);

  ///The URL load should be loaded only from the originating source.
  ///This policy specifies that no existing cache data should be used to satisfy a URL load request.
  ///
  ///**NOTE**: Always use this policy if you are making HTTP or HTTPS byte-range requests.
  static const RELOAD_IGNORING_LOCAL_CACHE_DATA =
      const IOSURLRequestCachePolicy_._internal(1);

  ///Use existing cache data, regardless or age or expiration date, loading from originating source only if there is no cached data.
  static const RETURN_CACHE_DATA_ELSE_LOAD =
      const IOSURLRequestCachePolicy_._internal(2);

  ///Use existing cache data, regardless or age or expiration date, and fail if no cached data is available.
  ///
  ///If there is no existing data in the cache corresponding to a URL load request,
  ///no attempt is made to load the data from the originating source, and the load is considered to have failed.
  ///This constant specifies a behavior that is similar to an “offline” mode.
  static const RETURN_CACHE_DATA_DONT_LOAD =
      const IOSURLRequestCachePolicy_._internal(3);

  ///Ignore local cache data, and instruct proxies and other intermediates to disregard their caches so far as the protocol allows.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_IGNORING_LOCAL_AND_REMOTE_CACHE_DATA =
      const IOSURLRequestCachePolicy_._internal(4);

  ///Use cache data if the origin source can validate it; otherwise, load from the origin.
  ///
  ///**NOTE**: Versions earlier than macOS 15, iOS 13, watchOS 6, and tvOS 13 don’t implement this constant.
  static const RELOAD_REVALIDATING_CACHE_DATA =
      const IOSURLRequestCachePolicy_._internal(5);
}
