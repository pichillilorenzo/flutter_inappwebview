import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import 'url_authentication_challenge.dart';
import 'url_protection_space.dart';
import 'enum_method.dart';

part 'server_trust_challenge.g.dart';

///Class that represents the challenge of the [PlatformWebViewCreationParams.onReceivedServerTrustAuthRequest] event.
///It provides all the information about the challenge.
@ExchangeableObject()
class ServerTrustChallenge_ extends URLAuthenticationChallenge_ {
  ServerTrustChallenge_({required super.protectionSpace});
}
