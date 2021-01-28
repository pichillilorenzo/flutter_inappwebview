#!/bin/bash
# flutter clean && flutter run -t ./lib/main.dart -d 'iPhone di Lorenzo' --debug --no-sound-null-safety

# on linux/macOS local IP can be found using $(ipconfig getifaddr en0)
export NODE_SERVER_IP=$1
dart tool/env.dart
cd nodejs_server_test_auth_basic_and_ssl
node index.js &
flutter clean
cd ../example
flutter clean
flutter driver --driver=test_driver/integration_test.dart --target=integration_test/webview_flutter_test.dart
kill $(jobs -p)