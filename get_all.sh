#!/bin/bash

execute_command() {
  cd "$1" || exit 1
  echo "Executing command in: $(pwd)"
  flutter pub get
  cd - >/dev/null
}

while IFS= read -r -d '' dir; do
  execute_command "$(dirname "$dir")"
done < <(find . -type f -name "pubspec.yaml" -print0)
