#!/bin/bash

readonly SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
readonly PROJECT_DIR="$(dirname $SCRIPT_PATH)"

function error() {
  echo "$@" 1>&2
}

# on macOS local IP can be found using something like $(ipconfig getifaddr en0)
# on linux local IP can be found using something like $(ifconfig en0 | grep "inet " | grep -Fv 127.0.0.1 | awk '{print $2}') or $(ip route get 1 | awk '{print $NF;exit}')
export NODE_SERVER_IP=$1
if [ -z "$1" ]; then
  export NODE_SERVER_IP=$(ipconfig getifaddr en0)
fi

echo Node Server IP: $NODE_SERVER_IP

if [ -z "$NODE_SERVER_IP" ]; then
  echo No Server IP found
  jobs -p | xargs kill
  exit 1
fi

DEVICE_ID=$2
FAILED=0

if [ ! -z "$2" ] && [ $DEVICE_ID = "chrome" ]; then
  $PROJECT_DIR/tool/chromedriver --port=4444 &
fi

dart $PROJECT_DIR/tool/env.dart

cd $PROJECT_DIR/test_node_server
node index.js &

# Only for Android
# Open Chrome on the development device, navigate to chrome://flags, search for an item called Enable command line on non-rooted devices and change it to ENABLED and then restart the browser.
adb shell "echo '_ --disable-digital-asset-link-verification-for-url=\"https://flutter.dev\"' > /data/local/tmp/chrome-command-line" || true

flutter --version
flutter devices
flutter clean
flutter pub get
cd $PROJECT_DIR/flutter_inappwebview/example
flutter clean
if [ ! -z "$2" ]; then
  flutter driver --driver=test_driver/integration_test.dart --target=integration_test/webview_flutter_test.dart --device-id=$DEVICE_ID
else
  flutter driver --driver=test_driver/integration_test.dart --target=integration_test/webview_flutter_test.dart
fi

if [ $? -eq 0 ]; then
  echo "Integration tests passed successfully."
else
  error "Some integration tests failed."
  FAILED=1
fi

jobs -p | xargs kill

exit $FAILED