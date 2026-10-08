#!/usr/bin/env bash
set -euo pipefail

readonly KCOV_BIN=${KCOV_BIN:-/usr/local/bin/kcov}

main() {
  local -a kcov_args=()
  local argument

  for argument in "$@"; do
    case $argument in
      --bash-parse-files-in-dir=.)
        kcov_args+=("--bash-parse-files-in-dir=.,scripts")
        ;;
      *)
        kcov_args+=("$argument")
        ;;
    esac
  done

  exec "$KCOV_BIN" "${kcov_args[@]}"
}

main "$@"

