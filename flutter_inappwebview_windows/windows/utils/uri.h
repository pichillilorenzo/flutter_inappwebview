#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_

#include <string>
#include <winrt/Windows.Foundation.h>

#include "string.h"

namespace flutter_inappwebview_plugin {
    static inline std::string get_origin_from_url(const std::string &url) {
        try {
            winrt::Windows::Foundation::Uri const uri{utf8_to_wide(url)};
            auto scheme = winrt::to_string(uri.SchemeName());
            auto host = winrt::to_string(uri.Host());
            if (!scheme.empty() && !host.empty()) {
                auto uriPort = uri.Port();
                std::string port = "";
                if (uriPort > 0 && ((string_equals(scheme, "http") && uriPort != 80) ||
                                    (string_equals(scheme, "https") && uriPort != 443))) {
                    port = ":" + std::to_string(uriPort);
                }
                return scheme + "://" + host + port;
            }
        }
        catch (...) {}
        auto urlSplit = split(url, std::string{"://"});
        if (urlSplit.size() > 1) {
            auto scheme = urlSplit[0];
            auto afterScheme = urlSplit[1];
            auto afterSchemeSplit = split(afterScheme, std::string{"/"});
            auto host = afterSchemeSplit[0];
            return scheme + "://" + host;
        }

        return url;
    }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_URI_UTIL_H_