#!/bin/bash -eux

# Randomize the root password and then lock the root account.
LOCKPWD=$(dd if=/dev/urandom count=128 status=none | md5sum | awk -F' ' '{print $1}')
printf '%s\n%s\n' "$LOCKPWD" "$LOCKPWD" | passwd root
passwd --lock root
