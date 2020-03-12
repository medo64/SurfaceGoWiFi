#!/bin/bash

FILE1=/usr/lib/surface-go-wifi/board.bin
if [[ -f $FILE1 ]]; then
    for VER in "2.1" "3.0"; do
        FILE2=/lib/firmware/ath10k/QCA6174/hw$VER/board.bin
        FILE3=/usr/lib/surface-go-wifi/backup/hw$VER/board.bin
        cmp --silent $FILE1 $FILE2 || cp $FILE2 $FILE3 && cp $FILE1 $FILE2 && printf 'Restored Surface Go WiFi (%s). Reboot for changes to take effect.\n' $VER
    done
fi

exit 0