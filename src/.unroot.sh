#!/bin/bash
set -euTo pipefail

UPDATE_MEDIA_DEVICE=
UPDATE_MEDIA_MOUNTPOINT=

while read -r MOUNT; do
    DEVICE=$(echo "$MOUNT" | cut -d' ' -f1)
    MOUNTPOINT=$(echo "$MOUNT" | cut -d' ' -f2)
    if [[ -e $MOUNTPOINT/CDJ3Kv000.UPD ]]; then
        UPDATE_MEDIA_DEVICE=$DEVICE
        UPDATE_MEDIA_MOUNTPOINT=$MOUNTPOINT
        break
    fi
done < /proc/mounts

if [[ -n $UPDATE_MEDIA_DEVICE ]]; then
    mount -o remount,rw "$UPDATE_MEDIA_DEVICE" "$UPDATE_MEDIA_MOUNTPOINT"

    SCRIPT_NAME=$(basename "$0")
    exec >"$UPDATE_MEDIA_MOUNTPOINT"/"$SCRIPT_NAME".log
    exec 2>&1

    trap 'printf "[%s] %s: %s\n" "$(cut -d" " -f1 /proc/uptime)" "$SCRIPT_NAME" "${BASH_COMMAND:-}" 1>&2' DEBUG
fi

rm /mnt/pdj.tar.gz

if [[ -b /dev/mmcblk1p8 ]]; then
    # Rockchip model
    systemctl reboot
    exit 0
fi

systemctl disable xserver-nodm
systemctl stop xserver-nodm
echo 1 > /sys/class/vtconsole/vtcon1/bind
openvt -s -- echo '*** Unroot complete. Please manually power cycle your CDJ. ***'
sleep 30d
