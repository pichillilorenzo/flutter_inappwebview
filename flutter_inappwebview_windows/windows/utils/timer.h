#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_TIMER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_TIMER_H_

#include <functional>
#include <map>
#include <Shlwapi.h>

#include "map.h"

namespace flutter_inappwebview_plugin
{
  class Timer {
  public:
    static UINT_PTR setTimeout(std::function<void()> callback, uint32_t delay)
    {
      auto timerId = SetTimer(NULL, 0, delay, (TIMERPROC)&Timer::timerCallback_);
      // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-settimer#return-value
      if (timerId != 0) {
        timeoutCallbacks_[timerId] = callback;
      }
      return timerId;
    }

    static UINT_PTR setInterval(std::function<void()> callback, uint32_t delay)
    {
      auto timerId = SetTimer(NULL, 0, delay, (TIMERPROC)&Timer::timerCallback_);
      // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-settimer#return-value
      if (timerId != 0) {
        intervalCallbacks_[timerId] = callback;
      }
      return timerId;
    }

    static bool clearTimeout(UINT_PTR timerId)
    {
      if (map_contains(timeoutCallbacks_, timerId)) {
        timeoutCallbacks_.erase(timerId);
        return (bool)KillTimer(NULL, timerId);
      }
      return false;
    }

    static bool clearInterval(UINT_PTR timerId)
    {
      if (map_contains(intervalCallbacks_, timerId)) {
        intervalCallbacks_.erase(timerId);
        return (bool)KillTimer(NULL, timerId);
      }
      return false;
    }
  private:
    static inline std::map<UINT_PTR, std::function<void()>> timeoutCallbacks_ = {};
    static inline std::map<UINT_PTR, std::function<void()>> intervalCallbacks_ = {};
    static void CALLBACK timerCallback_(HWND hwnd, UINT uMsg, UINT_PTR timerId, DWORD dwTime)
    {
      if (map_contains(timeoutCallbacks_, timerId)) {
        timeoutCallbacks_.at(timerId)();
        clearTimeout(timerId);
      }
      else if (map_contains(intervalCallbacks_, timerId)) {
        intervalCallbacks_.at(timerId)();
      }
      else {
        KillTimer(NULL, timerId);
      }
    }
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_TIMER_H_