#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2025
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
OUTPUT_ROOT=${OUTPUT_ROOT:-"${SCRIPT_DIR}/dist"}
WORK_DIR=${WORK_DIR:-"${SCRIPT_DIR}/output"}
VERSION=${VERSION:-4.3.12}
BOX_NAMESPACE=generic
BOX_BASE_URL=${BOX_BASE_URL:-}
DEPLOY_WWW=${DEPLOY_WWW:-false}
WWW_ROOT=${WWW_ROOT:-/var/www}
PACKER_GETTER_READ_TIMEOUT=${PACKER_GETTER_READ_TIMEOUT:-90m}
UTM_PACKER_PLUGIN_SOURCE=${UTM_PACKER_PLUGIN_SOURCE:-github.com/electrocucaracha/utm}
UTM_PACKER_PLUGIN_VERSION=${UTM_PACKER_PLUGIN_VERSION:-v4.0.3}

export PACKER_GETTER_READ_TIMEOUT

function _set_shell_options() {
	set -o pipefail
	set -o errexit
	set -o nounset
	if [[ ${DEBUG:-false} == "true" ]]; then
		set -o xtrace
	fi
}

function _parse_list() {
	local raw_value=${1:?list value is required}
	local -a values=()

	raw_value=${raw_value//,/ }
	read -r -a values <<<"${raw_value}"

	printf '%s\n' "${values[@]}"
}

DISTRO_LIST=${DISTROS:-ubuntu2204 ubuntu2404}
PROVIDER_LIST=${PROVIDERS:-libvirt virtualbox}

DISTROS=()
while IFS= read -r distro; do
	DISTROS+=("${distro}")
done < <(_parse_list "${DISTRO_LIST}")

PROVIDERS=()
while IFS= read -r provider; do
	PROVIDERS+=("${provider}")
done < <(_parse_list "${PROVIDER_LIST}")

BUILT_KEYS=()
BUILT_BOXES=()
BUILT_CHECKSUMS=()

function _get_description() {
	case "$1" in
	ubuntu2204) echo "Ubuntu Jammy 22.04" ;;
	ubuntu2404) echo "Ubuntu Noble 24.04" ;;
	*) echo "Unknown" ;;
	esac
}

function _get_packer_template() {
	case "$1" in
	libvirt) echo "generic-libvirt-x64.json" ;;
	utm) echo "generic-utm-arm64.json" ;;
	virtualbox) echo "generic-virtualbox-x64.json" ;;
	esac
}

function _get_provider_build_arch() {
	case "$1" in
	libvirt | virtualbox) echo "x64" ;;
	utm) echo "arm64" ;;
	esac
}

function _get_provider_metadata_arch() {
	case "$1" in
	libvirt | virtualbox) echo "amd64" ;;
	utm) echo "arm64" ;;
	esac
}

function _find_built_box_index() {
	local key=${1:?build key is required}
	local index

	for ((index = 0; index < ${#BUILT_KEYS[@]}; index++)); do
		if [[ ${BUILT_KEYS[${index}]} == "${key}" ]]; then
			printf '%s' "${index}"
			return 0
		fi
	done

	return 1
}

function _record_built_box() {
	local key=${1:?build key is required}
	local box_path=${2:?box path is required}
	local checksum_path=${3:?checksum path is required}
	local index=

	if index=$(_find_built_box_index "${key}"); then
		BUILT_BOXES[index]="${box_path}"
		BUILT_CHECKSUMS[index]="${checksum_path}"
		return
	fi

	BUILT_KEYS+=("${key}")
	BUILT_BOXES+=("${box_path}")
	BUILT_CHECKSUMS+=("${checksum_path}")
}

function _get_built_box_path() {
	local key=${1:?build key is required}
	local index=

	if index=$(_find_built_box_index "${key}"); then
		printf '%s' "${BUILT_BOXES[${index}]}"
	fi
}

function _get_built_checksum_path() {
	local key=${1:?build key is required}
	local index=

	if index=$(_find_built_box_index "${key}"); then
		printf '%s' "${BUILT_CHECKSUMS[${index}]}"
	fi
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
	local version=${2:-}
	local installed_plugins=
	local normalized_version=

	installed_plugins=$(packer plugins installed 2>/dev/null || true)
	normalized_version=${version#v}

	if grep -q "${plugin}" <<<"${installed_plugins}" &&
		([[ -z ${version} ]] || grep -Eq "_v?${normalized_version//./\\.}_" <<<"${installed_plugins}"); then
		return
	fi

	echo "Installing missing packer plugin: ${plugin}${version:+ @ ${version}}"

	if [[ -n ${version} ]]; then
		packer plugins install "${plugin}" "${version}"
		return
	fi

	packer plugins install "${plugin}"
}

function _remove_packer_plugin() {
	local plugin=${1:?plugin is required}

	if packer plugins installed 2>/dev/null | grep -q "${plugin}"; then
		echo "Removing conflicting packer plugin: ${plugin}"
		packer plugins remove "${plugin}"
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
	libvirt | utm | virtualbox) ;;
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

	for provider in "${PROVIDERS[@]}"; do
		_assert_supported_provider "${provider}"

		case "${provider}" in
		libvirt)
			_ensure_packer_plugin github.com/hashicorp/qemu
			_ensure_packer_plugin github.com/hashicorp/vagrant
			_require_command qemu-system-x86_64
			_require_command virsh
			;;
		utm)
			_remove_packer_plugin github.com/naveenrajm7/utm
			_ensure_packer_plugin "${UTM_PACKER_PLUGIN_SOURCE}" "${UTM_PACKER_PLUGIN_VERSION}"
			_require_command utmctl
			if [[ $(uname -s) != "Darwin" ]]; then
				echo "ERROR: utm provider builds require macOS"
				exit 1
			fi
			;;
		virtualbox)
			_ensure_packer_plugin github.com/hashicorp/vagrant
			_ensure_packer_plugin github.com/hashicorp/virtualbox
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

function _cleanup_utm_vm() {
	local vm_name=${1:?vm name is required}
	local vm_status=

	if ! vm_status=$(utmctl status "${vm_name}" 2>/dev/null); then
		return
	fi

	echo "Removing existing UTM VM: ${vm_name}"

	if [[ ${vm_status} != "stopped" ]]; then
		utmctl stop "${vm_name}" --force >/dev/null
	fi

	utmctl delete "${vm_name}" >/dev/null
}

function _build_box() {
	local distro=${1:?distro is required}
	local provider=${2:?provider is required}
	local build_arch
	build_arch=$(_get_provider_build_arch "${provider}")
	local build_name="${BOX_NAMESPACE}-${distro}-${provider}-${build_arch}"
	local template
	template=$(_get_packer_template "${provider}")
	local box_name="${build_name}-${VERSION}.box"
	local box_path="${WORK_DIR}/${box_name}"
	local checksum_path="${box_path}.sha256"
	local publish_dir="${OUTPUT_ROOT}/${BOX_NAMESPACE}/${distro}"

	mkdir -p "${WORK_DIR}"

	if [[ ${provider} == "utm" ]]; then
		_cleanup_utm_vm "${build_name}"
	fi

	(
		cd "${SCRIPT_DIR}"
		VERSION="${VERSION}" packer build -only="${build_name}" "${template}"
	)

	mkdir -p "${publish_dir}"
	mv "${box_path}" "${publish_dir}/"
	mv "${checksum_path}" "${publish_dir}/"
	rm -rf "${WORK_DIR:?}/${build_name}"

	_record_built_box \
		"${distro}:${provider}" \
		"${publish_dir}/${box_name}" \
		"${publish_dir}/${box_name}.sha256"
}

function _get_default_architecture() {
	local distro=${1:?distro is required}
	local first_architecture=

	for provider in "${PROVIDERS[@]}"; do
		local key="${distro}:${provider}"
		local box_path
		box_path=$(_get_built_box_path "${key}")
		local architecture
		architecture=$(_get_provider_metadata_arch "${provider}")

		[[ -n ${box_path} ]] || continue

		if [[ -z ${first_architecture} ]]; then
			first_architecture=${architecture}
		fi

		if [[ ${architecture} == "amd64" ]]; then
			printf 'amd64'
			return
		fi
	done

	printf '%s' "${first_architecture}"
}

function _write_metadata() {
	local distro=${1:?distro is required}
	local publish_dir="${OUTPUT_ROOT}/${BOX_NAMESPACE}/${distro}"
	local default_architecture
	default_architecture=$(_get_default_architecture "${distro}")
	local provider_entries=()

	mkdir -p "${publish_dir}"

	for provider in "${PROVIDERS[@]}"; do
		local key="${distro}:${provider}"
		local box_path
		box_path=$(_get_built_box_path "${key}")
		local checksum_path
		checksum_path=$(_get_built_checksum_path "${key}")
		local architecture
		architecture=$(_get_provider_metadata_arch "${provider}")
		local is_default_architecture=false

		if [[ ${architecture} == "${default_architecture}" ]]; then
			is_default_architecture=true
		fi

		[[ -n ${box_path} ]] || continue
		[[ -n ${checksum_path} ]] || continue

		provider_entries+=(
			"$(jq -n \
				--arg name "${provider}" \
				--arg url "$(_box_url "${distro}" "${box_path}")" \
				--arg checksum "$(awk '{ print $1 }' "${checksum_path}")" \
				--arg architecture "${architecture}" \
				--argjson default_architecture "${is_default_architecture}" \
				'{
                    name: $name,
                    url: $url,
                    checksum_type: "sha256",
                    checksum: $checksum,
                    architecture: $architecture,
                    default_architecture: $default_architecture
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

function _deploy_www() {
	if [[ ${DEPLOY_WWW} != "true" ]]; then
		return
	fi

	local deploy_dir="${WWW_ROOT%/}/${BOX_NAMESPACE}"

	mkdir -p "${deploy_dir}"
	rm -rf "${deploy_dir:?}/"*
	cp -R "${OUTPUT_ROOT}/${BOX_NAMESPACE}/." "${deploy_dir}/"
}

function main() {
	_set_shell_options
	_check_reqs
	_validate

	for distro in "${DISTROS[@]}"; do
		for provider in "${PROVIDERS[@]}"; do
			_build_box "${distro}" "${provider}"
		done

		_write_metadata "${distro}"
	done

	_deploy_www
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	main "$@"
fi
