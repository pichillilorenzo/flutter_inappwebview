#include <memory>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include "in_app_browser_manager.h"

#include "../types/url_request.h"

#include "../utils/util.h"

namespace flutter_inappwebview_plugin
{
	InAppBrowserManager::InAppBrowserManager(FlutterInappwebviewWindowsBasePlugin* plugin)
		: plugin(plugin), ChannelDelegate(plugin->registrar->messenger(), InAppBrowserManager::METHOD_CHANNEL_NAME)
	{

	}

	void InAppBrowserManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (method_call.method_name().compare("open") == 0) {
			auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
			open(arguments);
			result->Success(flutter::EncodableValue(true));
		}
		else {
			result->NotImplemented();
		}
	}

	void InAppBrowserManager::open(const flutter::EncodableMap* arguments)
	{
		auto id = std::get<std::string>(arguments->at(flutter::EncodableValue("id")));
		auto urlRequestMap = std::get_if<flutter::EncodableMap>(&arguments->at(flutter::EncodableValue("urlRequest")));
		auto urlRequest = make_pointer_optional<URLRequest>(new URLRequest(*urlRequestMap));

		InAppBrowserCreationParams params = {
			id,
			urlRequest
		};
		auto inAppBrowser = std::make_unique<InAppBrowser>(plugin, params);
		browsers[id] = std::move(inAppBrowser);
	}

	InAppBrowserManager::~InAppBrowserManager()
	{
		std::cout << "dealloc InAppBrowserManager\n";
		for (std::map<std::string, std::unique_ptr<InAppBrowser>>::iterator itr = browsers.begin(); itr != browsers.end(); itr++)
		{
			browsers.erase(itr->first);
		}
		browsers.clear();
		plugin = nullptr;
	}
}