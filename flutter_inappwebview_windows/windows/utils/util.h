#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#include <string>
#include <optional>

namespace flutter_inappwebview_plugin
{
	template<typename T>
	static inline std::optional<T> make_pointer_optional(const T* value)
	{
		return value == nullptr ? std::nullopt : std::make_optional<T>(*value);
	}

	template<typename T>
	static inline T get_flutter_value(const flutter::EncodableMap map, const char* string)
	{
		return std::get<T>(map.at(flutter::EncodableValue(string)));
	}

	template<typename T>
	static inline std::optional<T> get_optional_flutter_value(const flutter::EncodableMap map, const char* string)
	{
		return make_pointer_optional<T>(std::get_if<T>(&map.at(flutter::EncodableValue(string))));
	}

	static inline std::string variant_to_string(std::variant<std::string, int> var)
	{
		return std::visit([](auto&& arg) {
			using T = std::decay_t<decltype(arg)>;
			if constexpr (std::is_same_v<T, std::string>)
				return arg;
			else if constexpr (std::is_arithmetic_v<T>)
				return std::to_string(arg);
			else
				static_assert(always_false_v<T>, "non-exhaustive visitor!");
			}, var);
	}
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_