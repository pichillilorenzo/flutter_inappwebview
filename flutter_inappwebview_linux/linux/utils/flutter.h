#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_FLUTTER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_FLUTTER_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

#include "map.h"
#include "util.h"
#include "vector.h"

namespace flutter_inappwebview_plugin {

// ============================================================================
// Type aliases for FlValue map building (similar to Windows EncodableMap)
// ============================================================================

/**
 * Type alias for building FlValue maps using standard C++ initializer lists.
 * This allows a consistent pattern similar to Windows' flutter::EncodableMap.
 *
 * Usage:
 *   FlValueMap map = {
 *     {"key1", make_fl_value("value1")},
 *     {"key2", make_fl_value(42)},
 *     {"key3", make_fl_value(optionalValue)},  // auto handles std::optional
 *   };
 *   return to_fl_map(map);
 */
using FlValueMap = std::initializer_list<std::pair<const char*, FlValue*>>;

/**
 * Converts an FlValueMap initializer list to an FlValue* map.
 * All values are taken (ownership transferred), so they should be created
 * with make_fl_value() or fl_value_new_*() functions.
 */
static inline FlValue* to_fl_map(FlValueMap entries) {
  FlValue* map = fl_value_new_map();
  for (const auto& [key, value] : entries) {
    fl_value_set_string_take(map, key, value);
  }
  return map;
}

// ============================================================================
// FlValue creation helpers (make_fl_value)
// ============================================================================

static inline FlValue* make_fl_value() {
  return fl_value_new_null();
}

static inline FlValue* make_fl_value(std::nullptr_t) {
  return fl_value_new_null();
}

static inline FlValue* make_fl_value(bool val) {
  return fl_value_new_bool(val);
}

static inline FlValue* make_fl_value(int32_t val) {
  return fl_value_new_int(static_cast<int64_t>(val));
}

static inline FlValue* make_fl_value(int64_t val) {
  return fl_value_new_int(val);
}

static inline FlValue* make_fl_value(double val) {
  return fl_value_new_float(val);
}

static inline FlValue* make_fl_value(const char* val) {
  return val == nullptr ? fl_value_new_null() : fl_value_new_string(val);
}

static inline FlValue* make_fl_value(const std::string& val) {
  return fl_value_new_string(val.c_str());
}

static inline FlValue* make_fl_value(const std::vector<uint8_t>& val) {
  return fl_value_new_uint8_list(val.data(), val.size());
}

template <typename T>
static inline FlValue* make_fl_value(const std::vector<T>& vec) {
  FlValue* list = fl_value_new_list();
  for (const auto& item : vec) {
    fl_value_append_take(list, make_fl_value(item));
  }
  return list;
}

template <typename K, typename V>
static inline FlValue* make_fl_value(const std::map<K, V>& map) {
  FlValue* fl_map = fl_value_new_map();
  for (const auto& [key, val] : map) {
    fl_value_set_take(fl_map, make_fl_value(key), make_fl_value(val));
  }
  return fl_map;
}

template <typename T>
static inline FlValue* make_fl_value(const std::optional<T>& optional) {
  return optional.has_value() ? make_fl_value(optional.value()) : fl_value_new_null();
}

// ============================================================================
// FlValue map access helpers
// ============================================================================

static inline bool fl_map_contains(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return false;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  return value != nullptr;
}

static inline bool fl_map_contains_not_null(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return false;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  return value != nullptr && fl_value_get_type(value) != FL_VALUE_TYPE_NULL;
}

// ============================================================================
// FlValue extraction helpers (get_fl_map_value with default)
// ============================================================================

// Generic template declaration
template <typename T>
static inline T get_fl_map_value(FlValue* map, const char* key, const T& defaultValue);

// Specialization for bool
template <>
inline bool get_fl_map_value<bool>(FlValue* map, const char* key, const bool& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_BOOL) {
    return fl_value_get_bool(value);
  }
  return defaultValue;
}

// Specialization for int64_t
template <>
inline int64_t get_fl_map_value<int64_t>(FlValue* map, const char* key,
                                         const int64_t& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return fl_value_get_int(value);
  }
  return defaultValue;
}

// Specialization for int32_t (uses int64_t internally)
template <>
inline int32_t get_fl_map_value<int32_t>(FlValue* map, const char* key,
                                         const int32_t& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return static_cast<int32_t>(fl_value_get_int(value));
  }
  return defaultValue;
}

// Specialization for double
template <>
inline double get_fl_map_value<double>(FlValue* map, const char* key, const double& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_FLOAT) {
    return fl_value_get_float(value);
  }
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return static_cast<double>(fl_value_get_int(value));
  }
  return defaultValue;
}

// Specialization for std::string
template <>
inline std::string get_fl_map_value<std::string>(FlValue* map, const char* key,
                                                 const std::string& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
    return std::string(fl_value_get_string(value));
  }
  return defaultValue;
}

// Specialization for std::vector<std::string>
template <>
inline std::vector<std::string> get_fl_map_value<std::vector<std::string>>(
    FlValue* map, const char* key, const std::vector<std::string>& defaultValue) {
  if (!fl_map_contains_not_null(map, key)) {
    return defaultValue;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) != FL_VALUE_TYPE_LIST) {
    return defaultValue;
  }
  std::vector<std::string> result;
  size_t len = fl_value_get_length(value);
  result.reserve(len);
  for (size_t i = 0; i < len; i++) {
    FlValue* item = fl_value_get_list_value(value, i);
    if (fl_value_get_type(item) == FL_VALUE_TYPE_STRING) {
      result.push_back(std::string(fl_value_get_string(item)));
    }
  }
  return result;
}

// ============================================================================
// FlValue extraction helpers (get_optional_fl_map_value)
// ============================================================================

template <typename T>
static inline std::optional<T> get_optional_fl_map_value(FlValue* map, const char* key);

// Specialization for bool
template <>
inline std::optional<bool> get_optional_fl_map_value<bool>(FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_BOOL) {
    return std::make_optional(fl_value_get_bool(value));
  }
  return std::nullopt;
}

// Specialization for int64_t
template <>
inline std::optional<int64_t> get_optional_fl_map_value<int64_t>(FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return std::make_optional(fl_value_get_int(value));
  }
  return std::nullopt;
}

// Specialization for int32_t
template <>
inline std::optional<int32_t> get_optional_fl_map_value<int32_t>(FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return std::make_optional(static_cast<int32_t>(fl_value_get_int(value)));
  }
  return std::nullopt;
}

// Specialization for double
template <>
inline std::optional<double> get_optional_fl_map_value<double>(FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_FLOAT) {
    return std::make_optional(fl_value_get_float(value));
  }
  if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
    return std::make_optional(static_cast<double>(fl_value_get_int(value)));
  }
  return std::nullopt;
}

// Specialization for std::string
template <>
inline std::optional<std::string> get_optional_fl_map_value<std::string>(FlValue* map,
                                                                         const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_STRING) {
    return std::make_optional(std::string(fl_value_get_string(value)));
  }
  return std::nullopt;
}

// Specialization for std::vector<std::string>
template <>
inline std::optional<std::vector<std::string>> get_optional_fl_map_value<std::vector<std::string>>(
    FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) != FL_VALUE_TYPE_LIST) {
    return std::nullopt;
  }
  std::vector<std::string> result;
  size_t len = fl_value_get_length(value);
  result.reserve(len);
  for (size_t i = 0; i < len; i++) {
    FlValue* item = fl_value_get_list_value(value, i);
    if (fl_value_get_type(item) == FL_VALUE_TYPE_STRING) {
      result.push_back(std::string(fl_value_get_string(item)));
    }
  }
  return std::make_optional(result);
}

// Specialization for std::vector<uint8_t>
template <>
inline std::optional<std::vector<uint8_t>> get_optional_fl_map_value<std::vector<uint8_t>>(
    FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) == FL_VALUE_TYPE_UINT8_LIST) {
    size_t len = fl_value_get_length(value);
    const uint8_t* data = fl_value_get_uint8_list(value);
    return std::make_optional(std::vector<uint8_t>(data, data + len));
  }
  return std::nullopt;
}

// Specialization for std::map<std::string, std::string>
template <>
inline std::optional<std::map<std::string, std::string>>
get_optional_fl_map_value<std::map<std::string, std::string>>(FlValue* map, const char* key) {
  if (!fl_map_contains_not_null(map, key)) {
    return std::nullopt;
  }
  FlValue* value = fl_value_lookup_string(map, key);
  if (fl_value_get_type(value) != FL_VALUE_TYPE_MAP) {
    return std::nullopt;
  }
  std::map<std::string, std::string> result;
  size_t len = fl_value_get_length(value);
  for (size_t i = 0; i < len; i++) {
    FlValue* map_key = fl_value_get_map_key(value, i);
    FlValue* map_val = fl_value_get_map_value(value, i);
    if (fl_value_get_type(map_key) == FL_VALUE_TYPE_STRING &&
        fl_value_get_type(map_val) == FL_VALUE_TYPE_STRING) {
      result[fl_value_get_string(map_key)] = fl_value_get_string(map_val);
    }
  }
  return std::make_optional(result);
}

// ============================================================================
// FlValue type helpers
// ============================================================================

static inline FlValue* fl_value_lookup_string_safe(FlValue* map, const char* key) {
  if (map == nullptr || fl_value_get_type(map) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  return fl_value_lookup_string(map, key);
}

static inline FlValue* get_fl_map_value_raw(FlValue* map, const char* key) {
  return fl_value_lookup_string_safe(map, key);
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_FLUTTER_H_
