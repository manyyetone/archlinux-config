#!/bin/sh

if [ "$(cat /sys/class/power_supply/AC0/online)" = "1" ]; then
    echo ""
fi
