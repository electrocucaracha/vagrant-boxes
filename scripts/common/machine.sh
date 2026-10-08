#!/bin/bash

MACHINE_ID_DBUS_PATH=${MACHINE_ID_DBUS_PATH:-/var/lib/dbus/machine-id}
MACHINE_ID_ETC_PATH=${MACHINE_ID_ETC_PATH:-/etc/machine-id}
MACHINE_ID_RUN_PATH=${MACHINE_ID_RUN_PATH:-/run/machine-id}

machine_main() {
	# Delete the machine-id file so a new value gets generated during subsequent reboots.
	if [ -f "${MACHINE_ID_DBUS_PATH}" ]; then
		truncate -s 0 "${MACHINE_ID_DBUS_PATH}"
	fi

	if [ -f "${MACHINE_ID_ETC_PATH}" ]; then
		truncate -s 0 "${MACHINE_ID_ETC_PATH}"
	fi

	if [ -f "${MACHINE_ID_RUN_PATH}" ]; then
		truncate -s 0 "${MACHINE_ID_RUN_PATH}"
	fi
}

# printf "@reboot root command bash -c '/usr/bin/systemd-machine-id-setup ; rm --force /etc/cron.d/machine-id'\n" > /etc/cron.d/machine-id

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	machine_main "$@"
fi
