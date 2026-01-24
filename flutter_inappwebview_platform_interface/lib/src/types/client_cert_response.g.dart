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
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  String? certificatePassword;

  ///The file path of the certificate to use.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  String certificatePath;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  String? keyStoreType;

  ///The index of the selected certificate.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Windows WebView2
  int selectedCertificate;
  ClientCertResponse({
    this.certificatePath = "",
    this.certificatePassword = "",
    @Deprecated('Use keyStoreType instead') this.androidKeyStoreType = "PKCS12",
    this.keyStoreType = "PKCS12",
    this.selectedCertificate = -1,
    this.action = ClientCertResponseAction.CANCEL,
  }) {
    if (this.action == ClientCertResponseAction.PROCEED && !Util.isWindows)
      assert(certificatePath.isNotEmpty);
    this.keyStoreType = this.keyStoreType ?? this.androidKeyStoreType;
    if (Util.isAndroid) assert(this.keyStoreType != null);
  }

  ///Gets a possible [ClientCertResponse] instance from a [Map] value.
  static ClientCertResponse? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ClientCertResponse();
    instance.action = switch (enumMethod ?? EnumMethod.nativeValue) {
      EnumMethod.nativeValue => ClientCertResponseAction.fromNativeValue(
        map['action'],
      ),
      EnumMethod.value => ClientCertResponseAction.fromValue(map['action']),
      EnumMethod.name => ClientCertResponseAction.byName(map['action']),
    };
    instance.androidKeyStoreType = map['keyStoreType'];
    instance.certificatePassword = map['certificatePassword'];
    if (map['certificatePath'] != null) {
      instance.certificatePath = map['certificatePath'];
    }
    instance.keyStoreType = map['keyStoreType'];
    if (map['selectedCertificate'] != null) {
      instance.selectedCertificate = map['selectedCertificate'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "action": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => action?.toNativeValue(),
        EnumMethod.value => action?.toValue(),
        EnumMethod.name => action?.name(),
      },
      "certificatePassword": certificatePassword,
      "certificatePath": certificatePath,
      "keyStoreType": keyStoreType,
      "selectedCertificate": selectedCertificate,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ClientCertResponse{action: $action, certificatePassword: $certificatePassword, certificatePath: $certificatePath, keyStoreType: $keyStoreType, selectedCertificate: $selectedCertificate}';
  }
}
