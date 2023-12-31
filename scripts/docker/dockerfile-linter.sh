#!/bin/bash
# shellcheck disable=SC1091

# WARNING: Please, DO NOT edit this file! It is maintained in the Repository Template (https://github.com/nhs-england-tools/repository-template). Raise a PR instead.

set -euo pipefail

# Dockerfile linter.
#
# Usage:
#   $ ./dockerfile-linter.sh
#
# Arguments (provided as environment variables):
#   file=Dockerfile   # Path to the Dockerfile to lint, relative to the project top-level directory, default is './Dockerfile.effective'
#   VERBOSE=true      # Show all the executed commands, default is 'false'

# ==============================================================================

function main() {

  cd "$(git rev-parse --show-toplevel)"
  local file=${file:-$PWD/Dockerfile.effective}
  source ./scripts/docker/docker.lib.sh
  docker-run-hadolint
}

function docker-run-hadolint() {

  image=$(name=hadolint/hadolint docker-get-image-version-and-pull)
  # shellcheck disable=SC2001
  docker run --rm --platform linux/amd64 \
    --volume "$PWD:/workdir" \
    "$image" \
      hadolint \
        --config /workdir/scripts/config/hadolint.yaml \
        "/workdir/$(echo "$file" | sed "s#$PWD/##")"
}

# ==============================================================================

function is_arg_true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is_arg_true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
