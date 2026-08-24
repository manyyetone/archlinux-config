#!/bin/bash
hyprctl activeworkspace -j | grep '"id"' | head -1 | grep -o '[0-9]\+'
