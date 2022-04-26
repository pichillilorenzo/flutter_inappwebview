import '../web_storage/web_storage_manager.dart';
import '../web_storage/android/web_storage_manager.dart';

///Class that encapsulates information about the amount of storage currently used by an origin for the JavaScript storage APIs.
///An origin comprises the host, scheme and port of a URI. See [WebStorageManager] for details.
class WebStorageOrigin {
  ///The string representation of this origin.
  String? origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int? quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int? usage;

  WebStorageOrigin({this.origin, this.quota, this.usage});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"origin": origin, "quota": quota, "usage": usage};
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

///Class that encapsulates information about the amount of storage currently used by an origin for the JavaScript storage APIs.
///An origin comprises the host, scheme and port of a URI. See [AndroidWebStorageManager] for details.
///Use [WebStorageOrigin] instead.
@Deprecated("Use WebStorageOrigin instead")
class AndroidWebStorageOrigin {
  ///The string representation of this origin.
  String? origin;

  ///The quota for this origin, for the Web SQL Database API, in bytes.
  int? quota;

  ///The total amount of storage currently being used by this origin, for all JavaScript storage APIs, in bytes.
  int? usage;

  AndroidWebStorageOrigin({this.origin, this.quota, this.usage});

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"origin": origin, "quota": quota, "usage": usage};
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