#!/bin/bash

APT_CONFIG_DIR=${APT_CONFIG_DIR:-/etc/apt/apt.conf.d}
CLOUD_INIT_DIR=${CLOUD_INIT_DIR:-/etc/cloud}
HOSTS_FILE=${HOSTS_FILE:-/etc/hosts}
LOG_ROOT=${LOG_ROOT:-/var/log}
RANDOM_SEED_FILE=${RANDOM_SEED_FILE:-/var/lib/systemd/random-seed}

cleanup2404_error() {
	if [ $? -ne 0 ]; then
		printf "\n\napt failed...\n\n"
		exit 1
	fi
}

cleanup2404_main() {
	# To allow for automated installs, we disable interactive configuration steps.
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true

	# Remove cloud init packages.
	dpkg -l eatmydata &>/dev/null && apt-get --assume-yes purge eatmydata
	dpkg -l libeatmydata1 &>/dev/null && apt-get --assume-yes purge libeatmydata1
	dpkg -l cloud-init &>/dev/null && apt-get --assume-yes purge cloud-init

	# We can probably also remove unattended-upgrades ... but we'll save that for later.
	# dpkg -l unattended-upgrades &>/dev/null && apt-get --assume-yes purge unattended-upgrades

	# Cleanup unused packages.
	apt-get --assume-yes autoremove
	cleanup2404_error
	apt-get --assume-yes autoclean
	cleanup2404_error

	# Restore the system default apt retry value.
	[ -f "${APT_CONFIG_DIR}/20retries" ] && rm --force "${APT_CONFIG_DIR}/20retries"

	# Remove leftover config files/directories.
	[ -d "${CLOUD_INIT_DIR}/" ] && rm --recursive --force "${CLOUD_INIT_DIR:?}/"

	# Remove the workaround IP address for old-releases if its present.
	sed -i '/old-releases.ubuntu.com/d' "${HOSTS_FILE}"

	# Remove log files.
	[ -d "${LOG_ROOT}/dist-upgrade/" ] && rm --recursive --force "${LOG_ROOT}/dist-upgrade/"
	[ -d "${LOG_ROOT}/installer/" ] && rm --recursive --force "${LOG_ROOT}/installer/"

	[ -f "${LOG_ROOT}/apt/eipp.log.xz" ] && rm --force "${LOG_ROOT}/apt/eipp.log.xz"
	[ -f "${LOG_ROOT}/cloud-init-output.log" ] && rm --force "${LOG_ROOT}/cloud-init-output.log"
	[ -f "${LOG_ROOT}/cloud-init.log" ] && rm --force "${LOG_ROOT}/cloud-init.log"
	[ -f "${LOG_ROOT}/bootstrap.log" ] && rm --force "${LOG_ROOT}/bootstrap.log"
	[ -f "${LOG_ROOT}/dmesg.1.gz" ] && rm --force "${LOG_ROOT}/dmesg.1.gz"
	[ -f "${LOG_ROOT}/dmesg.0" ] && rm --force "${LOG_ROOT}/dmesg.0"
	[ -f "${LOG_ROOT}/dmesg" ] && rm --force "${LOG_ROOT}/dmesg"

	[ -f "${LOG_ROOT}/apt/history.log" ] && truncate --size=0 "${LOG_ROOT}/apt/history.log"
	[ -f "${LOG_ROOT}/apt/term.log" ] && truncate --size=0 "${LOG_ROOT}/apt/term.log"
	[ -f "${LOG_ROOT}/ubuntu-advantage-timer.log" ] && truncate --size=0 "${LOG_ROOT}/ubuntu-advantage-timer.log"
	[ -f "${LOG_ROOT}/ubuntu-advantage.log" ] && truncate --size=0 "${LOG_ROOT}/ubuntu-advantage.log"
	[ -f "${LOG_ROOT}/alternatives.log" ] && truncate --size=0 "${LOG_ROOT}/alternatives.log"
	[ -f "${LOG_ROOT}/dpkg.log" ] && truncate --size=0 "${LOG_ROOT}/dpkg.log"
	[ -f "${LOG_ROOT}/kern.log" ] && truncate --size=0 "${LOG_ROOT}/kern.log"
	[ -f "${LOG_ROOT}/syslog" ] && truncate --size=0 "${LOG_ROOT}/syslog"

	# Remove the random seed so a unique value is used the first time the box is booted.
	systemctl --quiet is-active systemd-random-seed.service && systemctl stop systemd-random-seed.service
	[ -f "${RANDOM_SEED_FILE}" ] && rm --force "${RANDOM_SEED_FILE}"

	# *Unmask anything we might have masked in the apt module.
	systemctl --quiet list-unit-files apt-news.service &>/dev/null && [ "$(systemctl is-enabled apt-news.service)" == "masked" ] && systemctl unmask apt-news.service
	systemctl --quiet list-unit-files apt-daily.service &>/dev/null && [ "$(systemctl is-enabled apt-daily.service)" == "masked" ] && systemctl unmask apt-daily.service
	# systemctl --quiet list-unit-files apt-daily-upgrade.service &>/dev/null && [ "$(systemctl is-enabled apt-daily-upgrade.service)" == "masked" ] && systemctl unmask apt-daily-upgrade.service

	systemctl --quiet list-unit-files packagekit.service &>/dev/null && [ "$(systemctl is-enabled packagekit.service)" == "disabled" ] && systemctl enable packagekit.service
	systemctl --quiet list-unit-files packagekit-offline-update.service &>/dev/null && [ "$(systemctl is-enabled packagekit-offline-update.service)" == "masked" ] && systemctl unmask packagekit-offline-update.service

	systemctl --quiet list-unit-files snapd.service &>/dev/null && [ "$(systemctl is-enabled snapd.service)" == "masked" ] && systemctl unmask snapd.service
	systemctl --quiet list-unit-files snapd.socket &>/dev/null && [ "$(systemctl is-enabled snapd.socket)" == "disabled" ] && systemctl enable snapd.socket
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	cleanup2404_main "$@"
fi
