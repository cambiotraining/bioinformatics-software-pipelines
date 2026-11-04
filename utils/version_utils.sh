#!/bin/bash

# Supports scalar version values in the two-space-indented `version:` map.
VERSION_FILE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)/_variables.yml"

get_version() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: get_version <key>" >&2
    return 1
  fi

  if [ ! -f "$VERSION_FILE" ]; then
    echo "Version manifest not found: $VERSION_FILE" >&2
    return 1
  fi

  local key="$1"
  local value

  value=$(
    awk -v key="$key" '
      $0 == "version:" {
        in_version = 1
        next
      }
      in_version && /^[^[:space:]#]/ {
        exit
      }
      in_version && $0 ~ "^  " key ":[[:space:]]*" {
        value = $0
        sub("^  " key ":[[:space:]]*", "", value)
        sub(/[[:space:]]+#.*$/, "", value)
        count++
      }
      END {
        if (count == 1 && value != "") {
          print value
          exit 0
        }
        exit 1
      }
    ' "$VERSION_FILE"
  ) || {
    echo "Version key not found or invalid in $VERSION_FILE: $key" >&2
    return 1
  }

  printf '%s\n' "$value"
}
