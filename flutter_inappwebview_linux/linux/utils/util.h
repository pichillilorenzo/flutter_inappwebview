#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#include <limits.h>
#include <unistd.h>

#include <cstring>
#include <optional>
#include <string>
#include <variant>

#include <gio/gio.h>

namespace flutter_inappwebview_plugin {

// Helper for static_assert in constexpr if
template <class>
inline constexpr bool always_false_v = false;

template <typename T>
static inline std::optional<T> make_pointer_optional(const T* value) {
  return value == nullptr ? std::nullopt : std::make_optional<T>(*value);
}

static inline std::string variant_to_string(const std::variant<std::string, int64_t>& var) {
  return std::visit(
      [](auto&& arg) {
        using T = std::decay_t<decltype(arg)>;
        if constexpr (std::is_same_v<T, std::string>)
          return arg;
        else if constexpr (std::is_arithmetic_v<T>)
          return std::to_string(arg);
        else
          static_assert(always_false_v<T>, "non-exhaustive visitor!");
      },
      var);
}

// === Application ID Utilities ===
// Used for creating app-specific storage paths (credentials, content filters, etc.)

static inline bool is_allowed_app_id_char(char c) {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') ||
         c == '.' || c == '_' || c == '-';
}

static inline std::string sanitize_app_id(std::string id) {
  std::string out;
  out.reserve(id.size());

  bool last_was_underscore = false;
  for (char c : id) {
    char mapped = is_allowed_app_id_char(c) ? c : '_';
    if (mapped == '_' && last_was_underscore) {
      continue;
    }
    out.push_back(mapped);
    last_was_underscore = (mapped == '_');
  }

  // Trim underscores.
  while (!out.empty() && out.front() == '_') {
    out.erase(out.begin());
  }
  while (!out.empty() && out.back() == '_') {
    out.pop_back();
  }

  if (out.size() > 128) {
    out.resize(128);
  }
  if (out.empty()) {
    out = "unknown_app";
  }
  return out;
}

static inline std::string resolve_app_id_from_gapplication() {
  GApplication* app = g_application_get_default();
  if (app == nullptr) {
    return "";
  }
  const gchar* id = g_application_get_application_id(app);
  if (id == nullptr || id[0] == '\0') {
    return "";
  }
  return std::string(id);
}

static inline std::string basename_of_path(const std::string& path) {
  if (path.empty()) {
    return "";
  }
  size_t last_slash = path.find_last_of('/');
  if (last_slash == std::string::npos) {
    return path;
  }
  if (last_slash + 1 >= path.size()) {
    return "";
  }
  return path.substr(last_slash + 1);
}

static inline std::string resolve_app_id_from_executable_basename() {
  char buf[PATH_MAX + 1];
  ssize_t len = readlink("/proc/self/exe", buf, PATH_MAX);
  if (len <= 0) {
    return "";
  }
  buf[len] = '\0';
  std::string exe_path(buf);

  return basename_of_path(exe_path);
}

/// Resolves a sanitized application ID for use in storage paths.
/// Tries GApplication ID first, falls back to executable name.
static inline std::string resolve_application_id_sanitized() {
  std::string raw = resolve_app_id_from_gapplication();
  if (raw.empty()) {
    raw = resolve_app_id_from_executable_basename();
  }
  return sanitize_app_id(raw);
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
