// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prewarming_token.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the Prewarming Token returned by [PlatformChromeSafariBrowser.prewarmConnections].
class PrewarmingToken {
  ///Prewarming Token id.
  final String id;
  PrewarmingToken({required this.id});

  ///Gets a possible [PrewarmingToken] instance from a [Map] value.
  static PrewarmingToken? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = PrewarmingToken(
      id: map['id'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "id": id,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'PrewarmingToken{id: $id}';
  }
}
