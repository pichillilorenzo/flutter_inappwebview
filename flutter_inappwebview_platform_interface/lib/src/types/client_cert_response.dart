import '../in_app_webview/platform_webview.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../util.dart';
import 'client_cert_response_action.dart';
import 'enum_method.dart';

part 'client_cert_response.g.dart';

///Class that represents the response used by the [PlatformWebViewCreationParams.onReceivedClientCertRequest] event.
@ExchangeableObject()
class ClientCertResponse_ {
  ///The file path of the certificate to use.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  String certificatePath;

  ///The certificate password.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  String? certificatePassword;

  ///Use [keyStoreType] instead.
  @Deprecated('Use keyStoreType instead')
  String? androidKeyStoreType;

  ///An Android-specific property used by Java [KeyStore](https://developer.android.com/reference/java/security/KeyStore) class to get the instance.
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
  ])
  String? keyStoreType;

  ///The index of the selected certificate.
  @SupportedPlatforms(platforms: [
    WindowsPlatform(),
  ])
  int selectedCertificate;

  ///Indicate the [ClientCertResponseAction] to take in response of the client certificate challenge.
  ClientCertResponseAction_? action;

  @ExchangeableObjectConstructor()
  ClientCertResponse_(
      {this.certificatePath = "",
      this.certificatePassword = "",
      @Deprecated('Use keyStoreType instead')
      this.androidKeyStoreType = "PKCS12",
      this.keyStoreType = "PKCS12",
      this.selectedCertificate = -1,
      this.action = ClientCertResponseAction_.CANCEL}) {
    if (this.action == ClientCertResponseAction_.PROCEED && !Util.isWindows)
      assert(certificatePath.isNotEmpty);

    this.keyStoreType = this.keyStoreType ?? this.androidKeyStoreType;

    if (Util.isAndroid) assert(this.keyStoreType != null);
  }
}
