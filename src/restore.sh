#!/bin/bash

CHANGED_ANY=0

for HW in "hw2.1" "hw3.0"; do
    CHANGED_HW=0

    for FILE in `ls /usr/lib/surface-go-wifi/template/$HW/`; do
        FILE_TEMPLATE=/usr/lib/surface-go-wifi/template/$HW/$FILE
        FILE_DRIVER=/lib/firmware/ath10k/QCA6174/$HW/$FILE
        FILE_BACKUP=/usr/lib/surface-go-wifi/backup/$HW/$FILE

        if [[ -f $FILE_TEMPLATE ]]; then
            cmp --silent $FILE_TEMPLATE $FILE_DRIVER
            if [[ $? -ne 0 ]]; then
                cp $FILE_DRIVER $FILE_BACKUP
                cp $FILE_TEMPLATE $FILE_DRIVER
                CHANGED_HW=1
                CHANGED_ANY=1
            fi
        fi
    done

    if [[ $CHANGED_HW -ne 0 ]]; then
        echo "Restored Surface Go WiFi ($HW)"
    fi
done

if [[ $CHANGED_ANY -ne 0 ]]; then
    echo "Reboot for changes to take effect."
fi

exit 0
