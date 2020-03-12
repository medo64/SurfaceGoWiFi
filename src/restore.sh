#!/bin/bash

CHANGED=0

for VER in "2.1" "3.0"; do
    FILE1=/usr/lib/surface-go-wifi/template/hw$VER/board.bin
    if [[ -f $FILE1 ]]; then
        FILE2=/lib/firmware/ath10k/QCA6174/hw$VER/board.bin
        FILE3=/usr/lib/surface-go-wifi/backup/hw$VER/board.bin
        cmp --silent $FILE1 $FILE2
        if [[ $? -ne 0 ]]; then
            cp $FILE2 $FILE3
            cp $FILE1 $FILE2
            echo "Restored Surface Go WiFi (hw$VER)"
            CHANGED=1
        fi
    fi
done

if [[ $CHANGED -ne 0 ]]; then
    echo "Reboot for changes to take effect."
fi

exit 0
