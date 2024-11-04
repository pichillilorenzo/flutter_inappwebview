#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_

#include <flutter/standard_method_codec.h>
#include <optional>

namespace flutter_inappwebview_plugin
{
  enum class ServerTrustAuthResponseAction {
    cancel = 0,
    proceed
  };

  inline ServerTrustAuthResponseAction ServerTrustAuthResponseActionFromInteger(const std::optional<int64_t>& action)
  {
    if (!action.has_value()) {
      return ServerTrustAuthResponseAction::cancel;
    }
    switch (action.value()) {
    case 1:
      return ServerTrustAuthResponseAction::proceed;
    case 0:
    default:
      return ServerTrustAuthResponseAction::cancel;
    }
  }

  inline std::optional<int64_t> ServerTrustAuthResponseActionToInteger(const std::optional<ServerTrustAuthResponseAction>& action)
  {
    return action.has_value() ? static_cast<int64_t>(action.value()) : std::optional<int64_t>{};
  }

  class ServerTrustAuthResponse
  {
  public:
    const std::optional<ServerTrustAuthResponseAction> action;

    ServerTrustAuthResponse(const std::optional<ServerTrustAuthResponseAction>& action);
    ServerTrustAuthResponse(const flutter::EncodableMap& map);
    ~ServerTrustAuthResponse() = default;

    bool ServerTrustAuthResponse::operator==(const ServerTrustAuthResponse& other)
    {
      return action == other.action;
    }
    bool ServerTrustAuthResponse::operator!=(const ServerTrustAuthResponse& other)
    {
      return !(*this == other);
    }

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_SERVER_TRUST_AUTH_RESPONSE_H_