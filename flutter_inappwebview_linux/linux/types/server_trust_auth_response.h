#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>

namespace flutter_inappwebview_plugin {

/**
 * Action to take in response to a server trust authentication challenge.
 * Maps to Dart's ServerTrustAuthResponseAction.
 */
enum class ServerTrustAuthResponseAction {
  CANCEL = 0,   // Reject the certificate and cancel the request
  PROCEED = 1,  // Accept the certificate and continue the request
};

/**
 * Response to a server trust authentication challenge.
 * Maps to Dart's ServerTrustAuthResponse.
 */
class ServerTrustAuthResponse {
 public:
  ServerTrustAuthResponseAction action;

  explicit ServerTrustAuthResponse(ServerTrustAuthResponseAction action = ServerTrustAuthResponseAction::CANCEL);
  ~ServerTrustAuthResponse() = default;

  /**
   * Create from FlValue map (from Dart response).
   */
  static std::optional<ServerTrustAuthResponse> fromFlValue(FlValue* value);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_
