#!/bin/bash -eux

FLOPPY_MODPROBE_CONFIG=${FLOPPY_MODPROBE_CONFIG:-/etc/modprobe.d/floppy.conf}
FLOPPY_BOOT_DIR=${FLOPPY_BOOT_DIR:-/boot}

floppy2404_main() {
	printf 'blacklist floppy\n' >"${FLOPPY_MODPROBE_CONFIG}"

	# Then run this instead to rebuild all of the install
	# kernels without the floppy module.
	for kernel in "${FLOPPY_BOOT_DIR}"/config-*; do
		[ -f "${kernel}" ] || continue
		KERNEL=${kernel#*-}
		mkinitramfs -o "${FLOPPY_BOOT_DIR}/initrd.img-${KERNEL}.img" "${KERNEL}" || return 1
	done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
	floppy2404_main "$@"
fi
