#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * URL credential for storing/providing authentication credentials.
 */
class URLCredential {
 public:
  std::optional<std::string> username;
  std::optional<std::string> password;

  URLCredential();
  URLCredential(const std::optional<std::string>& username,
                const std::optional<std::string>& password);
  URLCredential(FlValue* map);
  ~URLCredential() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_URL_CREDENTIAL_H_
