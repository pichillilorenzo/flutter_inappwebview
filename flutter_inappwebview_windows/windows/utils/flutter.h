#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_UTIL_H_

#include <flutter/encodable_value.h>
#include <optional>
#include <string>

#include "util.h"

namespace flutter_inappwebview_plugin
{
  static inline flutter::EncodableValue make_fl_value()
  {
    return flutter::EncodableValue();
  }

  template<typename T>
  static inline flutter::EncodableValue make_fl_value(const T& val)
  {
    return flutter::EncodableValue(val);
  }

  template<typename T>
  static inline flutter::EncodableValue make_fl_value(const T* val)
  {
    return val == nullptr ? make_fl_value() : flutter::EncodableValue(val);
  }

  template<typename T>
  static inline flutter::EncodableValue make_fl_value(const std::vector<T>& vec)
  {
    auto encodableList = flutter::EncodableList{};
    for (auto const& val : vec) {
      encodableList.push_back(make_fl_value(val));
    }
    return encodableList;
  }

  template<typename K, typename T>
  static inline flutter::EncodableValue make_fl_value(const std::map<K, T>& map)
  {
    auto encodableMap = flutter::EncodableMap{};
    for (auto const& [key, val] : map) {
      encodableMap.insert({ make_fl_value(key), make_fl_value(val) });
    }
    return encodableMap;
  }

  template<typename T>
  static inline flutter::EncodableValue make_fl_value(const std::optional<T>& optional)
  {
    return optional.has_value() ? make_fl_value(optional.value()) : make_fl_value();
  }

  template<typename T>
  static inline flutter::EncodableValue make_fl_value(const std::optional<std::vector<T>>& optional)
  {
    if (!optional.has_value()) {
      return make_fl_value();
    }
    auto& vecValue = optional.value();
    auto encodableList = flutter::EncodableList{};
    for (auto const& val : vecValue) {
      encodableList.push_back(make_fl_value(val));
    }
    return encodableList;
  }

  template<typename K, typename T>
  static inline flutter::EncodableValue make_fl_value(const std::optional<std::map<K, T>>& optional)
  {
    if (!optional.has_value()) {
      return make_fl_value();
    }
    auto& mapValue = optional.value();
    auto encodableMap = flutter::EncodableMap{};
    for (auto const& [key, val] : mapValue) {
      encodableMap.insert({ make_fl_value(key), make_fl_value(val) });
    }
    return encodableMap;
  }

  template<typename T>
  static inline T get_fl_map_value(const flutter::EncodableMap& map, const char* string)
  {
    return std::get<T>(map.at(make_fl_value(string)));
  }

  template<typename T>
  static inline std::optional<T> get_optional_fl_map_value(const flutter::EncodableMap& map, const char* string)
  {
    return make_pointer_optional<T>(std::get_if<T>(&map.at(make_fl_value(string))));
  }

  template<typename K, typename T>
  static inline std::optional<std::map<K, T>> get_optional_fl_map_value(const flutter::EncodableMap& map, const char* string)
  {
    auto flMap = std::get_if<flutter::EncodableMap>(&map.at(make_fl_value(string)));
    if (flMap) {
      auto mapValue = std::map<K, T>{};
      for (auto itr = flMap->begin(); itr != flMap->end(); itr++) {
        mapValue.insert({ std::get<K>(itr->first),  std::get<T>(itr->second) });
      }
      return make_pointer_optional<std::map<K, T>>(&mapValue);
    }
    return std::nullopt;
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FLUTTER_UTIL_H_