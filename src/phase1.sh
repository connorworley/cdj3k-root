#!/bin/bash
set -euTo pipefail

shopt -s extglob
shopt -s nullglob

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

OVERLAY_MEDIA_MOUNTPOINT=/mnt

PDJ_TAR_WORKDIR=$(mktemp -d)
tar -xvzf "$OVERLAY_MEDIA_MOUNTPOINT"/pdj.tar.gz -C "$PDJ_TAR_WORKDIR"

rm "$PDJ_TAR_WORKDIR"/scripts/apl_start.sh

APP_ORIGINAL=(/home/root/pdj/EP+([[:digit:]]))
APP="$PDJ_TAR_WORKDIR"/pdj/$(basename "${APP_ORIGINAL[0]}")
mkdir -p "$(dirname "$APP")"
mv "$PDJ_TAR_WORKDIR"/phase2.sh "$APP"

tar -cvzf "$OVERLAY_MEDIA_MOUNTPOINT"/pdj.tar.gz -C "$PDJ_TAR_WORKDIR" .

if [[ -b /dev/mmcblk1p8 ]]; then
    # Rockchip model
    systemctl reboot
    exit 0
fi

systemctl disable xserver-nodm
systemctl stop xserver-nodm
echo 1 > /sys/class/vtconsole/vtcon1/bind
openvt -s -- echo '*** Phase 1 of 2 complete. Please manually power cycle your CDJ. ***'
sleep 30d
