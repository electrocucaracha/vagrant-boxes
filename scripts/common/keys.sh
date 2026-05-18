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
cat <<-'EOF' >/usr/local/sbin/regenerate-ssh-host-keys.sh
	#!/bin/bash

	export PATH="$PATH:/usr/sbin"
	export DEBIAN_FRONTEND=noninteractive
	export DEBCONF_NONINTERACTIVE_SEEN=true

	for i in {1..5}; do
		if /usr/sbin/dpkg-reconfigure openssh-server >>/var/log/ssh-host-keys-reconfigure.log 2>&1; then
			exit 0
		fi

		echo "retry $i failed" >>/var/log/ssh-host-keys-reconfigure.log
		sleep 15
	done

	exit 1
EOF
chmod 0755 /usr/local/sbin/regenerate-ssh-host-keys.sh
cat <<-'EOF' >/etc/systemd/system/regenerate-ssh-host-keys.service
	[Unit]
	Description=Regenerate SSH host keys before SSH starts
	ConditionPathExists=!/etc/ssh/ssh_host_rsa_key
	Before=ssh.service

	[Service]
	Type=oneshot
	ExecStart=/usr/local/sbin/regenerate-ssh-host-keys.sh
	RemainAfterExit=yes

	[Install]
	WantedBy=ssh.service
EOF
systemctl daemon-reload
systemctl enable regenerate-ssh-host-keys.service
