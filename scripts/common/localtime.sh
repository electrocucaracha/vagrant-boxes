#!/bin/bash -eux

LOCALTIME_PATH=${LOCALTIME_PATH:-/etc/localtime}
SYSCONFIG_CLOCK_PATH=${SYSCONFIG_CLOCK_PATH:-/etc/sysconfig/clock}
UTC_ZONEINFO_PATH=${UTC_ZONEINFO_PATH:-/usr/share/zoneinfo/UTC}

localtime_main() {
	# If localtime is a regular file then the timedatectl command will fail.
	if [ -f "${LOCALTIME_PATH}" ] && [ "$(command -v timedatectl)" ]; then
		rm -f "${LOCALTIME_PATH}"
		timedatectl set-timezone UTC
	# Run the timedatectl command without removing a file.
	elif [ "$(command -v timedatectl)" ]; then
		timedatectl set-timezone UTC

		# Handle older distros which use sysconfig and the tzdata-update command.
	elif [ -f "${SYSCONFIG_CLOCK_PATH}" ] && [ "$(command -v tzdata-update)" ]; then
		printf "ZONE=\"UTC\"\n" >"${SYSCONFIG_CLOCK_PATH}"
		tzdata-update
	# Logic of last resort.
	elif [ -h "${LOCALTIME_PATH}" ] && [ -f "${UTC_ZONEINFO_PATH}" ]; then
		ln -sf "${UTC_ZONEINFO_PATH}" "${LOCALTIME_PATH}"
	elif [ -f "${LOCALTIME_PATH}" ] && [ -f "${UTC_ZONEINFO_PATH}" ]; then
		cp -f "${UTC_ZONEINFO_PATH}" "${LOCALTIME_PATH}"
	fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	localtime_main "$@"
fi
