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

if [[ -z $UPDATE_MEDIA_DEVICE ]]; then
    echo "Couldn't locate update media"
    exit 1
fi

mount -o remount,rw "$UPDATE_MEDIA_DEVICE" "$UPDATE_MEDIA_MOUNTPOINT"

SCRIPT_NAME=$(basename "$0")
exec >"$UPDATE_MEDIA_MOUNTPOINT"/"$SCRIPT_NAME".log
exec 2>&1

trap 'printf "[%s] %s: %s\n" "$(cut -d" " -f1 /proc/uptime)" "$SCRIPT_NAME" "${BASH_COMMAND:-}" 1>&2' DEBUG

ISO_MOUNTPOINT=$1
LANGUAGE=$2

function safe_cp() {
    SRC=$1
    DST=$2

    mkdir -p "$(dirname "$DST")"
    cp "$SRC" "$DST"
}

function install_phase1() {
    OVERLAY_MEDIA=$1

    OVERLAY_MEDIA_MOUNTPOINT=$(mktemp -d)
    ls "$OVERLAY_MEDIA_MOUNTPOINT"
    mount -o rw "$OVERLAY_MEDIA" "$OVERLAY_MEDIA_MOUNTPOINT"

    PDJ_TAR_WORKDIR=$(mktemp -d)

    safe_cp $"$ISO_MOUNTPOINT"/phase1.sh  "$PDJ_TAR_WORKDIR"/scripts/apl_start.sh
    safe_cp $"$ISO_MOUNTPOINT"/phase2.sh  "$PDJ_TAR_WORKDIR"/phase2.sh
    safe_cp $"$ISO_MOUNTPOINT"/payload.sh "$PDJ_TAR_WORKDIR"/payload.sh
    safe_cp $"$ISO_MOUNTPOINT"/.unroot.sh "$PDJ_TAR_WORKDIR"/.unroot.sh

    safe_cp $"$UPDATE_MEDIA_MOUNTPOINT"/authorized_keys "$PDJ_TAR_WORKDIR"/.ssh/authorized_keys

    tar -cvzf "$OVERLAY_MEDIA_MOUNTPOINT"/pdj.tar.gz -C "$PDJ_TAR_WORKDIR" .
    umount "$OVERLAY_MEDIA_MOUNTPOINT"
}

if [[ -b /dev/mmcblk0p5 ]]; then
    # Renesas model
    install_phase1 /dev/mmcblk0p5
    gui_image D007 "$LANGUAGE" "" >/dev/null 2>&1
elif [[ -b /dev/mmcblk1p8 ]]; then
    # Rockchip model
    install_phase1 /dev/mmcblk1p8
    pkill gui_image
    gui_image D007 "$LANGUAGE" >/dev/null 2>&1 &
else
    echo "Unknown MMC partition layout"
    exit 1
fi
