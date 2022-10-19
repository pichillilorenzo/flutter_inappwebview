// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the printer used by a [PrintJobController].
class Printer {
  ///The unique id of the printer.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  String? id;

  ///A description of the printer’s make and model.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  String? type;

  ///The PostScript language level recognized by the printer.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  int? languageLevel;

  ///The printer’s name.
  ///
  ///**Supported Platforms/Implementations**:
  ///- MacOS
  String? name;
  Printer({this.id, this.type, this.languageLevel, this.name});

  ///Gets a possible [Printer] instance from a [Map] value.
  static Printer? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = Printer(
      id: map['id'],
      type: map['type'],
      languageLevel: map['languageLevel'],
      name: map['name'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "languageLevel": languageLevel,
      "name": name,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Printer{id: $id, type: $type, languageLevel: $languageLevel, name: $name}';
  }
}
