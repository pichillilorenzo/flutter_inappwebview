#!/bin/bash
# on linux/macOS local IP can be found using $(ipconfig getifaddr en0)
export NODE_SERVER_IP=$1
dart tool/env.dart
cd nodejs_server_test_auth_basic_and_ssl
node index.js &
flutter clean
cd ../example
flutter clean
flutter driver -t test_driver/app.dart
kill $(jobs -p)