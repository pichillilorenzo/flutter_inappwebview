import 'package:flutter/foundation.dart';

import '../in_app_webview/webview.dart';

import 'client_cert_response_action.dart';

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

    // ignore: deprecated_member_use_from_same_package
    this.keyStoreType = this.keyStoreType ?? this.androidKeyStoreType;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      assert(this.keyStoreType != null);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "certificatePath": certificatePath,
      "certificatePassword": certificatePassword,
      // ignore: deprecated_member_use_from_same_package
      "androidKeyStoreType": keyStoreType ?? androidKeyStoreType,
      // ignore: deprecated_member_use_from_same_package
      "keyStoreType": keyStoreType ?? androidKeyStoreType,
      "action": action?.toValue()
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