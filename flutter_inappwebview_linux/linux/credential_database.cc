#include "credential_database.h"

#include <sys/stat.h>
#include <unistd.h>

#include <algorithm>
#include <cstring>
#include <fstream>
#include <sstream>

#include <nlohmann/json.hpp>

#include "plugin_instance.h"
#include "utils/flutter.h"
#include "utils/log.h"
#include "utils/util.h"

namespace flutter_inappwebview_plugin {

using json = nlohmann::json;

namespace {
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

// === Schema Definition ===

const SecretSchema* CredentialDatabase::getSchema() {
  static const SecretSchema schema = {
    "com.pichillilorenzo.flutter_inappwebview.HttpAuth",
      SECRET_SCHEMA_NONE,
      {
      {"appId", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {"host", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {"port", SECRET_SCHEMA_ATTRIBUTE_INTEGER},
          {"protocol", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {"realm", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {"username", SECRET_SCHEMA_ATTRIBUTE_STRING},
          {NULL, (SecretSchemaAttributeType)0}
      }
  };
  return &schema;
}

// === ProtectionSpace ===

ProtectionSpace::ProtectionSpace(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  host = get_fl_map_value<std::string>(map, "host", "");
  port = get_fl_map_value<int32_t>(map, "port", 0);
  protocol = get_optional_fl_map_value<std::string>(map, "protocol");
  realm = get_optional_fl_map_value<std::string>(map, "realm");
}

FlValue* ProtectionSpace::toFlValue() const {
  return to_fl_map({
      {"host", make_fl_value(host)},
      {"port", make_fl_value(port)},
      {"protocol", make_fl_value(protocol)},
      {"realm", make_fl_value(realm)},
  });
}

bool ProtectionSpace::operator==(const ProtectionSpace& other) const {
  return host == other.host && port == other.port && 
         protocol == other.protocol && realm == other.realm;
}

// === Credential ===

Credential::Credential(const std::string& username, const std::string& password)
    : username(username), password(password) {}

Credential::Credential(FlValue* map) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return;
  }

  username = get_fl_map_value<std::string>(map, "username", "");
  password = get_fl_map_value<std::string>(map, "password", "");
}

FlValue* Credential::toFlValue() const {
  return to_fl_map({
      {"username", make_fl_value(username)},
      {"password", make_fl_value(password)},
  });
}

// === CredentialDatabase ===

std::string CredentialDatabase::makeKey(const ProtectionSpace& ps) {
  std::ostringstream oss;
  oss << ps.host << ":" << ps.port << ":" 
      << ps.protocol.value_or("") << ":" 
      << ps.realm.value_or("");
  return oss.str();
}

std::string CredentialDatabase::makeLabel(const ProtectionSpace& ps, const std::string& username) {
  std::ostringstream oss;
  oss << "InAppWebView: " << username << "@" << ps.host;
  if (ps.port != 0 && ps.port != 80 && ps.port != 443) {
    oss << ":" << ps.port;
  }
  if (ps.realm.has_value() && !ps.realm->empty()) {
    oss << " (" << ps.realm.value() << ")";
  }
  return oss.str();
}

ProtectionSpace CredentialDatabase::fromKey(const std::string& key) {
  ProtectionSpace ps;
  std::vector<std::string> parts;
  std::istringstream iss(key);
  std::string part;

  // Split by ':'
  while (std::getline(iss, part, ':')) {
    parts.push_back(part);
  }

  // Handle case where key ends with colons (empty parts at end)
  size_t colonCount = std::count(key.begin(), key.end(), ':');
  while (parts.size() <= colonCount) {
    parts.push_back("");
  }

  if (parts.size() > 0) {
    ps.host = parts[0];
  }
  if (parts.size() > 1 && !parts[1].empty()) {
    try {
      ps.port = std::stoi(parts[1]);
    } catch (...) {
      ps.port = 0;
    }
  }
  if (parts.size() > 2 && !parts[2].empty()) {
    ps.protocol = parts[2];
  }
  if (parts.size() > 3 && !parts[3].empty()) {
    ps.realm = parts[3];
  }

  return ps;
}

std::string CredentialDatabase::getIndexPath(const std::string& app_id) {
  const char* xdg_data_home = getenv("XDG_DATA_HOME");
  std::string base_dir;

  if (xdg_data_home != nullptr && strlen(xdg_data_home) > 0) {
    base_dir = xdg_data_home;
  } else {
    const char* home = getenv("HOME");
    if (home != nullptr) {
      base_dir = std::string(home) + "/.local/share";
    } else {
      base_dir = "/tmp";
    }
  }

  std::string dir = base_dir + "/flutter_inappwebview";
  mkdir(dir.c_str(), 0700);

  std::string app_dir = dir + "/" + app_id;
  mkdir(app_dir.c_str(), 0700);

  return app_dir + "/credential_index.json";
}

void CredentialDatabase::loadIndex() {
  credentials_index_.clear();

  std::ifstream file(index_path_);
  if (!file.is_open()) {
    return;
  }

  try {
    json j;
    file >> j;

    if (j.is_object()) {
      for (auto& [key, usernames] : j.items()) {
        std::vector<std::string> users;
        if (usernames.is_array()) {
          for (auto& u : usernames) {
            if (u.is_string()) {
              users.push_back(u.get<std::string>());
            }
          }
        }
        credentials_index_[key] = users;
      }
    }
  } catch (const std::exception& e) {
    errorLog(std::string("CredentialDatabase: Failed to load index: ") + e.what());
    credentials_index_.clear();
  }
}

void CredentialDatabase::saveIndex() {
  json j = json::object();

  for (const auto& [key, usernames] : credentials_index_) {
    j[key] = usernames;
  }

  std::ofstream file(index_path_);
  if (file.is_open()) {
    file << j.dump(2);
    file.close();
    chmod(index_path_.c_str(), 0600);
  }
}

CredentialDatabase::CredentialDatabase(PluginInstance* plugin)
    : ChannelDelegate(plugin->messenger(), METHOD_CHANNEL_NAME),
      plugin_(plugin) {
  app_id_ = resolve_application_id_sanitized();
  index_path_ = getIndexPath(app_id_);
  loadIndex();
}

CredentialDatabase::~CredentialDatabase() {
  debugLog("dealloc CredentialDatabase");
  plugin_ = nullptr;
}

void CredentialDatabase::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(method, "getAllAuthCredentials")) {
    auto all = getAllAuthCredentials();

    g_autoptr(FlValue) result = fl_value_new_list();

    for (const auto& [ps, creds] : all) {
      FlValue* creds_list = fl_value_new_list();
      for (const auto& cred : creds) {
        fl_value_append_take(creds_list, cred.toFlValue());
      }

      FlValue* entry = to_fl_map({
          {"protectionSpace", ps.toFlValue()},
          {"credentials", creds_list},
      });

      fl_value_append_take(result, entry);
    }

    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (string_equals(method, "getHttpAuthCredentials")) {
    std::string host = get_fl_map_value<std::string>(args, "host", "");
    int port = get_fl_map_value<int32_t>(args, "port", 0);
    auto protocol = get_optional_fl_map_value<std::string>(args, "protocol");
    auto realm = get_optional_fl_map_value<std::string>(args, "realm");

    ProtectionSpace ps;
    ps.host = host;
    ps.port = port;
    ps.protocol = protocol;
    ps.realm = realm;

    auto credentials = getHttpAuthCredentials(ps);

    g_autoptr(FlValue) result = fl_value_new_list();
    for (const auto& cred : credentials) {
      fl_value_append_take(result, cred.toFlValue());
    }

    fl_method_call_respond_success(method_call, result, nullptr);

  } else if (string_equals(method, "setHttpAuthCredential")) {
    std::string host = get_fl_map_value<std::string>(args, "host", "");
    int port = get_fl_map_value<int32_t>(args, "port", 0);
    auto protocol = get_optional_fl_map_value<std::string>(args, "protocol");
    auto realm = get_optional_fl_map_value<std::string>(args, "realm");
    std::string username = get_fl_map_value<std::string>(args, "username", "");
    std::string password = get_fl_map_value<std::string>(args, "password", "");

    ProtectionSpace ps;
    ps.host = host;
    ps.port = port;
    ps.protocol = protocol;
    ps.realm = realm;

    Credential cred(username, password);

    setHttpAuthCredential(ps, cred);

    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);

  } else if (string_equals(method, "removeHttpAuthCredential")) {
    std::string host = get_fl_map_value<std::string>(args, "host", "");
    int port = get_fl_map_value<int32_t>(args, "port", 0);
    auto protocol = get_optional_fl_map_value<std::string>(args, "protocol");
    auto realm = get_optional_fl_map_value<std::string>(args, "realm");
    std::string username = get_fl_map_value<std::string>(args, "username", "");
    std::string password = get_fl_map_value<std::string>(args, "password", "");

    ProtectionSpace ps;
    ps.host = host;
    ps.port = port;
    ps.protocol = protocol;
    ps.realm = realm;

    Credential cred(username, password);

    removeHttpAuthCredential(ps, cred);

    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);

  } else if (string_equals(method, "removeHttpAuthCredentials")) {
    std::string host = get_fl_map_value<std::string>(args, "host", "");
    int port = get_fl_map_value<int32_t>(args, "port", 0);
    auto protocol = get_optional_fl_map_value<std::string>(args, "protocol");
    auto realm = get_optional_fl_map_value<std::string>(args, "realm");

    ProtectionSpace ps;
    ps.host = host;
    ps.port = port;
    ps.protocol = protocol;
    ps.realm = realm;

    removeHttpAuthCredentials(ps);

    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);

  } else if (string_equals(method, "clearAllAuthCredentials")) {
    clearAllAuthCredentials();

    fl_method_call_respond_success(method_call, fl_value_new_bool(TRUE), nullptr);

  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

std::vector<std::pair<ProtectionSpace, std::vector<Credential>>>
CredentialDatabase::getAllAuthCredentials() {
  std::vector<std::pair<ProtectionSpace, std::vector<Credential>>> result;

  for (const auto& [key, usernames] : credentials_index_) {
    // Parse key back to ProtectionSpace
    ProtectionSpace ps = fromKey(key);

    // Lookup each credential from libsecret
    std::vector<Credential> creds;
    for (const auto& username : usernames) {
      auto cred = lookupCredential(ps, username);
      if (cred.has_value()) {
        creds.push_back(cred.value());
      }
    }

    if (!creds.empty()) {
      result.push_back({ps, creds});
    }
  }

  return result;
}

std::vector<Credential> CredentialDatabase::getHttpAuthCredentials(
    const ProtectionSpace& protectionSpace) {
  std::string key = makeKey(protectionSpace);

  auto it = credentials_index_.find(key);
  if (it == credentials_index_.end()) {
    return {};
  }

  std::vector<Credential> creds;
  for (const auto& username : it->second) {
    auto cred = lookupCredential(protectionSpace, username);
    if (cred.has_value()) {
      creds.push_back(cred.value());
    }
  }

  return creds;
}

std::optional<Credential> CredentialDatabase::lookupCredential(
    const ProtectionSpace& protectionSpace, const std::string& username) {
  GError* error = nullptr;

  gchar* password = secret_password_lookup_sync(
      getSchema(),
      nullptr,
      &error,
      "appId", app_id_.c_str(),
      "host", protectionSpace.host.c_str(),
      "port", protectionSpace.port,
      "protocol", protectionSpace.protocol.value_or("").c_str(),
      "realm", protectionSpace.realm.value_or("").c_str(),
      "username", username.c_str(),
      NULL);

  if (error != nullptr) {
    errorLog(std::string("CredentialDatabase: Failed to lookup credential: ") + error->message);
    g_error_free(error);
    return std::nullopt;
  }

  if (password == nullptr) {
    return std::nullopt;
  }

  Credential cred(username, password);
  secret_password_free(password);

  return cred;
}

std::optional<Credential> CredentialDatabase::lookupFirstCredential(
    const ProtectionSpace& protectionSpace) {
  std::string key = makeKey(protectionSpace);

  auto it = credentials_index_.find(key);
  if (it == credentials_index_.end() || it->second.empty()) {
    return std::nullopt;
  }

  // Return the first available credential
  for (const auto& username : it->second) {
    auto cred = lookupCredential(protectionSpace, username);
    if (cred.has_value()) {
      return cred;
    }
  }

  return std::nullopt;
}

void CredentialDatabase::setHttpAuthCredential(const ProtectionSpace& protectionSpace,
                                               const Credential& credential) {
  GError* error = nullptr;

  std::string label = makeLabel(protectionSpace, credential.username);

  gboolean stored = secret_password_store_sync(
      getSchema(),
      SECRET_COLLECTION_DEFAULT,
      label.c_str(),
      credential.password.c_str(),
      nullptr,
      &error,
      "appId", app_id_.c_str(),
      "host", protectionSpace.host.c_str(),
      "port", protectionSpace.port,
      "protocol", protectionSpace.protocol.value_or("").c_str(),
      "realm", protectionSpace.realm.value_or("").c_str(),
      "username", credential.username.c_str(),
      NULL);

  if (error != nullptr) {
    errorLog(std::string("CredentialDatabase: Failed to store credential: ") + error->message);
    g_error_free(error);
    return;
  }

  if (!stored) {
    errorLog("CredentialDatabase: Failed to store credential (unknown error)");
    return;
  }

  // Update index
  std::string key = makeKey(protectionSpace);
  auto& usernames = credentials_index_[key];

  // Add username if not already present
  if (std::find(usernames.begin(), usernames.end(), credential.username) == usernames.end()) {
    usernames.push_back(credential.username);
  }

  saveIndex();
}

void CredentialDatabase::removeHttpAuthCredential(const ProtectionSpace& protectionSpace,
                                                  const Credential& credential) {
  GError* error = nullptr;

  secret_password_clear_sync(
      getSchema(),
      nullptr,
      &error,
      "appId", app_id_.c_str(),
      "host", protectionSpace.host.c_str(),
      "port", protectionSpace.port,
      "protocol", protectionSpace.protocol.value_or("").c_str(),
      "realm", protectionSpace.realm.value_or("").c_str(),
      "username", credential.username.c_str(),
      NULL);

  if (error != nullptr) {
    errorLog(std::string("CredentialDatabase: Failed to remove credential: ") + error->message);
    g_error_free(error);
    return;
  }

  // Update index
  std::string key = makeKey(protectionSpace);
  auto it = credentials_index_.find(key);
  if (it != credentials_index_.end()) {
    auto& usernames = it->second;
    usernames.erase(
        std::remove(usernames.begin(), usernames.end(), credential.username),
        usernames.end());
    if (usernames.empty()) {
      credentials_index_.erase(it);
    }
  }

  saveIndex();
}

void CredentialDatabase::removeHttpAuthCredentials(const ProtectionSpace& protectionSpace) {
  std::string key = makeKey(protectionSpace);

  auto it = credentials_index_.find(key);
  if (it == credentials_index_.end()) {
    return;
  }

  // Remove all credentials for this protection space
  for (const auto& username : it->second) {
    GError* error = nullptr;

    secret_password_clear_sync(
        getSchema(),
        nullptr,
        &error,
      "appId", app_id_.c_str(),
        "host", protectionSpace.host.c_str(),
        "port", protectionSpace.port,
        "protocol", protectionSpace.protocol.value_or("").c_str(),
        "realm", protectionSpace.realm.value_or("").c_str(),
        "username", username.c_str(),
        NULL);

    if (error != nullptr) {
      errorLog(std::string("CredentialDatabase: Failed to remove credential: ") + error->message);
      g_error_free(error);
    }
  }

  credentials_index_.erase(it);
  saveIndex();
}

void CredentialDatabase::clearAllAuthCredentials() {
  // Remove all credentials from libsecret
  for (const auto& [key, usernames] : credentials_index_) {
    ProtectionSpace ps = fromKey(key);

    for (const auto& username : usernames) {
      GError* error = nullptr;

      secret_password_clear_sync(
          getSchema(),
          nullptr,
          &error,
          "appId", app_id_.c_str(),
          "host", ps.host.c_str(),
          "port", ps.port,
          "protocol", ps.protocol.value_or("").c_str(),
          "realm", ps.realm.value_or("").c_str(),
          "username", username.c_str(),
          NULL);

      if (error != nullptr) {
        g_error_free(error);
      }
    }
  }

  credentials_index_.clear();

  // Remove the index file
  unlink(index_path_.c_str());
}

}  // namespace flutter_inappwebview_plugin
