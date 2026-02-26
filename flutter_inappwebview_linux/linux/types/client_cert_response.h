#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Action to take in response to a client certificate request.
 */
enum class ClientCertResponseAction {
  CANCEL = 0,   // Cancel the request
  PROCEED = 1,  // Proceed with a certificate
  IGNORE = 2,   // Ignore the request (for now)
};

/**
 * Response to a client certificate challenge.
 * 
 * NOTE: WPE WebKit's ability to programmatically provide a client certificate
 * is limited. The webkit_credential_new_for_certificate() API requires a
 * GTlsCertificate which must be loaded from a file. If the certificate cannot
 * be loaded or the API is not available, PROCEED will behave like CANCEL.
 */
class ClientCertResponse {
 public:
  ClientCertResponseAction action;
  
  // Path to the certificate file (PEM or PKCS12 format)
  std::optional<std::string> certificatePath;
  
  // Password for the certificate (if PKCS12)
  std::optional<std::string> certificatePassword;
  
  // Key store type (e.g., "PKCS12", "PEM")
  std::optional<std::string> keyStoreType;
  
  // Index of selected certificate (for Windows compatibility, not used on Linux)
  int selectedCertificate;

  ClientCertResponse();
  explicit ClientCertResponse(FlValue* map);
  ~ClientCertResponse() = default;

  static std::optional<ClientCertResponse> fromFlValue(FlValue* value);
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_
