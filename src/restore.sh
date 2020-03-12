#!/bin/bash

CHANGED=0

for VER in "2.1" "3.0"; do
    FILE_TEMPLATE=/usr/lib/surface-go-wifi/template/hw$VER/board.bin
    FILE_DRIVER=/lib/firmware/ath10k/QCA6174/hw$VER/board.bin
    FILE_BACKUP=/usr/lib/surface-go-wifi/backup/hw$VER/board.bin

    if [[ -f $FILE_TEMPLATE ]]; then
        cmp --silent $FILE_TEMPLATE $FILE_DRIVER
        if [[ $? -ne 0 ]]; then
            cp $FILE_DRIVER $FILE_BACKUP
            cp $FILE_TEMPLATE $FILE_DRIVER
            echo "Restored Surface Go WiFi (hw$VER)"
            CHANGED=1
        fi
    fi
done

if [[ $CHANGED -ne 0 ]]; then
    echo "Reboot for changes to take effect."
fi

exit 0
