// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_data_record.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents website data, grouped by domain name using the public suffix list.
class WebsiteDataRecord {
  ///The various types of website data that exist for this data record.
  Set<WebsiteDataType>? dataTypes;

  ///The display name for the data record. This is usually the domain name.
  String? displayName;
  WebsiteDataRecord({this.dataTypes, this.displayName});

  ///Gets a possible [WebsiteDataRecord] instance from a [Map] value.
  static WebsiteDataRecord? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebsiteDataRecord(
      dataTypes: map['dataTypes'] != null
          ? Set<WebsiteDataType>.from(
              map['dataTypes'].map(
                (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue => WebsiteDataType.fromNativeValue(e),
                  EnumMethod.value => WebsiteDataType.fromValue(e),
                  EnumMethod.name => WebsiteDataType.byName(e),
                }!,
              ),
            )
          : null,
      displayName: map['displayName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "dataTypes": dataTypes
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "displayName": displayName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebsiteDataRecord{dataTypes: $dataTypes, displayName: $displayName}';
  }
}

///Class that represents website data, grouped by domain name using the public suffix list.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataRecord] instead.
@Deprecated('Use WebsiteDataRecord instead')
class IOSWKWebsiteDataRecord {
  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType>? dataTypes;

  ///The display name for the data record. This is usually the domain name.
  String? displayName;
  IOSWKWebsiteDataRecord({this.dataTypes, this.displayName});

  ///Gets a possible [IOSWKWebsiteDataRecord] instance from a [Map] value.
  static IOSWKWebsiteDataRecord? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = IOSWKWebsiteDataRecord(
      dataTypes: map['dataTypes'] != null
          ? Set<IOSWKWebsiteDataType>.from(
              map['dataTypes'].map(
                (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
                  EnumMethod.nativeValue =>
                    IOSWKWebsiteDataType.fromNativeValue(e),
                  EnumMethod.value => IOSWKWebsiteDataType.fromValue(e),
                  EnumMethod.name => IOSWKWebsiteDataType.byName(e),
                }!,
              ),
            )
          : null,
      displayName: map['displayName'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "dataTypes": dataTypes
          ?.map(
            (e) => switch (enumMethod ?? EnumMethod.nativeValue) {
              EnumMethod.nativeValue => e.toNativeValue(),
              EnumMethod.value => e.toValue(),
              EnumMethod.name => e.name(),
            },
          )
          .toList(),
      "displayName": displayName,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'IOSWKWebsiteDataRecord{dataTypes: $dataTypes, displayName: $displayName}';
  }
}
