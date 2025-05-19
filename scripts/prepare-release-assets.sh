#!/usr/bin/env bash

set -o errexit # exit immediately if a command exits with a non-zero status.
set -o nounset # exit when script tries to use undeclared variables

readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

function prepareAssets() {
          destination=_dist/

          echo "Copy files"

          mkdir -p _dist

          # do not fail if there is no .md file
          cp addons/*.md ${destination} 2>/dev/null || true
          cp addons/*.yaml ${destination}

          echo "Executing targz"
          scripts/targz.sh addons/ ${destination}

          echo "Processing done"
          echo
}

prepareAssets