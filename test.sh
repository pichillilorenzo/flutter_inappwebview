#!/bin/bash
export NODE_SERVER_IP=$1
dart tool/env.dart
cd nodejs_server_test_auth_basic_and_ssl
node index.js &
cd ../example
flutter driver -t test_driver/app.dart
kill $(jobs -p)