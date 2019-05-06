#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

#Whiteout partitions to reduce box size
partitions='/boot / /tmp /var /var/log /var/log/audit /home'
for partition in $partitions; do
    count=$(df --sync -kP ${partition} | tail -n1 | awk -F ' ' '{print $4}')
    count=$(($count-1))
    dd if=/dev/zero of=${partition}/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
    rm ${partition}/whitespace
done

set +e
swapuuid="`/sbin/blkid -o value -l -s UUID -t TYPE=swap`";
case "$?" in
    2|0) ;;
    *) exit 1 ;;
esac
set -e

if [ "x${swapuuid}" != "x" ]; then
    # Whiteout the swap partition to reduce box size
    # Swap is disabled till reboot
    swappart="`readlink -f /dev/disk/by-uuid/$swapuuid`";
    /sbin/swapoff "$swappart";
    dd if=/dev/zero of="$swappart" bs=1M || echo "dd exit code $? is suppressed";
    /sbin/mkswap -U "$swapuuid" "$swappart";
fi

sync;
