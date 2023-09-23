#!/bin/bash

TARGET_LIST=("rpi4-arcade-min" "rpi4-arcade" "rpi4-arcade-dev")
TARGET_BOARD=$2
mkdir -p "${PWD}/../builds/"
SETUP_DIR="${PWD}"
BUILD_DIR="$(builtin cd "${PWD}/../builds/"; pwd)"
BUILDROOT_VERSION="buildroot-2023.02.3"

usage() {
	echo "Usage: $0 <command> <target>"
	echo ""
	echo "Commands: setup build"
	echo "Targets: ${TARGET_LIST[*]}"
}

setup() {
	BUILD_TARGET_DIR=${BUILD_DIR}/${TARGET_BOARD}

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
	BUILDROOT_DIR=${BUILD_DIR}/${BUILDROOT_VERSION}
	if [ ! -d "${BUILDROOT_DIR}" ]; then
		FILE_NAME=${BUILDROOT_DIR}.tar.gz
		wget -O ${FILE_NAME} https://buildroot.org/downloads/${BUILDROOT_VERSION}.tar.gz
		cd ${BUILD_DIR}
		tar xvzf ${FILE_NAME}
		rm -rf ${FILE_NAME}
	fi
	if [ ! -d "${BUILD_TARGET_DIR}" ]; then
		cp -r ${BUILDROOT_DIR} ${BUILD_TARGET_DIR}
	fi

	echo "Moving packages..."
	CONFIG_IN_FILE=${BUILD_TARGET_DIR}/Config.in
	CONFIG_IN_CUSTOM=${BUILD_TARGET_DIR}/package/Config.in.custom
	cp -r ${SETUP_DIR}/package/* ${BUILD_TARGET_DIR}/package/
	rm -rf ${CONFIG_IN_CUSTOM}
	touch ${CONFIG_IN_CUSTOM}
	echo "menu \"Custom Packages\"" >> ${CONFIG_IN_CUSTOM}
	find package -name 'Config.in' -exec echo -e "\tsource \"{}\"" >> ${CONFIG_IN_CUSTOM} \;
	echo "endmenu" >> ${CONFIG_IN_CUSTOM}
	if ! grep -q "Config.in.custom" ${CONFIG_IN_FILE}; then
		echo -e 'source "package/Config.in.custom"' >> $CONFIG_IN_FILE
	fi

	echo "Copying skeleton..."
	cp -r ${SETUP_DIR}/skeleton/* ${BUILD_TARGET_DIR}/system/skeleton/

	echo "Setting up configuration file..."
	DEF_CONFIG_FILE_NAME="${TARGET_BOARD//-/_}_defconfig"
	DEF_CONFIG="${BUILD_TARGET_DIR}/configs/${DEF_CONFIG_FILE_NAME}"
	rm -rf ${DEF_CONFIG}
	touch ${DEF_CONFIG}
	while read partconfig; do
		cat partials/$partconfig >> ${DEF_CONFIG}
	done < $CONFIG_FILE
	cd ${BUILD_TARGET_DIR} && make ${DEF_CONFIG_FILE_NAME}

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
