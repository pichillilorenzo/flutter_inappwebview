// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
class ClientCertResponse {
  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction? action;

  ///Use [keyStoreType] instead.
  @Deprecated('Use keyStoreType instead')
  String? androidKeyStoreType;

  ///The certificate password.
  String? certificatePassword;

  ///The file path of the certificate to use.
  String certificatePath;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android native WebView
  String? keyStoreType;
  ClientCertResponse(
      {required this.certificatePath,
      this.certificatePassword = "",
      @Deprecated('Use keyStoreType instead')
      this.androidKeyStoreType = "PKCS12",
      this.keyStoreType = "PKCS12",
      this.action = ClientCertResponseAction.CANCEL}) {
    if (this.action == ClientCertResponseAction.PROCEED)
      assert(certificatePath.isNotEmpty);
    this.keyStoreType = this.keyStoreType ?? this.androidKeyStoreType;
    if (Util.isAndroid) assert(this.keyStoreType != null);
  }

  ///Gets a possible [ClientCertResponse] instance from a [Map] value.
  static ClientCertResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertResponse(
      certificatePath: map['certificatePath'],
    );
    instance.action = ClientCertResponseAction.fromNativeValue(map['action']);
    instance.androidKeyStoreType = map['keyStoreType'];
    instance.certificatePassword = map['certificatePassword'];
    instance.keyStoreType = map['keyStoreType'];
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "action": action?.toNativeValue(),
      "certificatePassword": certificatePassword,
      "certificatePath": certificatePath,
      "keyStoreType": keyStoreType,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertResponse{action: $action, certificatePassword: $certificatePassword, certificatePath: $certificatePath, keyStoreType: $keyStoreType}';
  }
}
