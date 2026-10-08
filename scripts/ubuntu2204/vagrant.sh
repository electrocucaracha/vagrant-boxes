#!/bin/bash -x

VAGRANT_USERADD_CMD=${VAGRANT_USERADD_CMD:-/usr/sbin/useradd}
VAGRANT_SUDOERS_FILE=${VAGRANT_SUDOERS_FILE:-/etc/sudoers.d/vagrant}
VAGRANT_HOME_DIR=${VAGRANT_HOME_DIR:-/home/vagrant}
VAGRANT_BUILD_TIME_FILE=${VAGRANT_BUILD_TIME_FILE:-/etc/vagrant_box_build_time}

vagrant2204_main() {
	# Create the vagrant user account.
	"${VAGRANT_USERADD_CMD}" vagrant

	printf "vagrant\nvagrant\n" | passwd vagrant
	cat <<-EOF >"${VAGRANT_SUDOERS_FILE}"
		Defaults:vagrant !fqdn
		Defaults:vagrant !requiretty
		vagrant ALL=(ALL) NOPASSWD: ALL
	EOF
	chmod 0440 "${VAGRANT_SUDOERS_FILE}"

	# Create the vagrant user ssh directory.
	mkdir -p "${VAGRANT_HOME_DIR}/.ssh"
	chmod 700 "${VAGRANT_HOME_DIR}/.ssh"

	# Create an authorized keys file and insert the insecure public vagrant key.
	cat <<-EOF >"${VAGRANT_HOME_DIR}/.ssh/authorized_keys"
		ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
	EOF

	# Ensure the permissions are set correct to avoid OpenSSH complaints.
	chmod 0600 "${VAGRANT_HOME_DIR}/.ssh/authorized_keys"
	chown -R vagrant:vagrant "${VAGRANT_HOME_DIR}/.ssh"

	# Mark the vagrant box build time.
	date --utc >"${VAGRANT_BUILD_TIME_FILE}"
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	set -eux
	vagrant2204_main "$@"
fi
