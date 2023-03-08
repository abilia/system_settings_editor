#!/usr/bin/env bash

# Tests all subdirectories containing a pubspec.yaml file.
test_all() {
  cd ..
  printf "\nTesting all subdirectories with pubspec.yaml file...\n"
  for dir in $(grep -lZr --include="pubspec.yaml" "" . | grep -v -E -z "./build/|./.pub-cache/" | xargs -0 -I {} dirname {}); do
    printf "\nTesting %s\n" "$dir"
    cd "$dir" || return
    flutter test
    cd - >/dev/null || return
  done
}

test_all
