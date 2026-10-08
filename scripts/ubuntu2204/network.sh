#!/bin/bash -x

NETWORK_SYSCTL_CONF=${NETWORK_SYSCTL_CONF:-/etc/sysctl.conf}
NETWORK_HOSTNAME_FILE=${NETWORK_HOSTNAME_FILE:-/etc/hostname}
NETWORK_HOSTS_FILE=${NETWORK_HOSTS_FILE:-/etc/hosts}
NETWORK_NETPLAN_FILE=${NETWORK_NETPLAN_FILE:-/etc/netplan/01-netcfg.yaml}
NETWORK_RESOLVED_CONF=${NETWORK_RESOLVED_CONF:-/etc/systemd/resolved.conf}
NETWORK_IFPLUGD_FILE=${NETWORK_IFPLUGD_FILE:-/etc/default/ifplugd}
NETWORK_SHUTDOWN_CMD=${NETWORK_SHUTDOWN_CMD:-shutdown}

network2204_retry() {
	local COUNT=1
	local DELAY=0
	local RESULT=0
	while [[ ${COUNT} -le 10 ]]; do
		[[ ${RESULT} -ne 0 ]] && {
			[ "$(which tput 2>/dev/null)" != "" ] && [ -n "$TERM" ] && tput setaf 1
			echo -e "\n${*} failed... retrying ${COUNT} of 10.\n" >&2
			[ "$(which tput 2>/dev/null)" != "" ] && [ -n "$TERM" ] && tput sgr0
		}
		"${@}" && { RESULT=0 && break; } || RESULT="${?}"
		COUNT="$((COUNT + 1))"

		# Increase the delay with each iteration.
		DELAY="$((DELAY + 10))"
		sleep $DELAY
	done

	[[ ${COUNT} -gt 10 ]] && {
		[ "$(which tput 2>/dev/null)" != "" ] && [ -n "$TERM" ] && tput setaf 1
		echo -e "\nThe command failed 10 times.\n" >&2
		[ "$(which tput 2>/dev/null)" != "" ] && [ -n "$TERM" ] && tput sgr0
	}

	return "${RESULT}"
}

network2204_main() {
	# If the TERM environment variable is set to dumb, tput will generate spurious error messages.
	[ "$TERM" == "dumb" ] && export TERM="vt100"

	# To allow for automated installs, we disable interactive configuration steps.
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true

	# Disable IPv6 for the current boot.
	sysctl net.ipv6.conf.all.disable_ipv6=1

	# Ensure IPv6 stays disabled.
	printf "\nnet.ipv6.conf.all.disable_ipv6 = 1\n" >>"${NETWORK_SYSCTL_CONF}"

	# Set the hostname, and then ensure it will resolve properly.
	printf "ubuntu2204.localdomain\n" >"${NETWORK_HOSTNAME_FILE}"
	printf "\n127.0.0.1 ubuntu2204.localdomain\n\n" >>"${NETWORK_HOSTS_FILE}"

	cat <<-EOF >"${NETWORK_NETPLAN_FILE}"
		network:
		  version: 2
		  renderer: networkd
		  ethernets:
		    eth0:
		      dhcp4: true
		      dhcp6: false
		      optional: true
		      nameservers:
		               addresses: [1.1.1.1, 1.0.0.1, 8.8.8.8, 8.8.4.4]
	EOF

	# Apply the network plan configuration.
	netplan generate

	# Ensure a nameserver is being used that won't return an IP for non-existent domain names.
	sed -i -e "s/#DNS=.*/DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4/g" "${NETWORK_RESOLVED_CONF}"
	sed -i -e "s/#FallbackDNS=.*/FallbackDNS=/g" "${NETWORK_RESOLVED_CONF}"
	sed -i -e "s/#Domains=.*/Domains=/g" "${NETWORK_RESOLVED_CONF}"
	sed -i -e "s/#DNSSEC=.*/DNSSEC=yes/g" "${NETWORK_RESOLVED_CONF}"
	sed -i -e "s/#Cache=.*/Cache=yes/g" "${NETWORK_RESOLVED_CONF}"
	sed -i -e "s/#DNSStubListener=.*/DNSStubListener=yes/g" "${NETWORK_RESOLVED_CONF}"

	# Install ifplugd so we can monitor and auto-configure nics.
	network2204_retry apt-get --assume-yes install ifplugd

	# Configure ifplugd to monitor the eth0 interface.
	sed -i -e 's/INTERFACES=.*/INTERFACES="eth0"/g' "${NETWORK_IFPLUGD_FILE}"

	# Ensure the networking interfaces get configured on boot.
	systemctl enable systemd-networkd.service

	# Ensure ifplugd also gets started, so the ethernet interface is monitored.
	systemctl enable ifplugd.service

	# Reboot onto the new kernel (if applicable).
	("${NETWORK_SHUTDOWN_CMD}" -r +1) &
	return 0
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	network2204_main "$@"
fi
