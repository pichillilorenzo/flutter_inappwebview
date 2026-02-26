#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  enum class ClientCertResponseAction {
    cancel = 0,
    proceed,
    ignore
  };

  inline ClientCertResponseAction ClientCertResponseActionFromInteger(const std::optional<int64_t>& action)
  {
    if (!action.has_value()) {
      return ClientCertResponseAction::cancel;
    }
    switch (action.value()) {
    case 0:
      return ClientCertResponseAction::cancel;
    case 1:
      return ClientCertResponseAction::proceed;
    case 2:
      return ClientCertResponseAction::ignore;
    default:
      return ClientCertResponseAction::cancel;
    }
  }

  inline std::optional<int64_t> ClientCertResponseActionToInteger(const std::optional<ClientCertResponseAction>& action)
  {
    return action.has_value() ? static_cast<int64_t>(action.value()) : std::optional<int64_t>{};
  }

  class ClientCertResponse
  {
  public:
    const int64_t selectedCertificate;
    const std::optional<ClientCertResponseAction> action;

    ClientCertResponse(const int64_t& selectedCertificate,
      const std::optional<ClientCertResponseAction>& action);
    ClientCertResponse(const flutter::EncodableMap& map);
    ~ClientCertResponse() = default;

    bool ClientCertResponse::operator==(const ClientCertResponse& other)
    {
      return selectedCertificate == other.selectedCertificate &&
        action == other.action;
    }
    bool ClientCertResponse::operator!=(const ClientCertResponse& other)
    {
      return !(*this == other);
    }

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_CLIENT_CERT_RESPONSE_H_