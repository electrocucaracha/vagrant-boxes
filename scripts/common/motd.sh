#!/bin/bash -ux

MOTD_PATH=${MOTD_PATH:-/etc/motd}

motd_main() {
	cat <<EOF >"${MOTD_PATH}"
EOF
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	motd_main "$@"
fi
