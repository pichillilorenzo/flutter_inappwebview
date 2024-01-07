#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#include <iostream>
#include <string>
#include <optional>
#include <algorithm>
#include "strconv.h"

namespace flutter_inappwebview_plugin
{
	static inline void debugLog(const std::string& msg) {
#ifndef NDEBUG
		std::cout << msg << std::endl;
		OutputDebugString(ansi_to_wide(msg + "\n").c_str());
#endif
	}

	template<typename T>
	static inline std::optional<T> make_pointer_optional(const T* value)
	{
		return value == nullptr ? std::nullopt : std::make_optional<T>(*value);
	}

	template<typename T>
	static inline T get_fl_map_value(const flutter::EncodableMap map, const char* string)
	{
		return std::get<T>(map.at(flutter::EncodableValue(string)));
	}

	template<typename T>
	static inline std::optional<T> get_optional_fl_map_value(const flutter::EncodableMap map, const char* string)
	{
		return make_pointer_optional<T>(std::get_if<T>(&map.at(flutter::EncodableValue(string))));
	}

	static inline std::optional<std::map<std::string, std::string>> get_optional_fl_map_value(const flutter::EncodableMap map, const char* string)
	{
		auto mapValue = std::map<std::string, std::string>{};
		auto flMap = std::get_if<flutter::EncodableMap>(&map.at(flutter::EncodableValue(string)));
		if (flMap) {
			for (auto itr = flMap->begin(); itr != flMap->end(); itr++)
			{
				mapValue.insert({ std::get<std::string>(itr->first),  std::get<std::string>(itr->second) });
			}
		}
		return make_pointer_optional<std::map<std::string, std::string>>(&mapValue);
	}

	template<typename T>
	static inline flutter::EncodableValue optional_to_fl_value(const std::optional<T> optional)
	{
		return optional.has_value() ? flutter::EncodableValue(optional.value()) : flutter::EncodableValue();
	}

	static inline flutter::EncodableValue optional_to_fl_value(const std::optional<std::map<std::string, std::string>> optional)
	{
		if (!optional.has_value()) {
			return flutter::EncodableValue();
		}
		auto& mapValue = optional.value();
		auto encodableMap = flutter::EncodableMap{};
		for (auto const& [key, val] : mapValue)
		{
			encodableMap.insert({ flutter::EncodableValue(key), flutter::EncodableValue(val) });
		}
		return encodableMap;
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