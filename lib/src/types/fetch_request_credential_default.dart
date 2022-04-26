import 'fetch_request.dart';
import 'fetch_request_credential.dart';

///Class that represents the default credentials used by an [FetchRequest].
class FetchRequestCredentialDefault extends FetchRequestCredential {
  ///The value of the credentials.
  String? value;

  FetchRequestCredentialDefault({type, this.value}) : super(type: type);

  ///Gets a possible [FetchRequestCredentialDefault] instance from a [Map] value.
  static FetchRequestCredentialDefault? fromMap(
      Map<String, dynamic>? credentialsMap) {
    if (credentialsMap == null) {
      return null;
    }
    return FetchRequestCredentialDefault(
        type: credentialsMap["type"], value: credentialsMap["value"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "value": value,
    };
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