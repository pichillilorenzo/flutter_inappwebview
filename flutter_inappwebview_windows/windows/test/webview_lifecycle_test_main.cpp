#include <exception>
#include <iostream>
#include "webview_lifecycle_test_cases.h"

int main()
{
  using namespace flutter_inappwebview_plugin::test::webview_lifecycle_test;
  try {
    waitsForSuspendCallback();
    successfulHresultCanRejectSuspend();
    failedHresultCannotConfirmSuspend();
    resumePreemptsPauseWaitingAtGate();
    lateSuspendSuccessRequiresCorrectiveResume();
    lateRefusalDoesNotResumeAgain();
    rapidPauseResumePausePreservesNewestRequest();
    duplicatePausesWaitForOneNativeOperation();
    timeoutBeforeDispatchClearsPendingWork();
    timeoutDuringSuspendIgnoresLateSuccess();
    lostCallbackCanRecoverAfterSuccessfulResume();
    retiredCompletionCanResumeOnlyOnce();
    failedResumeDoesNotRetirePendingSuspend();
    disposalCompletesAndPreventsLateAccess();
    visibilityOrResumeFailureCannotSucceed();
    independentViewsNeverCancelEachOther();
    completionCanStartAnotherRequest();
    repeatedLifecyclesReleaseReplyOwners();
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "WebView lifecycle: all 18 cases passed\n";
}
