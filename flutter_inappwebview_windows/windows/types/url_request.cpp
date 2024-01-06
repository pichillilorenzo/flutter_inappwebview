#include "url_request.h"

#include "../utils/util.h"

namespace flutter_inappwebview_plugin
{
	URLRequest::URLRequest(const flutter::EncodableMap map)
		: url(get_optional_flutter_value<std::string>(map, "url")),
		method(get_optional_flutter_value<std::string>(map, "method"))
	{

	}
}