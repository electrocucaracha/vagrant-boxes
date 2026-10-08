#!/bin/bash -eux

lockout_main() {
	local lock_password
	lock_password=$(dd if=/dev/urandom count=128 status=none | md5sum | awk -F' ' '{print $1}')
	printf '%s\n%s\n' "$lock_password" "$lock_password" | passwd root
	passwd --lock root
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	lockout_main "$@"
fi
