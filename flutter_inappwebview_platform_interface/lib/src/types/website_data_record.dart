import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'website_data_type.dart';
import 'enum_method.dart';

part 'website_data_record.g.dart';

///Class that represents website data, grouped by domain name using the public suffix list.
@ExchangeableObject()
class WebsiteDataRecord_ {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<WebsiteDataType_>? dataTypes;

  WebsiteDataRecord_({this.displayName, this.dataTypes});
}

///Class that represents website data, grouped by domain name using the public suffix list.
///
///**NOTE**: available on iOS 9.0+.
///
///Use [WebsiteDataRecord] instead.
@Deprecated("Use WebsiteDataRecord instead")
@ExchangeableObject()
class IOSWKWebsiteDataRecord_ {
  ///The display name for the data record. This is usually the domain name.
  String? displayName;

  ///The various types of website data that exist for this data record.
  Set<IOSWKWebsiteDataType_>? dataTypes;

  IOSWKWebsiteDataRecord_({this.displayName, this.dataTypes});
}
