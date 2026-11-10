#include <exception>
#include <iostream>

#include "browser_process_gate_test_cases.h"

int main()
{
  using namespace flutter_inappwebview_plugin::test::browser_process_gate_test;
  try {
    responsiveOwnersOutlivePendingWork();
    closingOnePreservesSharedRetry();
    lastOwnerCancelsAndReleasesCaches();
    timeoutRetainsOwnership();
    pidReuseRequiresFreshProbe();
    movingOwnerPreservesOtherOwners();
    processFailurePreservesOtherOwners();
    drainedWaitersRecheckOwnership();
    releaseHooksObserveConsistentOwnership();
    retryCancellationCanReleaseLastOwner();
    repeatedCloseReleasesBookkeeping();
  }
  catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
  std::cout << "Browser process gate: all 11 cases passed (1,000 close cycles)\n";
}
