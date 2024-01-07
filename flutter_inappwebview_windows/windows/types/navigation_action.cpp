#include "navigation_action.h"

#include "../utils/util.h"

namespace flutter_inappwebview_plugin
{
    NavigationAction::NavigationAction(std::shared_ptr<URLRequest> request, const bool& isForMainFrame)
            : request(std::move(request)), isForMainFrame(isForMainFrame)
    {

    }

    flutter::EncodableMap NavigationAction::toEncodableMap()
    {
        return flutter::EncodableMap{
                {flutter::EncodableValue("request"), request->toEncodableMap()},
                {flutter::EncodableValue("isForMainFrame"), flutter::EncodableValue(isForMainFrame)}
        };
    }
}