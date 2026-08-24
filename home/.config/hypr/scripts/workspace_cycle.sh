#!/bin/bash

MAX=10

CURRENT=$(hyprctl workspaces -j | jq '.[] | select(.focused==true) | .id')

NEXT=$((CURRENT + 1))

if [ "$NEXT" -gt "$MAX" ]; then
    NEXT=1
fi

hyprctl dispatch workspace "$NEXT"
