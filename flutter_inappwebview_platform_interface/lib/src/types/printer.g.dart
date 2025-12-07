// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class representing the printer used by a [PlatformPrintJobController].
class Printer {
  ///The unique id of the printer.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  String? id;

  ///The PostScript language level recognized by the printer.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  int? languageLevel;

  ///The printer’s name.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  String? name;

  ///A description of the printer’s make and model.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- macOS WKWebView
  String? type;
  Printer({this.id, this.languageLevel, this.name, this.type});

  ///Gets a possible [Printer] instance from a [Map] value.
  static Printer? fromMap(Map<String, dynamic>? map, {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = Printer(
      id: map['id'],
      languageLevel: map['languageLevel'],
      name: map['name'],
      type: map['type'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "id": id,
      "languageLevel": languageLevel,
      "name": name,
      "type": type,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'Printer{id: $id, languageLevel: $languageLevel, name: $name, type: $type}';
  }
}
