#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2025
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o pipefail
set -o errexit
set -o nounset
if [[ ${DEBUG:-false} == "true" ]]; then
	set -o xtrace
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUTPUT_ROOT=${OUTPUT_ROOT:-"${SCRIPT_DIR}/dist"}
WORK_DIR=${WORK_DIR:-"${SCRIPT_DIR}/output"}
VERSION=${VERSION:-4.3.12}
BOX_NAMESPACE=generic
BOX_BASE_URL=${BOX_BASE_URL:-}
PACKER_GETTER_READ_TIMEOUT=${PACKER_GETTER_READ_TIMEOUT:-90m}

export PACKER_GETTER_READ_TIMEOUT

function _parse_list() {
	local raw_value=${1:?list value is required}
	local -a values=()

	raw_value=${raw_value//,/ }
	read -r -a values <<<"${raw_value}"

	printf '%s\n' "${values[@]}"
}

mapfile -t DISTROS < <(_parse_list "${DISTROS:-ubuntu2204 ubuntu2404}")
mapfile -t PROVIDERS < <(_parse_list "${PROVIDERS:-libvirt virtualbox}")

declare -A PACKER_TEMPLATES=(
	[libvirt]=generic-libvirt-x64.json
	[virtualbox]=generic-virtualbox-x64.json
)

declare -A BUILT_BOXES=()
declare -A BUILT_CHECKSUMS=()

function _get_description() {
	case "$1" in
	ubuntu2204) echo "Ubuntu Jammy 22.04" ;;
	ubuntu2404) echo "Ubuntu Noble 24.04" ;;
	*) echo "Unknown" ;;
	esac
}

function _require_command() {
	local command_name=${1:?command name is required}

	if ! command -v "${command_name}" >/dev/null 2>&1; then
		echo "ERROR: ${command_name} is required"
		exit 1
	fi
}

function _ensure_packer_plugin() {
	local plugin=${1:?plugin is required}

	if ! packer plugins installed 2>/dev/null | grep -q "${plugin}"; then
		echo "Installing missing packer plugin: ${plugin}"
		packer plugins install "${plugin}"
	fi
}

function _assert_supported_distro() {
	local distro=${1:?distro is required}

	case "${distro}" in
	ubuntu2204 | ubuntu2404) ;;
	*)
		echo "ERROR: Unsupported distro '${distro}'"
		exit 1
		;;
	esac
}

function _assert_supported_provider() {
	local provider=${1:?provider is required}

	case "${provider}" in
	libvirt | virtualbox) ;;
	*)
		echo "ERROR: Unsupported provider '${provider}'"
		exit 1
		;;
	esac
}

function _check_reqs() {
	_require_command jq
	_require_command packer
	_require_command realpath
	_require_command sha256sum
	_require_command vagrant

	_ensure_packer_plugin github.com/hashicorp/qemu
	_ensure_packer_plugin github.com/hashicorp/vagrant
	_ensure_packer_plugin github.com/hashicorp/virtualbox

	for provider in "${PROVIDERS[@]}"; do
		_assert_supported_provider "${provider}"

		case "${provider}" in
		libvirt)
			_require_command qemu-system-x86_64
			_require_command virsh
			;;
		virtualbox)
			_require_command VBoxManage
			;;
		esac
	done

	for distro in "${DISTROS[@]}"; do
		_assert_supported_distro "${distro}"
	done
}

function _validate() {
	if printf '%s\n' "${PROVIDERS[@]}" | grep -qx 'libvirt'; then
		if virsh list --state-running --name | grep -q .; then
			echo "ERROR: Running libvirt instances detected."
			exit 1
		fi
	fi

	if printf '%s\n' "${PROVIDERS[@]}" | grep -qx 'virtualbox'; then
		if VBoxManage list runningvms | grep -q .; then
			echo "ERROR: Running VirtualBox instances detected."
			exit 1
		fi
	fi
}

function _box_url() {
	local distro=${1:?distro is required}
	local box_path=${2:?box path is required}

	if [[ -n ${BOX_BASE_URL} ]]; then
		printf '%s/%s/%s/%s' "${BOX_BASE_URL%/}" "${BOX_NAMESPACE}" "${distro}" "$(basename "${box_path}")"
		return
	fi

	printf 'file://%s' "$(realpath "${box_path}")"
}

function _build_box() {
	local distro=${1:?distro is required}
	local provider=${2:?provider is required}
	local build_name="${BOX_NAMESPACE}-${distro}-${provider}-x64"
	local template="${PACKER_TEMPLATES[${provider}]}"
	local box_name="${build_name}-${VERSION}.box"
	local box_path="${WORK_DIR}/${box_name}"
	local checksum_path="${box_path}.sha256"
	local publish_dir="${OUTPUT_ROOT}/${BOX_NAMESPACE}/${distro}"

	mkdir -p "${WORK_DIR}"

	(
		cd "${SCRIPT_DIR}"
		VERSION="${VERSION}" packer build -only="${build_name}" "${template}"
	)

	mkdir -p "${publish_dir}"
	mv "${box_path}" "${publish_dir}/"
	mv "${checksum_path}" "${publish_dir}/"
	rm -rf "${WORK_DIR:?}/${build_name}"

	BUILT_BOXES["${distro}:${provider}"]="${publish_dir}/${box_name}"
	BUILT_CHECKSUMS["${distro}:${provider}"]="${publish_dir}/${box_name}.sha256"
}

function _write_metadata() {
	local distro=${1:?distro is required}
	local publish_dir="${OUTPUT_ROOT}/${BOX_NAMESPACE}/${distro}"
	local provider_entries=()

	mkdir -p "${publish_dir}"

	for provider in "${PROVIDERS[@]}"; do
		local key="${distro}:${provider}"
		local box_path=${BUILT_BOXES[${key}]:-}
		local checksum_path=${BUILT_CHECKSUMS[${key}]:-}

		[[ -n ${box_path} ]] || continue
		[[ -n ${checksum_path} ]] || continue

		provider_entries+=(
			"$(jq -n \
				--arg name "${provider}" \
				--arg url "$(_box_url "${distro}" "${box_path}")" \
				--arg checksum "$(awk '{ print $1 }' "${checksum_path}")" \
				'{
                    name: $name,
                    url: $url,
                    checksum_type: "sha256",
                    checksum: $checksum,
                    architecture: "amd64",
                    default_architecture: true
                }')"
		)
	done

	if [[ ${#provider_entries[@]} -eq 0 ]]; then
		echo "ERROR: No built boxes found for ${distro}"
		exit 1
	fi

	local providers_json
	providers_json=$(printf '%s\n' "${provider_entries[@]}" | jq -s '.')

	jq -n \
		--arg name "${BOX_NAMESPACE}/${distro}" \
		--arg description "$(_get_description "${distro}")" \
		--arg version "${VERSION}" \
		--argjson providers "${providers_json}" \
		'{
            name: $name,
            description: $description,
            versions: [
                {
                    version: $version,
                    providers: $providers
                }
            ]
        }' >"${publish_dir}/metadata.json"
}

_check_reqs
_validate

for distro in "${DISTROS[@]}"; do
	for provider in "${PROVIDERS[@]}"; do
		_build_box "${distro}" "${provider}"
	done

	_write_metadata "${distro}"
done
