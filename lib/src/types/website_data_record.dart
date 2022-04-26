import 'website_data_type.dart';

///Class that represents website data, grouped by domain name using the public suffix list.
class WebsiteDataRecord {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<WebsiteDataType>? dataTypes;

  WebsiteDataRecord({this.displayName, this.dataTypes});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    List<String> dataTypesString = [];
    if (dataTypes != null) {
      for (var dataType in dataTypes!) {
        dataTypesString.add(dataType.toValue());
      }
    }

    return {"displayName": displayName, "dataTypes": dataTypesString};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

///Class that represents website data, grouped by domain name using the public suffix list.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataRecord] instead.
@Deprecated("Use WebsiteDataRecord instead")
class IOSWKWebsiteDataRecord {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType>? dataTypes;

  IOSWKWebsiteDataRecord({this.displayName, this.dataTypes});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    List<String> dataTypesString = [];
    if (dataTypes != null) {
      for (var dataType in dataTypes!) {
        dataTypesString.add(dataType.toValue());
      }
    }

    return {"displayName": displayName, "dataTypes": dataTypesString};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}