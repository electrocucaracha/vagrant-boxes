#!/bin/bash -ux

ZERO_DEVICE=${ZERO_DEVICE:-/dev/zero}
ROOT_MOUNT_POINT=${ROOT_MOUNT_POINT:-/}
BOOT_MOUNT_POINT=${BOOT_MOUNT_POINT:-/boot}
ROOT_ZERO_FILL_PREFIX=${ROOT_ZERO_FILL_PREFIX:-/zerofill}
BOOT_ZERO_FILL_FILE=${BOOT_ZERO_FILL_FILE:-/boot/zerofill}
BLKID_CMD=${BLKID_CMD:-/sbin/blkid}
SWAPOFF_CMD=${SWAPOFF_CMD:-/sbin/swapoff}
MKSWAP_CMD=${MKSWAP_CMD:-/sbin/mkswap}
SWAP_UUID_DIR=${SWAP_UUID_DIR:-/dev/disk/by-uuid}

zerodisk_main() {
	local rootcount
	local bootcount
	local swapuuid
	local swappart

	# Whiteout the root partition.
	rootcount=$(df --sync -mP "${ROOT_MOUNT_POINT}" | tail -n1 | awk -F ' ' '{print $4}')
	rootcount=$((rootcount / 4))
	(dd if="${ZERO_DEVICE}" of="${ROOT_ZERO_FILL_PREFIX}_1" bs=1M count="${rootcount}" || echo "dd exit code $? suppressed") &
	(dd if="${ZERO_DEVICE}" of="${ROOT_ZERO_FILL_PREFIX}_2" bs=1M count="${rootcount}" || echo "dd exit code $? suppressed") &
	(dd if="${ZERO_DEVICE}" of="${ROOT_ZERO_FILL_PREFIX}_3" bs=1M count="${rootcount}" || echo "dd exit code $? suppressed") &
	(dd if="${ZERO_DEVICE}" of="${ROOT_ZERO_FILL_PREFIX}_4" bs=1M count="${rootcount}" || echo "dd exit code $? suppressed") &
	wait
	sync || echo "sync exit code $? suppressed"
	rm --force "${ROOT_ZERO_FILL_PREFIX}_1" "${ROOT_ZERO_FILL_PREFIX}_2" "${ROOT_ZERO_FILL_PREFIX}_3" "${ROOT_ZERO_FILL_PREFIX}_4"

	# Whiteout boot if it is on a different partition from root.
	rootcount=$(df --sync -mP "${ROOT_MOUNT_POINT}" | tail -n1 | awk -F ' ' '{print $4}')
	rootcount=$((rootcount - 1))
	bootcount=$(df --sync -mP "${BOOT_MOUNT_POINT}" | tail -n1 | awk -F ' ' '{print $4}')
	bootcount=$((bootcount - 1))
	if [ "${rootcount}" != "${bootcount}" ]; then
		dd if="${ZERO_DEVICE}" of="${BOOT_ZERO_FILL_FILE}" bs=1M count="${bootcount}" || echo "dd exit code $? suppressed"
		sync || echo "sync exit code $? suppressed"
		rm --force "${BOOT_ZERO_FILL_FILE}"
	fi

	# If blkid is installed we use it to locate the swap partition.
	if [ -f "${BLKID_CMD}" ]; then
		swapuuid=$("${BLKID_CMD}" -o value -l -s UUID -t TYPE=swap)
	else
		swapuuid=
	fi

	# Whiteout the swap partition.
	if [ -n "${swapuuid}" ]; then
		swappart=$(readlink -f "${SWAP_UUID_DIR}/${swapuuid}")
		"${SWAPOFF_CMD}" "${swappart}"
		dd if="${ZERO_DEVICE}" of="${swappart}" bs=1M || echo "dd exit code $? suppressed"
		"${MKSWAP_CMD}" -U "${swapuuid}" "${swappart}"
	fi

	# Sync to ensure that the delete completes before we move to the shutdown phase.
	sync
	sync
	sync

	echo "All done."
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	zerodisk_main "$@"
fi
