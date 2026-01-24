#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_CALLBACK_RESULT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_CALLBACK_RESULT_H_

#include <flutter_linux/flutter_linux.h>

#include <functional>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Base class for async callback results from Flutter method invocations.
 * This mirrors the Windows BaseCallbackResult pattern, adapted for FlValue.
 *
 * Template parameter T is the decoded result type.
 *
 * Usage:
 * 1. Create a subclass and set decodeResult in the constructor
 * 2. Optionally set nonNullSuccess/nullSuccess to return whether default
 *    behaviour should run
 * 3. Optionally set defaultBehaviour to run when no specific handling is done
 * 4. Call handleResult() when the async response arrives
 */
template <typename T>
class BaseCallbackResult {
 public:
  /**
   * Error handler - called when an error response is received.
   */
  std::function<void(const std::string& code, const std::string& message)> error;

  /**
   * Not implemented handler - called when method is not implemented.
   */
  std::function<void()> notImplemented;

  /**
   * Called when result is non-null.
   * Returns true if defaultBehaviour should run.
   */
  std::function<bool(const T result)> nonNullSuccess = [](const T) { return true; };

  /**
   * Called when result is null.
   * Returns true if defaultBehaviour should run.
   */
  std::function<bool()> nullSuccess = []() { return true; };

  /**
   * Default behaviour to run after success handling.
   */
  std::function<void(const std::optional<T> result)> defaultBehaviour = [](const std::optional<T>) {
  };

  /**
   * Decode the FlValue result into type T.
   * Must be set by subclasses.
   */
  std::function<std::optional<T>(FlValue* result)> decodeResult = [](FlValue*) {
    return std::nullopt;
  };

  BaseCallbackResult() = default;
  virtual ~BaseCallbackResult() = default;

  /**
   * Handle the async result from Flutter.
   * This should be called from the GAsyncReadyCallback.
   */
  void handleResult(FlValue* value) {
    std::optional<T> result = decodeResult ? decodeResult(value) : std::nullopt;
    bool shouldRunDefaultBehaviour = false;

    if (result.has_value()) {
      shouldRunDefaultBehaviour =
          nonNullSuccess ? nonNullSuccess(result.value()) : shouldRunDefaultBehaviour;
    } else {
      shouldRunDefaultBehaviour = nullSuccess ? nullSuccess() : shouldRunDefaultBehaviour;
    }

    if (shouldRunDefaultBehaviour && defaultBehaviour) {
      defaultBehaviour(result);
    }
  }

  /**
   * Handle an error result.
   */
  void handleError(const std::string& code, const std::string& message) {
    if (error) {
      error(code, message);
    }
  }

  /**
   * Handle not implemented response.
   */
  void handleNotImplemented() {
    if (defaultBehaviour) {
      defaultBehaviour(std::nullopt);
    }
    if (notImplemented) {
      notImplemented();
    }
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_BASE_CALLBACK_RESULT_H_
