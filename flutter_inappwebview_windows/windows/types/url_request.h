#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_

#include <flutter/standard_method_codec.h>

#include <optional>

namespace flutter_inappwebview_plugin
{
	class URLRequest
	{
	public:
		const std::optional<std::string> url;
		const std::optional<std::string> method;

		URLRequest(const flutter::EncodableMap map);
	};
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_URL_REQUEST_H_