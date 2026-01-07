#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_

#include <iomanip>
#include <regex>
#include <string>

#include "string.h"

namespace flutter_inappwebview_plugin {

// Extract origin (scheme + host + port) from a URL
static inline std::string get_origin_from_url(const std::string& url) {
  // Try to parse using regex for common URL formats
  try {
    // Pattern: scheme://host[:port][/path...]
    std::regex url_regex(R"(^([a-zA-Z][a-zA-Z0-9+.-]*):\/\/([^:\/\?#]+)(?::(\d+))?)",
                         std::regex::ECMAScript);
    std::smatch match;

    if (std::regex_search(url, match, url_regex)) {
      std::string scheme = match[1].str();
      std::string host = match[2].str();
      std::string port_str = match[3].str();

      std::string origin = scheme + "://" + host;

      if (!port_str.empty()) {
        int port = std::stoi(port_str);
        // Only add port if it's not the default for the scheme
        bool isDefaultPort = (string_equals(scheme, "http") && port == 80) ||
                             (string_equals(scheme, "https") && port == 443);
        if (!isDefaultPort) {
          origin += ":" + port_str;
        }
      }

      return origin;
    }
  } catch (const std::regex_error&) {
    // Fallback to simple string parsing
  }

  // Fallback: simple string parsing
  auto urlSplit = split(url, std::string{"://"});
  if (urlSplit.size() > 1) {
    auto scheme = urlSplit[0];
    auto afterScheme = urlSplit[1];
    auto afterSchemeSplit = split(afterScheme, std::string{"/"});
    auto hostPort = afterSchemeSplit[0];

    // Further split to remove query string if present
    auto hostPortSplit = split(hostPort, std::string{"?"});
    hostPort = hostPortSplit[0];

    return scheme + "://" + hostPort;
  }

  return url;
}

// Check if a URL is valid
static inline bool is_valid_url(const std::string& url) {
  if (url.empty()) {
    return false;
  }

  try {
    std::regex url_regex(R"(^[a-zA-Z][a-zA-Z0-9+.-]*:\/\/[^\s]+$)", std::regex::ECMAScript);
    return std::regex_match(url, url_regex);
  } catch (const std::regex_error&) {
    // Fallback: check for basic URL structure
    return url.find("://") != std::string::npos;
  }
}

// Extract scheme from URL
static inline std::string get_scheme_from_url(const std::string& url) {
  auto pos = url.find("://");
  if (pos != std::string::npos) {
    return url.substr(0, pos);
  }
  return "";
}

// Extract host from URL
static inline std::string get_host_from_url(const std::string& url) {
  auto urlSplit = split(url, std::string{"://"});
  if (urlSplit.size() > 1) {
    auto afterScheme = urlSplit[1];
    auto afterSchemeSplit = split(afterScheme, std::string{"/"});
    auto hostPort = afterSchemeSplit[0];

    // Remove port if present
    auto colonPos = hostPort.find(':');
    if (colonPos != std::string::npos) {
      return hostPort.substr(0, colonPos);
    }
    return hostPort;
  }
  return "";
}

// URL encode a string
static inline std::string url_encode(const std::string& value) {
  std::ostringstream escaped;
  escaped.fill('0');
  escaped << std::hex;

  for (auto c : value) {
    // Keep alphanumeric and other accepted characters intact
    if (std::isalnum(static_cast<unsigned char>(c)) || c == '-' || c == '_' || c == '.' ||
        c == '~') {
      escaped << c;
    } else {
      // Percent-encode other characters
      escaped << '%' << std::setw(2) << static_cast<int>(static_cast<unsigned char>(c));
    }
  }

  return escaped.str();
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_
