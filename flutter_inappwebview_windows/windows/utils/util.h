#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#include <algorithm>
#include <comdef.h>
#include <iostream>
#include <map>
#include <optional>
#include <string>
#include <variant>

#include "strconv.h"

namespace flutter_inappwebview_plugin
{
  template<typename T = void, typename = void>
  struct is_vector_impl : std::false_type { };

  template<typename T, typename U = void>
  struct is_mappish_impl : std::false_type { };

  template<typename T>
  struct is_vector_impl<T, std::enable_if_t<
    std::is_same<T, typename std::vector<std::string>>::value>
  > : std::true_type { };

  template<typename T>
  struct is_vector_impl<T, std::enable_if_t<
    std::is_same<T, typename std::vector<typename std::iterator_traits<T>::value_type>::iterator>::value>
  > : std::true_type { };

  template<typename T>
  struct is_mappish_impl<T, std::void_t<typename T::key_type,
    typename T::mapped_type,
    decltype(std::declval<T&>()[std::declval<const typename T::key_type&>()])>>
    : std::true_type { };

  template<typename T>
  struct is_mappish : is_mappish_impl<T>::type { };

  template<typename T>
  struct is_vector : is_vector_impl<T>::type { };

  static inline void debugLog(const std::string& msg)
  {
#ifndef NDEBUG
    std::cout << msg << std::endl;
    OutputDebugString(ansi_to_wide(msg + "\n").c_str());
#endif
  }

  static inline std::string getErrorMessage(const HRESULT& error)
  {
    _com_error err(error);
    return wide_to_ansi(err.ErrorMessage());
  }

  template<typename T>
  static inline std::optional<T> make_pointer_optional(const T* value)
  {
    return value == nullptr ? std::nullopt : std::make_optional<T>(*value);
  }

  static inline std::string variant_to_string(const std::variant<std::string, int64_t>& var)
  {
    return std::visit([](auto&& arg)
      {
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

  template <typename Iterator, typename Func>
  static inline auto functional_map(Iterator begin, Iterator end, Func&& func) ->
    std::vector<decltype(func(std::declval<typename Iterator::value_type>()))>
  {
    using value_type = decltype(func(std::declval<typename Iterator::value_type>()));

    std::vector<value_type> out_vector;
    out_vector.reserve(std::distance(begin, end));

    std::transform(begin, end, std::back_inserter(out_vector),
      std::forward<Func>(func));

    return out_vector;
  }

  template <typename T, typename Func>
  static inline auto functional_map(const T& iterable, Func&& func) ->
    std::vector<decltype(func(std::declval<typename T::value_type>()))>
  {
    return functional_map(std::begin(iterable), std::end(iterable),
      std::forward<Func>(func));
  }

  template <typename T, typename Func>
  static inline auto functional_map(const std::optional<T>& iterable, Func&& func) ->
    std::vector<decltype(func(std::declval<typename T::value_type>()))>
  {
    if (!iterable.has_value()) {
      return {};
    }
    return functional_map(iterable.value(), std::forward<Func>(func));
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_