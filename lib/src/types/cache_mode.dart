///Class used to override the way the cache is used.
class CacheMode {
  final int _value;

  const CacheMode._internal(this._value);

  ///Set of all values of [CacheMode].
  static final Set<CacheMode> values = [
    CacheMode.LOAD_DEFAULT,
    CacheMode.LOAD_CACHE_ELSE_NETWORK,
    CacheMode.LOAD_NO_CACHE,
    CacheMode.LOAD_CACHE_ONLY,
  ].toSet();

  ///Gets a possible [CacheMode] instance from an [int] value.
  static CacheMode? fromValue(int? value) {
    if (value != null) {
      try {
        return CacheMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "LOAD_CACHE_ELSE_NETWORK";
      case 2:
        return "LOAD_NO_CACHE";
      case 3:
        return "LOAD_CACHE_ONLY";
      case -1:
      default:
        return "LOAD_DEFAULT";
    }
  }

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = const CacheMode._internal(-1);

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = const CacheMode._internal(1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = const CacheMode._internal(2);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = const CacheMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///An Android-specific class used to override the way the cache is used.
///Use [CacheMode] instead.
@Deprecated("Use CacheMode instead")
class AndroidCacheMode {
  final int _value;

  const AndroidCacheMode._internal(this._value);

  ///Set of all values of [AndroidCacheMode].
  static final Set<AndroidCacheMode> values = [
    AndroidCacheMode.LOAD_DEFAULT,
    AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
    AndroidCacheMode.LOAD_NO_CACHE,
    AndroidCacheMode.LOAD_CACHE_ONLY,
  ].toSet();

  ///Gets a possible [AndroidCacheMode] instance from an [int] value.
  static AndroidCacheMode? fromValue(int? value) {
    if (value != null) {
      try {
        return AndroidCacheMode.values
            .firstWhere((element) => element.toValue() == value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets [int] value.
  int toValue() => _value;

  @override
  String toString() {
    switch (_value) {
      case 1:
        return "LOAD_CACHE_ELSE_NETWORK";
      case 2:
        return "LOAD_NO_CACHE";
      case 3:
        return "LOAD_CACHE_ONLY";
      case -1:
      default:
        return "LOAD_DEFAULT";
    }
  }

  ///Default cache usage mode. If the navigation type doesn't impose any specific behavior,
  ///use cached resources when they are available and not expired, otherwise load resources from the network.
  static const LOAD_DEFAULT = const AndroidCacheMode._internal(-1);

  ///Use cached resources when they are available, even if they have expired. Otherwise load resources from the network.
  static const LOAD_CACHE_ELSE_NETWORK = const AndroidCacheMode._internal(1);

  ///Don't use the cache, load from the network.
  static const LOAD_NO_CACHE = const AndroidCacheMode._internal(2);

  ///Don't use the network, load from the cache.
  static const LOAD_CACHE_ONLY = const AndroidCacheMode._internal(3);

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}