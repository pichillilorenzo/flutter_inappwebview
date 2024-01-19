#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_STRING_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_STRING_H_

#include <optional>
#include <string>

#include "strconv.h"

namespace flutter_inappwebview_plugin
{
  template <typename T>
  struct is_string
    : std::false_type
  {};

  // Partial specialization - parameters used to qualify the specialization
  template <typename CharT, typename TraitsT, typename AllocT>
  struct is_string<std::basic_string<CharT, TraitsT, AllocT>>
    : std::true_type
  {};

  template <typename T>
  using is_basic_string = is_string<std::remove_cv_t<T>>;

  template <typename T>
  static inline bool string_equals(const std::basic_string<T>& s1, const std::basic_string<T>& s2)
  {
    return s1.compare(s2) == 0;
  }

  template <typename T>
  static inline bool string_equals(const std::basic_string<T>& s1, const char* s2)
  {
    return s1.compare(s2) == 0;
  }

  template <typename T>
  static inline bool string_equals(const char* s1, const std::basic_string<T>& s2)
  {
    return s2.compare(s1) == 0;
  }

  static inline bool string_equals(const std::string& s1, const std::wstring& s2)
  {
    return string_equals(s1, wide_to_ansi(s2));
  }

  static inline bool string_equals(const std::wstring& s1, const std::string& s2)
  {
    return string_equals(wide_to_ansi(s1), s2);
  }

  template <typename T>
  static inline bool string_equals(const std::optional<std::basic_string<T>>& s1, const std::basic_string<T>& s2)
  {
    return s1.has_value() ? string_equals(s1.value(), s2) : false;
  }

  template <typename T>
  static inline bool string_equals(const std::basic_string<T>& s1, const std::optional<std::basic_string<T>>& s2)
  {
    return s2.has_value() ? string_equals(s1, s2.value()) : false;
  }

  template <typename T>
  static inline bool string_equals(const std::optional<std::basic_string<T>>& s1, const std::optional<std::basic_string<T>>& s2)
  {
    return s1.has_value() && s2.has_value() ? string_equals(s1.value(), s2.value()) : true;
  }

  static inline void replace_all(std::string& source, const std::string& from, const std::string& to)
  {
    std::string newString;
    newString.reserve(source.length());  // avoids a few memory allocations

    std::string::size_type lastPos = 0;
    std::string::size_type findPos;

    while (std::string::npos != (findPos = source.find(from, lastPos))) {
      newString.append(source, lastPos, findPos - lastPos);
      newString += to;
      lastPos = findPos + from.length();
    }

    // Care for the rest after last occurrence
    newString += source.substr(lastPos);

    source.swap(newString);
  }

  static inline std::string replace_all_copy(const std::string& source, const std::string& from, const std::string& to)
  {
    std::string newString;
    newString.reserve(source.length());  // avoids a few memory allocations

    std::string::size_type lastPos = 0;
    std::string::size_type findPos;

    while (std::string::npos != (findPos = source.find(from, lastPos))) {
      newString.append(source, lastPos, findPos - lastPos);
      newString += to;
      lastPos = findPos + from.length();
    }

    // Care for the rest after last occurrence
    newString += source.substr(lastPos);

    return newString;
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_STRING_H_