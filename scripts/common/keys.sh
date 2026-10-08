#!/bin/bash

SSH_HOST_KEY_DIR=${SSH_HOST_KEY_DIR:-/etc/ssh}
SSH_KEY_CRON_PATH=${SSH_KEY_CRON_PATH:-/etc/cron.d/keys}
SSH_KEY_REGENERATE_SCRIPT=${SSH_KEY_REGENERATE_SCRIPT:-/usr/local/sbin/regenerate-ssh-host-keys.sh}
SSH_KEY_REGENERATE_SERVICE=${SSH_KEY_REGENERATE_SERVICE:-/etc/systemd/system/regenerate-ssh-host-keys.service}

keys_main() {
	# Delete the OpenSSH host keys, so they get generated when the box is
	# provisioned.
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_key"
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_key.pub"

	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_dsa_key"
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_dsa_key.pub"

	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_rsa_key"
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_rsa_key.pub"

	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_ecdsa_key"
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_ecdsa_key.pub"

	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_ed25519_key"
	rm -f "${SSH_HOST_KEY_DIR}/ssh_host_ed25519_key.pub"

	rm -f "${SSH_KEY_CRON_PATH}"
	rm -f "${SSH_KEY_REGENERATE_SCRIPT}"
	# NOTE: dpkg-reconfigure restarts ssh.service, which deadlocks with Before=ssh.service
	cat <<-'EOF' >"${SSH_KEY_REGENERATE_SERVICE}"
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
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	keys_main "$@"
fi
