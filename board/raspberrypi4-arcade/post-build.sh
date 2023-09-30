#!/bin/sh

set -u
set -e

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
FSTAB_LOCATION="${BOARD_DIR}/fstab"

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# exnsure overlays exists for genimage
mkdir -p "${BINARIES_DIR}/rpi-firmware/overlays"

cp ${FSTAB_LOCATION} ${TARGET_DIR}/etc/fstab
