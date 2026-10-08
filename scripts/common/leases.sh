#!/bin/bash -eux

LEASE_NETWORKMANAGER_DIR=${LEASE_NETWORKMANAGER_DIR:-/var/lib/NetworkManager}
LEASE_DHCLIENT_DIR=${LEASE_DHCLIENT_DIR:-/var/lib/dhclient}
LEASE_DHCP_DIR=${LEASE_DHCP_DIR:-/var/lib/dhcp}

leases_main() {
	# Delete the DHCP client lease files from any/all locations we know about.
	if [ -d "${LEASE_NETWORKMANAGER_DIR}/" ]; then
		find "${LEASE_NETWORKMANAGER_DIR}/" \( -name "*.lease" -o -name "*.leases" \)
		find "${LEASE_NETWORKMANAGER_DIR}/" \( -name "*.lease" -o -name "*.leases" \) -exec rm --force {} \;
	fi

	if [ -d "${LEASE_DHCLIENT_DIR}/" ]; then
		find "${LEASE_DHCLIENT_DIR}/" \( -name "*.lease" -o -name "*.leases" \)
		find "${LEASE_DHCLIENT_DIR}/" \( -name "*.lease" -o -name "*.leases" \) -exec rm --force {} \;
	fi

	if [ -d "${LEASE_DHCP_DIR}/" ]; then
		find "${LEASE_DHCP_DIR}/" \( -name "*.lease" -o -name "*.leases" \)
		find "${LEASE_DHCP_DIR}/" \( -name "*.lease" -o -name "*.leases" \) -exec rm --force {} \;
	fi
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	leases_main "$@"
fi
