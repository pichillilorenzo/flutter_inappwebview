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

	static inline std::string variant_to_string(const std::variant<std::string, int>& var)
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

	template<typename K, typename T>
	static inline bool map_contains(const std::map<K, T>& map, const K& key)
	{
		return  map.find(key) != map.end();
	}

	template<typename K, typename T>
	static inline T map_at_or_null(const std::map<K, T>& map, const K& key)
	{
		auto itr = map.find(key);
		return itr != map.end() ? itr->second : nullptr;
	}
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_