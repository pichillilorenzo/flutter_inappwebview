#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_VECTOR_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_VECTOR_H_

#include <algorithm>
#include <iterator>
#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin
{
  template<typename T = void, typename = void>
  struct is_vector_impl : std::false_type { };

  template<typename T>
  struct is_vector_impl<T, std::enable_if_t<
    std::is_same<T, typename std::vector<std::string>>::value>
  > : std::true_type { };

  template<typename T>
  struct is_vector_impl<T, std::enable_if_t<
    std::is_same<T, typename std::vector<typename std::iterator_traits<T>::value_type>::iterator>::value>
  > : std::true_type { };

  template<typename T>
  struct is_vector : is_vector_impl<T>::type { };

  template <typename T>
  static inline void vector_remove_el(std::vector<T>& vec, const T& el)
  {
    std::remove(vec.begin(), vec.end(), el);
  }

  template <typename T>
  static inline void vector_remove_erase_el(std::vector<T>& vec, const T& el)
  {
    vec.erase(std::remove(vec.begin(), vec.end(), el), vec.end());
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_LOG_VECTOR_H_