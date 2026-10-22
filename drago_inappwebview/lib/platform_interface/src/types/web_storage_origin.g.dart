// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_storage_origin.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that encapsulates information about the amount of storage currently used by an origin for the JavaScript storage APIs.
///An origin comprises the host, scheme and port of a URI. See [PlatformWebStorageManager] for details.
class WebStorageOrigin {
  ///The string representation of this origin.
  String? origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int? quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int? usage;
  WebStorageOrigin({this.origin, this.quota, this.usage});

  ///Gets a possible [WebStorageOrigin] instance from a [Map] value.
  static WebStorageOrigin? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebStorageOrigin(
      origin: map['origin'],
      quota: map['quota'],
      usage: map['usage'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"origin": origin, "quota": quota, "usage": usage};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebStorageOrigin{origin: $origin, quota: $quota, usage: $usage}';
  }
}

///Class that encapsulates information about the amount of storage currently used by an origin for the JavaScript storage APIs.
///An origin comprises the host, scheme and port of a URI. See `AndroidWebStorageManager` for details.
///Use [WebStorageOrigin] instead.
@Deprecated('Use WebStorageOrigin instead')
class AndroidWebStorageOrigin {
  ///The string representation of this origin.
  String? origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int? quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int? usage;
  AndroidWebStorageOrigin({this.origin, this.quota, this.usage});

  ///Gets a possible [AndroidWebStorageOrigin] instance from a [Map] value.
  static AndroidWebStorageOrigin? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = AndroidWebStorageOrigin(
      origin: map['origin'],
      quota: map['quota'],
      usage: map['usage'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"origin": origin, "quota": quota, "usage": usage};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidWebStorageOrigin{origin: $origin, quota: $quota, usage: $usage}';
  }
}
