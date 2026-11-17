#pragma once

// Narrow COM doubles for the production-source harness. The Windows CI build
// still compiles the plugin against the real WebView2, WIL and Flutter headers.
#include <atomic>
#include <cstdint>
#include <functional>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

using HRESULT = int32_t;
using UINT = uint32_t;
using INT32 = int32_t;
using BOOL = int32_t;
constexpr BOOL FALSE = 0;
constexpr HRESULT S_OK = 0;
constexpr HRESULT E_FAIL = static_cast<HRESULT>(0x80004005u);
constexpr HRESULT E_NOINTERFACE = static_cast<HRESULT>(0x80004002u);
constexpr HRESULT E_POINTER = static_cast<HRESULT>(0x80004003u);
constexpr HRESULT E_UNEXPECTED = static_cast<HRESULT>(0x8000ffffu);
constexpr HRESULT E_ACCESSDENIED = static_cast<HRESULT>(0x80070005u);
inline bool SUCCEEDED(HRESULT hr) { return hr >= 0; }
inline bool FAILED(HRESULT hr) { return hr < 0; }
inline bool succeededOrLog(HRESULT hr) { return SUCCEEDED(hr); }
#define IID_PPV_ARGS(value) value

struct TestComObject {
  inline static int live = 0;
  std::atomic<int> refs{1};
  TestComObject() { ++live; }
  virtual ~TestComObject() { --live; }
  void AddRef() { ++refs; }
  void Release() { if (--refs == 0) delete this; }
};

namespace wil {
template <typename T> class com_ptr {
 public:
  com_ptr() = default;
  com_ptr(std::nullptr_t) {}
  com_ptr(T* value) : value_(value) { if (value_) value_->AddRef(); }
  com_ptr(const com_ptr& other) : com_ptr(other.value_) {}
  com_ptr(com_ptr&& other) noexcept : value_(std::exchange(other.value_, nullptr)) {}
  ~com_ptr() { if (value_) value_->Release(); }
  com_ptr& operator=(com_ptr other) noexcept {
    std::swap(value_, other.value_);
    return *this;
  }
  T* get() const { return value_; }
  T* operator->() const { return value_; }
  explicit operator bool() const { return value_ != nullptr; }
  T** operator&() {
    if (value_) value_->Release();
    value_ = nullptr;
    return &value_;
  }
  void attach(T* value) {
    if (value_) value_->Release();
    value_ = value;
  }
  template <typename U> com_ptr<U> try_query() const {
    com_ptr<U> result;
    if (value_) value_->QueryInterface(&result);
    return result;
  }
 private:
  T* value_ = nullptr;
};
}

template <typename T, typename... Args> wil::com_ptr<T> makeCom(Args&&... args) {
  wil::com_ptr<T> result;
  result.attach(new T(std::forward<Args>(args)...));
  return result;
}
template <typename T> void copyCom(const wil::com_ptr<T>& source, T** target) {
  *target = source.get();
  if (*target) (*target)->AddRef();
}

enum COREWEBVIEW2_PROCESS_KIND { BROWSER = 0, RENDERER = 1, UTILITY = 2, GPU = 4 };
struct ICoreWebView2ProcessInfo : TestComObject {
  HRESULT kindError = S_OK, pidError = S_OK;
  COREWEBVIEW2_PROCESS_KIND kind = RENDERER;
  INT32 pid = 42;
  HRESULT get_Kind(COREWEBVIEW2_PROCESS_KIND* value) {
    if (SUCCEEDED(kindError)) *value = kind;
    return kindError;
  }
  HRESULT get_ProcessId(INT32* value) {
    if (SUCCEEDED(pidError)) *value = pid;
    return pidError;
  }
};

struct ICoreWebView2FrameInfo : TestComObject {};
struct ICoreWebView2FrameInfoCollectionIterator : TestComObject {
  wil::com_ptr<ICoreWebView2FrameInfo> current;
  HRESULT get_HasCurrent(BOOL* value) { *value = current ? 1 : 0; return S_OK; }
  HRESULT GetCurrent(ICoreWebView2FrameInfo** value) {
    copyCom(current, value); return S_OK;
  }
};
struct ICoreWebView2FrameInfoCollection : TestComObject {
  HRESULT error = S_OK;
  wil::com_ptr<ICoreWebView2FrameInfoCollectionIterator> iterator;
  HRESULT GetIterator(ICoreWebView2FrameInfoCollectionIterator** value) {
    if (SUCCEEDED(error)) copyCom(iterator, value);
    return error;
  }
};
struct ICoreWebView2ProcessExtendedInfo : TestComObject {
  HRESULT infoError = S_OK, framesError = S_OK;
  wil::com_ptr<ICoreWebView2ProcessInfo> info = makeCom<ICoreWebView2ProcessInfo>();
  wil::com_ptr<ICoreWebView2FrameInfoCollection> frames;
  HRESULT get_ProcessInfo(ICoreWebView2ProcessInfo** value) {
    if (SUCCEEDED(infoError)) copyCom(info, value);
    return infoError;
  }
  HRESULT get_AssociatedFrameInfos(ICoreWebView2FrameInfoCollection** value) {
    if (SUCCEEDED(framesError)) copyCom(frames, value);
    return framesError;
  }
};

template <typename T> struct ProcessCollection : TestComObject {
  HRESULT countError = S_OK, itemError = E_ACCESSDENIED;
  std::optional<UINT> failingIndex;
  std::vector<wil::com_ptr<T>> items;
  HRESULT get_Count(UINT* value) {
    if (SUCCEEDED(countError)) *value = static_cast<UINT>(items.size());
    return countError;
  }
  HRESULT GetValueAtIndex(UINT index, T** value) {
    if (failingIndex == index) return itemError;
    copyCom(items.at(index), value);
    return S_OK;
  }
};
struct ICoreWebView2ProcessInfoCollection : ProcessCollection<ICoreWebView2ProcessInfo> {};
struct ICoreWebView2ProcessExtendedInfoCollection : ProcessCollection<ICoreWebView2ProcessExtendedInfo> {};

struct ICoreWebView2GetProcessExtendedInfosCompletedHandler : TestComObject {
  using Function = std::function<HRESULT(HRESULT, wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection>)>;
  explicit ICoreWebView2GetProcessExtendedInfosCompletedHandler(Function callback)
    : callback(std::move(callback)) {}
  Function callback;
  HRESULT Invoke(HRESULT error, ICoreWebView2ProcessExtendedInfoCollection* collection) {
    return callback(error, collection);
  }
};
namespace Microsoft::WRL {
template <typename T> struct CallbackOwner {
  wil::com_ptr<T> value;
  T* Get() const { return value.get(); }
};
template <typename T, typename F> CallbackOwner<T> Callback(F callback) {
  return { makeCom<T>(std::move(callback)) };
}
}

struct ICoreWebView2Environment8 : TestComObject {
  int requests = 0;
  HRESULT error = S_OK;
  wil::com_ptr<ICoreWebView2ProcessInfoCollection> collection;
  HRESULT GetProcessInfos(ICoreWebView2ProcessInfoCollection** value) {
    ++requests;
    if (SUCCEEDED(error)) copyCom(collection, value);
    return error;
  }
};
struct ICoreWebView2Environment13 : TestComObject {
  int requests = 0;
  HRESULT startError = S_OK, inlineError = S_OK;
  bool completeInline = false;
  wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection> inlineCollection;
  wil::com_ptr<ICoreWebView2GetProcessExtendedInfosCompletedHandler> pending;
  HRESULT GetProcessExtendedInfos(ICoreWebView2GetProcessExtendedInfosCompletedHandler* callback) {
    ++requests;
    pending = callback;
    if (completeInline) complete(inlineError, inlineCollection);
    return startError;
  }
  void complete(HRESULT error, const wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection>& collection) {
    if (!pending) throw std::runtime_error("no pending native callback");
    pending->Invoke(error, collection.get());
  }
};
struct ICoreWebView2Environment : TestComObject {
  std::optional<HRESULT> query8Error, query13Error;
  wil::com_ptr<ICoreWebView2Environment8> basic;
  wil::com_ptr<ICoreWebView2Environment13> extended;
  HRESULT QueryInterface(ICoreWebView2Environment8** value) {
    const auto hr = query8Error.value_or(basic ? S_OK : E_NOINTERFACE);
    if (SUCCEEDED(hr)) copyCom(basic, value);
    return hr;
  }
  HRESULT QueryInterface(ICoreWebView2Environment13** value) {
    const auto hr = query13Error.value_or(extended ? S_OK : E_NOINTERFACE);
    if (SUCCEEDED(hr)) copyCom(extended, value);
    return hr;
  }
};

// Serialization and frame metadata are unrelated to process enumeration; the
// harness runs the production process converters and stubs only their leaf type.
namespace flutter { struct EncodableMap {}; }
namespace flutter_inappwebview_plugin {
struct FrameInfo {
  static std::unique_ptr<FrameInfo> fromICoreWebView2FrameInfo(
    const wil::com_ptr<ICoreWebView2FrameInfo>) {
    return std::make_unique<FrameInfo>();
  }
};
}
