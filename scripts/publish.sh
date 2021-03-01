#!/bin/bash

readonly SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
readonly PROJECT_DIR="$(dirname $SCRIPT_PATH)"

cd $PROJECT_DIR/lib
dartfmt -w .

cd $PROJECT_DIR
flutter analyze
flutter pub publish --dry-run
flutter pub publish