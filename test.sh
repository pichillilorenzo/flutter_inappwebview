#!/bin/bash

function error() {
  echo "$@" 1>&2
}

# on linux/macOS local IP can be found using $(ipconfig getifaddr en0)
export NODE_SERVER_IP=$1
FAILED=0

dart tool/env.dart

cd nodejs_server_test_auth_basic_and_ssl
node index.js &

flutter clean
cd ../example
flutter clean
flutter driver --driver=test_driver/integration_test.dart --target=integration_test/webview_flutter_test.dart

if [ $? -eq 0 ]; then
  echo "Integration tests passed successfully."
else
  error "Some integration tests failed."
  FAILED=1
fi

kill $(jobs -p)

exit $FAILED