#include "url_request.h"

#include "../utils/util.h"

namespace flutter_inappwebview_plugin
{
	URLRequest::URLRequest(std::optional<std::string> url, std::optional<std::string> method, std::optional<std::map<std::string, std::string>> headers, std::optional<std::vector<uint8_t>> body)
		: url(url), method(method), headers(headers), body(body)
	{

	}

	URLRequest::URLRequest(const flutter::EncodableMap map)
		: url(get_optional_fl_map_value<std::string>(map, "url")),
		method(get_optional_fl_map_value<std::string>(map, "method")),
		headers(get_optional_fl_map_value(map, "headers")),
		body(get_optional_fl_map_value<std::vector<uint8_t>>(map, "body"))
	{

	}

	flutter::EncodableMap URLRequest::toEncodableMap()
	{
		return flutter::EncodableMap{
			{flutter::EncodableValue("url"), optional_to_fl_value(url)},
			{flutter::EncodableValue("method"), optional_to_fl_value(method)},
			{flutter::EncodableValue("headers"), optional_to_fl_value(headers)},
			{flutter::EncodableValue("body"), optional_to_fl_value(body)}
		};
	}
}