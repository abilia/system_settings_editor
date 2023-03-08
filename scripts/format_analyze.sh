#!/usr/bin/env bash

# Formats and analyzes all subdirectories containing a pubspec.yaml file.
format_analyze() {
  cd ..
  printf "\nFormatting and analyzing all subdirectories with pubspec.yaml file...\n"
  for dir in $(grep -lZr --include="pubspec.yaml" "" . | grep -v -E -z "./build/|./.pub-cache/" | xargs -0 -I {} dirname {}); do
    printf "\nFormatting and analyzing %s\n" "$dir"
    cd "$dir" || return
    dart format .
    flutter analyze .
    cd - >/dev/null || return
  done
}

format_analyze
