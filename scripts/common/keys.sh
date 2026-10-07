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

rm -f /etc/cron.d/keys
rm -f /usr/local/sbin/regenerate-ssh-host-keys.sh
# NOTE: dpkg-reconfigure restarts ssh.service, which deadlocks with Before=ssh.service
cat <<-'EOF' >/etc/systemd/system/regenerate-ssh-host-keys.service
	[Unit]
	Description=Regenerate SSH host keys before SSH starts
	ConditionPathExists=!/etc/ssh/ssh_host_rsa_key
	Before=ssh.service ssh.socket

	[Service]
	Type=oneshot
	ExecStart=/usr/bin/ssh-keygen -A
	TimeoutStartSec=120
	RemainAfterExit=yes

	[Install]
	WantedBy=ssh.service
EOF
systemctl daemon-reload
systemctl enable regenerate-ssh-host-keys.service
