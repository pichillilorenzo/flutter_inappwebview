#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

namespace drago_inappwebview_plugin
{
  enum class HttpAuthResponseAction {
    cancel = 0,
    proceed,
    useSavedHttpAuthCredentials // not supported currently
  };

  inline HttpAuthResponseAction HttpAuthResponseActionFromInteger(const std::optional<int64_t>& action)
  {
    if (!action.has_value()) {
      return HttpAuthResponseAction::cancel;
    }
    switch (action.value()) {
    case 0:
      return HttpAuthResponseAction::cancel;
    case 1:
      return HttpAuthResponseAction::proceed;
    case 2:
      // not supported currently
      // return HttpAuthResponseAction::useSavedHttpAuthCredentials;
    default:
      return HttpAuthResponseAction::cancel;
    }
  }

  inline std::optional<int64_t> HttpAuthResponseActionToInteger(const std::optional<HttpAuthResponseAction>& action)
  {
    return action.has_value() ? static_cast<int64_t>(action.value()) : std::optional<int64_t>{};
  }

  class HttpAuthResponse
  {
  public:
    const std::string username;
    const std::string password;
    const bool permanentPersistence;
    const std::optional<HttpAuthResponseAction> action;

    HttpAuthResponse(const std::string& username,
      const std::string& password,
      const bool& permanentPersistence,
      const std::optional<HttpAuthResponseAction>& action);
    HttpAuthResponse(const flutter::EncodableMap& map);
    ~HttpAuthResponse() = default;

    bool operator==(const HttpAuthResponse& other)
    {
      return username == other.username && password == other.password &&
        permanentPersistence == other.permanentPersistence &&
        action == other.action;
    }
    bool operator!=(const HttpAuthResponse& other)
    {
      return !(*this == other);
    }

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_HTTP_AUTH_RESPONSE_H_