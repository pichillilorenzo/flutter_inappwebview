import 'fetch_request_credential_default.dart';
import 'fetch_request_federated_credential.dart';
import 'fetch_request_password_credential.dart';

///Class that is an interface for [FetchRequestCredentialDefault], [FetchRequestFederatedCredential] and [FetchRequestPasswordCredential] classes.
class FetchRequestCredential {
  ///Type of credentials.
  String? type;

  FetchRequestCredential({this.type});

  ///Gets a possible [FetchRequestCredential] instance from a [Map] value.
  static FetchRequestCredential? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return FetchRequestCredential(type: map["type"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {"type": type};
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