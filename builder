#!/bin/bash

TARGET_LIST=("rpi4-arcade" "rpi4-debugger")
TARGET_BOARD=$2
mkdir -p "${PWD}/../builds/"
BUILD_DIR="$(builtin cd "${PWD}/../builds/"; pwd)"
BUILDROOT_VERSION="buildroot-2023.02.3"

usage() {
	echo "Usage: $0 <command> <target>"
	echo ""
	echo "Commands: setup build"
	echo "Targets: ${TARGET_LIST[*]}"
}

setup() {
	echo "Verifying validity of target..."
	if ! [[ " ${TARGET_LIST[@]} " =~ " ${TARGET_BOARD} "  ]]; then
		usage
		exit 1
	fi
	CONFIG_FILE="configs/${TARGET_BOARD}.buildercfg"
	if [ ! -f "${CONFIG_FILE}" ]; then
		echo "Unable to find build configuration file: ${CONFIG_FILE}"
	fi

	echo "Setting up buildroot environment..."
	if [ ! -d "${BUILD_DIR}/${BUILDROOT_VERSION}" ]; then
		FILE_NAME=${BUILD_DIR}/${BUILDROOT_VERSION}.tar.gz
		wget -O ${FILE_NAME} https://buildroot.org/downloads/${BUILDROOT_VERSION}.tar.gz
		cd ${BUILD_DIR}
		tar xvzf ${FILE_NAME}
		rm -rf ${FILE_NAME}
	fi
	cp -r ${BUILD_DIR}/${BUILDROOT_VERSION} ${BUILD_DIR}/${TARGET_BOARD}

	echo "Setting up configuration file..."
	DEF_CONFIG_FILE_NAME="${TARGET_BOARD//-/_}_defconfig"
	DEF_CONFIG="${BUILD_DIR}/${TARGET_BOARD}/configs/${DEF_CONFIG_FILE_NAME}"
	rm -rf ${DEF_CONFIG}
	touch ${DEF_CONFIG}
	while read partconfig; do
		cat partials/$partconfig >> ${DEF_CONFIG}
	done < $CONFIG_FILE
	(cd ${BUILD_DIR}/${TARGET_BOARD} && make ${DEF_CONFIG_FILE_NAME})

	echo "Build successfully setup"
}

build() {
	setup
	echo "Starting build..."
	(cd ${BUILD_DIR}/${TARGET_BOARD} && make all)
	echo "Done"
}

case $1 in
	setup)
		setup
		;;
	build)
		build
		;;
	*)
		usage
		;;
esac
