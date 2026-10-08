#!/bin/bash -eux

CONSOLE_SETUP_PATH=${CONSOLE_SETUP_PATH:-/etc/default/console-setup}
UPSTART_TTY_DIR=${UPSTART_TTY_DIR:-/etc/init}

fixtty2204_main() {
	# Fix the no tty bug with vagrant.
	# https://github.com/mitchellh/vagrant/issues/1673
	sed -i -e 's,^ACTIVE_CONSOLES="/dev/tty.*,ACTIVE_CONSOLES="/dev/tty1",' "${CONSOLE_SETUP_PATH}"
	for tty_config in "${UPSTART_TTY_DIR}"/tty[^1]*.conf; do
		rm --force "${tty_config}"
	done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	fixtty2204_main "$@"
fi
