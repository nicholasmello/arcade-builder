#!/bin/sh

set -u
set -e

BOARD_DIR="$(dirname "$0")"

cp -r "${BOARD_DIR}"/custom-skeleton/ "${TARGET_DIR}"
