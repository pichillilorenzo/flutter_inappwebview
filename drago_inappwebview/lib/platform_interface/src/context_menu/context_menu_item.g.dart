// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_menu_item.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represent an item of the [ContextMenu].
class ContextMenuItem {
  ///Menu item action that will be called when an user clicks on it.
  dynamic Function()? action;

  ///Use [id] instead.
  @Deprecated('Use id instead')
  int? androidId;

  ///Menu item ID. It cannot be `null` and it can be a [String] or an [int].
  ///
  ///**NOTE for Android**: it must be an [int] value.
  dynamic id;

  ///Use [id] instead.
  @Deprecated('Use id instead')
  String? iosId;

  ///Menu item title.
  String title;
  ContextMenuItem({
    this.id,
    @Deprecated("Use id instead") this.androidId,
    @Deprecated("Use id instead") this.iosId,
    required this.title,
    this.action,
  }) {
    if (Util.isAndroid) {
      id = id ?? androidId;
      assert(id is int);
    } else if (Util.isIOS) {
      id = id ?? iosId;
    }
    assert(id != null && (id is int || id is String));
  }

  ///Gets a possible [ContextMenuItem] instance from a [Map] value.
  static ContextMenuItem? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ContextMenuItem(
      androidId: map['id'],
      id: map['id'],
      iosId: map['id'],
      title: map['title'],
    );
    return instance;
  }

  @ExchangeableObjectMethod(toMapMergeWith: true)
  Map<String, dynamic> _toMapMergeWith({EnumMethod? enumMethod}) {
    return {"androidId": androidId, "iosId": iosId};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "id": id,
      "title": title,
      ..._toMapMergeWith(enumMethod: enumMethod),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ContextMenuItem{id: $id, title: $title}';
  }
}
