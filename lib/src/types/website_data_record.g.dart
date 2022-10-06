// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_data_record.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents website data, grouped by domain name using the public suffix list.
class WebsiteDataRecord {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<WebsiteDataType>? dataTypes;
  WebsiteDataRecord({this.displayName, this.dataTypes});

  ///Gets a possible [WebsiteDataRecord] instance from a [Map] value.
  static WebsiteDataRecord? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebsiteDataRecord(
      displayName: map['displayName'],
      dataTypes: map['dataTypes'] != null
          ? Set<WebsiteDataType>.from(
              map['dataTypes'].map((e) => WebsiteDataType.fromNativeValue(e)!))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "displayName": displayName,
      "dataTypes": dataTypes?.map((e) => e.toNativeValue()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebsiteDataRecord{displayName: $displayName, dataTypes: $dataTypes}';
  }
}

///Class that represents website data, grouped by domain name using the public suffix list.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataRecord] instead.
@Deprecated('Use WebsiteDataRecord instead')
class IOSWKWebsiteDataRecord {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType>? dataTypes;
  IOSWKWebsiteDataRecord({this.displayName, this.dataTypes});

  ///Gets a possible [IOSWKWebsiteDataRecord] instance from a [Map] value.
  static IOSWKWebsiteDataRecord? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKWebsiteDataRecord(
      displayName: map['displayName'],
      dataTypes: map['dataTypes'] != null
          ? Set<IOSWKWebsiteDataType>.from(map['dataTypes']
              .map((e) => IOSWKWebsiteDataType.fromNativeValue(e)!))
          : null,
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "displayName": displayName,
      "dataTypes": dataTypes?.map((e) => e.toNativeValue()).toList(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKWebsiteDataRecord{displayName: $displayName, dataTypes: $dataTypes}';
  }
}
