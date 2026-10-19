#pragma once

#include <functional>
#include <memory>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include "../types/one_shot_callback.h"

namespace flutter_inappwebview_plugin::test
{
  namespace
  {
    inline void requireOneShotTest(bool condition, const char* message)
    {
      if (!condition) {
        throw std::runtime_error(message);
      }
    }

    struct CopyCountedPayload
    {
      std::vector<int> values;
      int* copyCount;

      CopyCountedPayload(const std::size_t size, int* copyCount)
        : values(size, 42), copyCount(copyCount)
      {}

      CopyCountedPayload(const CopyCountedPayload& other)
        : values(other.values), copyCount(other.copyCount)
      {
        ++*copyCount;
      }

      CopyCountedPayload(CopyCountedPayload&&) noexcept = default;
    };
  }

  inline void runOneShotCallbackFailureTest()
  {
    int payloadCopies = 0;
    CopyCountedPayload payload(10000, &payloadCopies);
    auto failureStage = std::make_shared<std::string>();
    int callbackCount = 0;
    int receivedError = 0;
    std::size_t receivedPayloadSize = 0;
    std::string observedStage;

    std::function<void(int)> completionHandler = [payload, failureStage, &callbackCount,
      &receivedError, &receivedPayloadSize, &observedStage](const int errorCode) {
        ++callbackCount;
        receivedError = errorCode;
        receivedPayloadSize = payload.values.size();
        observedStage = *failureStage;
      };
    using Completion = OneShotCallback<decltype(completionHandler)>;
    auto completion = std::make_shared<Completion>(std::move(completionHandler));
    auto fail = [completion, failureStage](const int errorCode, const char* stage) {
      completion->invokeWithFailureStage(failureStage, stage, errorCode);
    };
    std::function<void(int)> controllerCallback = [completion, fail](const int errorCode) {
      if (errorCode != 0) {
        fail(errorCode, "CreateCoreWebView2ControllerWithOptions");
      }
      else {
        completion->invoke(errorCode);
      }
    };

    requireOneShotTest(payloadCopies == 1,
      "moving callback into shared completion or wrapping it copied its payload");
    controllerCallback(5);
    requireOneShotTest(callbackCount == 1, "failure callback did not run exactly once");
    requireOneShotTest(receivedError == 5, "failure HRESULT was not propagated");
    requireOneShotTest(receivedPayloadSize == 10000, "delayed callback lost its captured payload");
    requireOneShotTest(observedStage == "CreateCoreWebView2ControllerWithOptions",
      "failure stage was not published before invoking the callback");

    controllerCallback(0);
    requireOneShotTest(callbackCount == 1, "late success completed the callback twice");
    requireOneShotTest(*failureStage == "CreateCoreWebView2ControllerWithOptions",
      "late success replaced the original failure stage");
  }

  inline void runOneShotCallbackSuccessTest()
  {
    int callbackCount = 0;
    int receivedError = -1;
    OneShotCallback<std::function<void(int)>> completion(
      [&callbackCount, &receivedError](const int errorCode) {
        ++callbackCount;
        receivedError = errorCode;
      });

    requireOneShotTest(completion.invoke(0), "success completion was rejected");
    requireOneShotTest(!completion.invoke(5), "duplicate success was accepted");
    requireOneShotTest(callbackCount == 1 && receivedError == 0,
      "success callback did not run exactly once");
  }

  inline void runOneShotCallbackWithoutFailureStageTest()
  {
    int callbackCount = 0;
    int receivedError = 0;
    std::shared_ptr<std::string> noFailureStage;
    OneShotCallback<std::function<void(int)>> completion(
      [&callbackCount, &receivedError](const int errorCode) {
        ++callbackCount;
        receivedError = errorCode;
      });

    requireOneShotTest(completion.invokeWithFailureStage(noFailureStage, "ignored stage", 5),
      "completion with an omitted failure stage was rejected");
    requireOneShotTest(callbackCount == 1 && receivedError == 5,
      "completion with an omitted failure stage did not propagate the error");
  }

  inline void runOneShotCallbackTests()
  {
    runOneShotCallbackFailureTest();
    runOneShotCallbackSuccessTest();
    runOneShotCallbackWithoutFailureStageTest();
  }
}
