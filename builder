#!/bin/bash

TARGET_LIST=("rpi4-arcade-min" "rpi4-arcade" "rpi4-arcade-dev")
TARGET_BOARD="$2"
SETUP_DIR="${PWD}"
if [[ -z "${BUILD_DIR}" ]]; then
	mkdir -p "${PWD}/../builds/"
	BUILD_DIR="$(builtin cd "${PWD}/../builds/" || exit; pwd)"
else
	mkdir -p "${BUILD_DIR}"
	BUILD_DIR="$(builtin cd "${BUILD_DIR}" || exit; pwd)"
fi
BUILDROOT_VERSION="buildroot-2023.02.3"
STANDALONE=FALSE
if [[ "$3" == "stand-alone" ]]; then
	STANDALONE=TRUE
fi

usage() {
	echo "Usage: $0 <command> <target>"
	echo ""
	echo "Commands: setup build copy"
	echo "Targets: ${TARGET_LIST[*]}"
}

move_dir() {
	local MOVEDIR="$1"
	if [[ "${STANDALONE}" == "TRUE" ]]; then
		cp -r "${SETUP_DIR}/${MOVEDIR}/*" "${BUILD_TARGET_DIR}/${MOVEDIR}/"
	else
		for package in "${SETUP_DIR:?}/${MOVEDIR}"/*; do
			rm -rf "${BUILD_TARGET_DIR:?}/${MOVEDIR}/${package##*/}"
			ln -s "$package" "${BUILD_TARGET_DIR}/${MOVEDIR}/${package##*/}"
		done
	fi
}

verify_board() {
	echo "Verifying validity of target..."
	if ! [[ " ${TARGET_LIST[*]} " =~ ${TARGET_BOARD}  ]]; then
		usage
		exit 1
	fi
}

setup() {
	local BUILD_TARGET_DIR="${BUILD_DIR}/${TARGET_BOARD}"
	# Ensure build directory exists
	mkdir -p "${BUILD_DIR}"

	local CONFIG_FILE="${SETUP_DIR}/configs/${TARGET_BOARD}.buildercfg"
	if [ ! -f "${CONFIG_FILE}" ]; then
		echo "Unable to find build configuration file: ${CONFIG_FILE}"
	fi

	echo "Setting up buildroot environment..."
	local BUILDROOT_DIR="${BUILD_DIR}/${BUILDROOT_VERSION}"
	if [ ! -d "${BUILDROOT_DIR}" ]; then
		local FILE_NAME="${BUILDROOT_DIR}.tar.gz"
		wget -O "${FILE_NAME}" "https://buildroot.org/downloads/${BUILDROOT_VERSION}.tar.gz"
		pushd "${BUILD_DIR}" || exit 1
		tar xvzf "${FILE_NAME}"
		rm -rf "${FILE_NAME}"
		popd || exit 1
	fi
	if [ ! -d "${BUILD_TARGET_DIR}" ]; then
		cp -r "${BUILDROOT_DIR}" "${BUILD_TARGET_DIR}"
	fi

	echo "Moving packages..."
	local CONFIG_IN_FILE=${BUILD_TARGET_DIR}/Config.in
	local CONFIG_IN_CUSTOM="${BUILD_TARGET_DIR}/package/Config.in.custom"
	move_dir package
	rm -rf "${CONFIG_IN_CUSTOM}"
	touch "${CONFIG_IN_CUSTOM}"
	# shellcheck disable=SC2129
	echo "menu \"Custom Packages\"" >> "${CONFIG_IN_CUSTOM}"
	# Ignoring this warning because it is wrong, the redirection is being
	# applied to the echo, not the find command. Creating a follow on issue
	# to look into this further. Issue number 48.
	# shellcheck disable=SC2227
	find package -name 'Config.in' -exec echo -e "\tsource \"{}\"" >> "${CONFIG_IN_CUSTOM}" \;
	echo "endmenu" >> "${CONFIG_IN_CUSTOM}"
	if ! grep -q "Config.in.custom" "${CONFIG_IN_FILE}"; then
		echo -e 'source "package/Config.in.custom"' >> "$CONFIG_IN_FILE"
	fi

	echo "Moving boards..."
	move_dir board

	echo "Setting up configuration file..."
	local DEF_CONFIG_FILE_NAME="${TARGET_BOARD//-/_}_defconfig"
	local DEF_CONFIG="${BUILD_TARGET_DIR}/configs/${DEF_CONFIG_FILE_NAME}"
	rm -rf "${DEF_CONFIG}"
	touch "${DEF_CONFIG}"
	while read -r partconfig; do
		cat "${SETUP_DIR}/partials/$partconfig" >> "${DEF_CONFIG}"
	done < "$CONFIG_FILE"
	make -C "${BUILD_TARGET_DIR}" "${DEF_CONFIG_FILE_NAME}" || exit 1

	make -C "${BUILD_TARGET_DIR}" source

	echo "Build successfully setup"
}

build() {
	setup
	echo "Starting build..."
	make -C "${BUILD_DIR}/${TARGET_BOARD}" all
	echo "Build complete."
}

verify_board

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
