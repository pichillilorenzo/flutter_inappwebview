// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_menu_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents available settings used by [ContextMenu].
class ContextMenuSettings {
  ///Whether all the default system context menu items should be hidden or not. The default value is `false`.
  bool hideDefaultSystemContextMenuItems;
  ContextMenuSettings({this.hideDefaultSystemContextMenuItems = false});

  ///Gets a possible [ContextMenuSettings] instance from a [Map] value.
  static ContextMenuSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ContextMenuSettings();
    instance.hideDefaultSystemContextMenuItems =
        map['hideDefaultSystemContextMenuItems'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "hideDefaultSystemContextMenuItems": hideDefaultSystemContextMenuItems,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of ContextMenuSettings.
  ContextMenuSettings copy() {
    return ContextMenuSettings.fromMap(toMap()) ?? ContextMenuSettings();
  }

  @override
  String toString() {
    return 'ContextMenuSettings{hideDefaultSystemContextMenuItems: $hideDefaultSystemContextMenuItems}';
  }
}
