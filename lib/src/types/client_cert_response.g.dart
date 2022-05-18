// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_cert_response.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the response used by the [WebView.onReceivedClientCertRequest] event.
class ClientCertResponse {
  ///The file path of the certificate to use.
  String certificatePath;

  ///The certificate password.
  String? certificatePassword;

  ///Use [keyStoreType] instead.
  @Deprecated('Use keyStoreType instead')
  String? androidKeyStoreType;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  String? keyStoreType;

  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction? action;
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
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      assert(this.keyStoreType != null);
  }

  ///Gets a possible [ClientCertResponse] instance from a [Map] value.
  static ClientCertResponse? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertResponse(
      certificatePath: map['certificatePath'],
    );
    instance.certificatePassword = map['certificatePassword'];
    instance.androidKeyStoreType = map['keyStoreType'];
    instance.keyStoreType = map['keyStoreType'];
    instance.action = ClientCertResponseAction.fromNativeValue(map['action']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "certificatePath": certificatePath,
      "certificatePassword": certificatePassword,
      "keyStoreType": keyStoreType,
      "action": action?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertResponse{certificatePath: $certificatePath, certificatePassword: $certificatePassword, keyStoreType: $keyStoreType, action: $action}';
  }
}
