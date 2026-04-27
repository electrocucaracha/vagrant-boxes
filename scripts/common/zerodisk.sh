#!/bin/bash -ux

# Whiteout the root partition.
rootcount=$(df --sync -mP / | tail -n1 | awk -F ' ' '{print $4}')
rootcount=$((rootcount / 4))
(dd if=/dev/zero of=/zerofill_1 bs=1M count=$rootcount || echo "dd exit code $? suppressed") &
(dd if=/dev/zero of=/zerofill_2 bs=1M count=$rootcount || echo "dd exit code $? suppressed") &
(dd if=/dev/zero of=/zerofill_3 bs=1M count=$rootcount || echo "dd exit code $? suppressed") &
(dd if=/dev/zero of=/zerofill_4 bs=1M count=$rootcount || echo "dd exit code $? suppressed") &
wait
sync || echo "sync exit code $? suppressed"
rm --force /zerofill_1 /zerofill_2 /zerofill_3 /zerofill_4

# Whiteout boot if the block count is different then root, otherwise if the
# block counts are identical, we assume both folders are on the same partition.
rootcount=$(df --sync -mP / | tail -n1 | awk -F ' ' '{print $4}')
rootcount=$((rootcount - 1))
bootcount=$(df --sync -mP /boot | tail -n1 | awk -F ' ' '{print $4}')
bootcount=$((bootcount - 1))
if [ $rootcount != $bootcount ]; then
	dd if=/dev/zero of=/boot/zerofill bs=1M count=$bootcount || echo "dd exit code $? suppressed"
	sync || echo "sync exit code $? suppressed"
	rm --force /boot/zerofill
fi

# If blkid is installed we use it to locate the swap partition.
if [ -f '/sbin/blkid' ]; then
	swapuuid="$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)"
else
	swapuuid=""
fi

# Whiteout the swap partition.
if [ -n "${swapuuid}" ]; then
	swappart="$(readlink -f /dev/disk/by-uuid/"$swapuuid")"
	/sbin/swapoff "$swappart"
	dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? suppressed"
	/sbin/mkswap -U "$swapuuid" "$swappart"
fi

# Sync to ensure that the delete completes before we move to the shutdown phase.
sync
sync
sync

echo "All done."
exit 0
