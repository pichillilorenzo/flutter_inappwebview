#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_MESSAGE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_MESSAGE_H_

#include <cstdint>
#include <nlohmann/json.hpp>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  // Wire format of the JavaScript bridge, kept free of WebView2 types so it can
  // be unit tested.
  class JavaScriptBridgeMessage
  {
  public:
    // A callHandler call arrives as one string: the prefix, the JSON header,
    // a newline and the arguments, already JSON. JSON.stringify never emits a
    // raw newline, so the first one ends the header.
    inline static const std::string CALL_PREFIX = "fiaw1:";

    struct Call {
      nlohmann::json header;
      std::string argsJson;
    };

    static std::optional<Call> parseCall(const std::string& raw)
    {
      if (raw.compare(0, CALL_PREFIX.size(), CALL_PREFIX) != 0) {
        return std::nullopt;
      }
      const auto newline = raw.find('\n', CALL_PREFIX.size());
      if (newline == std::string::npos) {
        return std::nullopt;
      }
      auto header = nlohmann::json::parse(
        raw.begin() + CALL_PREFIX.size(), raw.begin() + newline, nullptr, false);
      if (header.is_discarded() || !header.is_object()) {
        return std::nullopt;
      }
      return Call{ std::move(header), raw.substr(newline + 1) };
    }

    // [valueJson] comes from Dart's jsonEncode and is embedded as is.
    static std::string resolution(const std::string& bridgeName,
                                  const int64_t id, const std::string& valueJson)
    {
      return "{" + nlohmann::json(bridgeName).dump() + ":{\"id\":" +
             std::to_string(id) + ",\"v\":" + valueJson + "}}";
    }

    static std::string rejection(const std::string& bridgeName,
                                 const int64_t id, const std::string& message)
    {
      return "{" + nlohmann::json(bridgeName).dump() + ":{\"id\":" +
             std::to_string(id) + ",\"e\":" + errorJson(message) + "}}";
    }

    // The same settlement as a script, for pages that cannot receive web
    // messages right now (a suspended page receives them only on resume).
    static std::string settleScript(const std::string& bridgeName,
                                    const int64_t id, const std::string& valueJson,
                                    const std::optional<std::string>& error)
    {
      const auto entry = "window." + bridgeName + "[" + std::to_string(id) + "]";
      const auto settle = error.has_value()
        ? "p.reject(new Error(" + errorJson(error.value()) + "));"
        : "p.resolve(" + valueJson + ");";
      return "(function() { var p = " + entry + "; if (p != null) { delete " +
             entry + "; " + settle + " } })();";
    }

  private:
    static std::string errorJson(const std::string& message)
    {
      return nlohmann::json(message).dump(-1, ' ', false,
        nlohmann::json::error_handler_t::replace);
    }
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_JAVASCRIPT_BRIDGE_MESSAGE_H_
