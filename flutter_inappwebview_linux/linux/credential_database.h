#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CREDENTIAL_DATABASE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CREDENTIAL_DATABASE_H_

#include <flutter_linux/flutter_linux.h>
#include <libsecret/secret.h>

#include <functional>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

/**
 * Represents a URL protection space for HTTP authentication.
 */
struct ProtectionSpace {
  std::string host;
  int port = 0;
  std::optional<std::string> protocol;
  std::optional<std::string> realm;

  ProtectionSpace() = default;
  ProtectionSpace(FlValue* map);

  FlValue* toFlValue() const;

  // Comparison for map usage
  bool operator==(const ProtectionSpace& other) const;
};

/**
 * Represents a URL credential (username/password pair).
 */
struct Credential {
  std::string username;
  std::string password;

  Credential() = default;
  Credential(const std::string& username, const std::string& password);
  Credential(FlValue* map);

  FlValue* toFlValue() const;
};

/**
 * Manages HTTP authentication credentials using libsecret for secure storage.
 *
 * Credentials are stored in the system keyring (gnome-keyring, KDE Wallet, etc.)
 * using the Secret Service D-Bus API.
 *
 * Schema: com.pichillilorenzo.flutter_inappwebview.HttpAuth
 * Attributes: appId, host, port, protocol, realm, username
 */
class CredentialDatabase : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_credential_database";

  explicit CredentialDatabase(PluginInstance* plugin);
  ~CredentialDatabase() override;

  /// Get the plugin instance
  PluginInstance* plugin() const { return plugin_; }

  void HandleMethodCall(FlMethodCall* method_call) override;

  // Credential operations
  std::vector<std::pair<ProtectionSpace, std::vector<Credential>>> getAllAuthCredentials();

  std::vector<Credential> getHttpAuthCredentials(const ProtectionSpace& protectionSpace);

  /**
   * Lookup a single credential by username.
   * Used for USE_SAVED_CREDENTIAL action.
   */
  std::optional<Credential> lookupCredential(const ProtectionSpace& protectionSpace,
                                              const std::string& username);

  /**
   * Lookup the first available credential for a protection space.
   * Used when username is not specified.
   */
  std::optional<Credential> lookupFirstCredential(const ProtectionSpace& protectionSpace);

  void setHttpAuthCredential(const ProtectionSpace& protectionSpace, const Credential& credential);

  void removeHttpAuthCredential(const ProtectionSpace& protectionSpace,
                                const Credential& credential);

  void removeHttpAuthCredentials(const ProtectionSpace& protectionSpace);

  void clearAllAuthCredentials();

 private:
  PluginInstance* plugin_ = nullptr;

  // The libsecret schema for HTTP auth credentials
  static const SecretSchema* getSchema();

  // In-memory index of stored credentials (for getAllAuthCredentials)
  // Key: "host:port:protocol:realm", Value: list of usernames
  std::map<std::string, std::vector<std::string>> credentials_index_;
  std::string index_path_;

  // Load/save the credential index (just usernames, not passwords)
  void loadIndex();
  void saveIndex();
  static std::string getIndexPath(const std::string& app_id);
  static std::string makeKey(const ProtectionSpace& ps);

  // Generate a human-readable label for the credential
  static std::string makeLabel(const ProtectionSpace& ps, const std::string& username);

  // Parse key back to ProtectionSpace
  static ProtectionSpace fromKey(const std::string& key);

  std::string app_id_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CREDENTIAL_DATABASE_H_
