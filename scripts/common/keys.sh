#!/bin/bash

# Delete the OpenSSH host keys, so they get generated when the box is
# provisioned.

rm -f /etc/ssh/ssh_host_key
rm -f /etc/ssh/ssh_host_key.pub

rm -f /etc/ssh/ssh_host_dsa_key
rm -f /etc/ssh/ssh_host_dsa_key.pub

rm -f /etc/ssh/ssh_host_rsa_key
rm -f /etc/ssh/ssh_host_rsa_key.pub

rm -f /etc/ssh/ssh_host_ecdsa_key
rm -f /etc/ssh/ssh_host_ecdsa_key.pub

rm -f /etc/ssh/ssh_host_ed25519_key
rm -f /etc/ssh/ssh_host_ed25519_key.pub

if [[ $PACKER_BUILD_NAME =~ ^generic-ubuntu(2204|2404|2604)-((libvirt|virtualbox)-x64|utm-arm64)$ ]]; then
	printf '%s\n' "@reboot root /bin/bash -c 'export PATH=\$PATH:/usr/sbin ; export DEBIAN_FRONTEND=noninteractive ; export DEBCONF_NONINTERACTIVE_SEEN=true ; for i in 1 2 3 4 5 ; do /usr/sbin/dpkg-reconfigure openssh-server >>/var/log/ssh-host-keys-reconfigure.log 2>&1 && /bin/systemctl restart ssh.service >>/var/log/ssh-host-keys-reconfigure.log 2>&1 && rm --force /etc/cron.d/keys && exit 0 ; echo \"retry \$i failed\" >>/var/log/ssh-host-keys-reconfigure.log ; sleep 15 ; done ; exit 1'" >/etc/cron.d/keys
fi
