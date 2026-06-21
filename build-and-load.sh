#!/bin/bash
set -e

KO_DIR="/var/home/enes/Apps/ryzen_smu"
MARKER="$KO_DIR/.built-for-kernel"
CURRENT_KERNEL="$(uname -r)"

if [[ -f "$MARKER" ]] && [[ "$(cat "$MARKER")" == "$CURRENT_KERNEL" ]]; then
    echo "ryzen_smu.ko already built for $CURRENT_KERNEL, skipping rebuild."
else
    echo "Kernel changed (or first run) - rebuilding in distrobox..."
    distrobox enter gigabyte_it87 -- bash -c "
        set -e
        sudo dnf install -y kernel-devel-\$(uname -r)
        cd '$KO_DIR'
        make clean
        make
    "
    echo "$CURRENT_KERNEL" > "$MARKER"
fi

sudo rmmod ryzen_smu 2>/dev/null || true
sudo insmod "$KO_DIR/ryzen_smu.ko"
