#!/usr/bin/env bash

# Retrieves all dependencies for subdirectories containing a pubspec.yaml file.
get_dependencies() {
  cd ..
  printf "\nGetting dependencies in all subdirectories with pubspec.yaml file...\n"
  for dir in $(grep -lZr --include="pubspec.yaml" "" . | grep -v -E -z "./build/|./.pub-cache/" | xargs -0 -I {} dirname {}); do
    printf "\nGetting dependencies in %s\n" "$dir"
    cd "$dir" || return
    flutter pub get
    cd - >/dev/null || return
  done
}

get_dependencies
