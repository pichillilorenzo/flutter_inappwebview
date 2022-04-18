#!/bin/bash

readonly SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
readonly PROJECT_DIR="$(dirname $SCRIPT_PATH)"

$SCRIPT_PATH/test.sh $1 2>&1 | tee $PROJECT_DIR/flutter_driver_tests.log

kill $(jobs -p)