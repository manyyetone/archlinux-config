#!/usr/bin/env bash
set -euo pipefail

BACKUP="$HOME/archlinux-backup"

mkdir -p "$BACKUP"/{home/.config,etc,system,packages,services,scripts,hardware}

echo "==> Package lists"

pacman -Qqe > "$BACKUP/packages/pacman-explicit.txt"

if command -v yay >/dev/null 2>&1; then
    yay -Qqm > "$BACKUP/packages/aur.txt"
elif command -v paru >/dev/null 2>&1; then
    paru -Qqm > "$BACKUP/packages/aur.txt"
else
    : > "$BACKUP/packages/aur.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application > "$BACKUP/packages/flatpak.txt"
else
    : > "$BACKUP/packages/flatpak.txt"
fi

echo "==> Hardware/system information"

uname -a > "$BACKUP/hardware/uname.txt"
lscpu > "$BACKUP/hardware/lscpu.txt"
lsblk -f > "$BACKUP/hardware/lsblk.txt"
lspci -nnk > "$BACKUP/hardware/lspci-nnk.txt"
lsusb > "$BACKUP/hardware/lsusb.txt"
lsmod > "$BACKUP/hardware/lsmod.txt"
rfkill list > "$BACKUP/hardware/rfkill.txt"

echo "==> Services"

systemctl list-unit-files --state=enabled \
    > "$BACKUP/services/system-enabled.txt"

systemctl --user list-unit-files --state=enabled \
    > "$BACKUP/services/user-enabled.txt"

systemctl list-timers --all \
    > "$BACKUP/services/system-timers.txt"

systemctl --user list-timers --all \
    > "$BACKUP/services/user-timers.txt"

echo "==> User configuration"

CONFIG="$BACKUP/home/.config"

# Desktop / window manager
for dir in \
    hypr \
    waybar \
    swaylock \
    swaync \
    mako \
    rofi \
    wofi
do
    [ -d "$HOME/.config/$dir" ] && cp -a "$HOME/.config/$dir" "$CONFIG/"
done

# Shell / terminal
for dir in \
    fish \
    kitty \
    ghostty \
    btop \
    htop
do
    [ -d "$HOME/.config/$dir" ] && cp -a "$HOME/.config/$dir" "$CONFIG/"
done

# Audio
for dir in \
    wireplumber \
    pulse
do
    [ -d "$HOME/.config/$dir" ] && cp -a "$HOME/.config/$dir" "$CONFIG/"
done

# GTK / Qt appearance
for dir in \
    gtk-3.0 \
    gtk-4.0 \
    qt5ct \
    qt6ct \
    xsettingsd \
    themes \
    fontconfig
do
    [ -d "$HOME/.config/$dir" ] && cp -a "$HOME/.config/$dir" "$CONFIG/"
done

# Other configuration-only applications
for dir in \
    mpv \
    btop \
    procps \
    mimeapps.list
do
    if [ -d "$HOME/.config/$dir" ]; then
        cp -a "$HOME/.config/$dir" "$CONFIG/"
    elif [ -f "$HOME/.config/$dir" ]; then
        cp -a "$HOME/.config/$dir" "$CONFIG/"
    fi
done

# Starship
[ -f "$HOME/.config/starship.toml" ] && \
    cp -a "$HOME/.config/starship.toml" "$CONFIG/"

# VS Code: configuration only
if [ -d "$HOME/.config/Code/User" ]; then
    mkdir -p "$CONFIG/Code/User"

    [ -f "$HOME/.config/Code/User/settings.json" ] &&
        cp "$HOME/.config/Code/User/settings.json" "$CONFIG/Code/User/"

    [ -f "$HOME/.config/Code/User/keybindings.json" ] &&
        cp "$HOME/.config/Code/User/keybindings.json" "$CONFIG/Code/User/"
fi

# VS Code extensions
if command -v code >/dev/null 2>&1; then
    code --list-extensions > "$BACKUP/packages/vscode-extensions.txt"
fi

echo "==> Shell dotfiles"

for file in \
    .bashrc \
    .bash_profile \
    .profile \
    .zshrc \
    .gitconfig \
    .gitignore_global \
    .vimrc \
    .inputrc \
    .tmux.conf
do
    [ -f "$HOME/$file" ] && cp -a "$HOME/$file" "$BACKUP/"
done

echo "==> User scripts"

if [ -d "$HOME/.local/bin" ]; then
    cp -a "$HOME/.local/bin" "$BACKUP/scripts/"
fi

echo "==> System configuration"

# Only configuration files, not entire /etc directories.
for file in \
    /etc/fstab \
    /etc/hostname \
    /etc/locale.conf \
    /etc/vconsole.conf \
    /etc/mkinitcpio.conf \
    /etc/pacman.conf
do
    [ -f "$file" ] && sudo cp "$file" "$BACKUP/etc/"
done

# Custom configuration directories only.
for dir in \
    /etc/modprobe.d \
    /etc/modules-load.d \
    /etc/udev/rules.d
do
    [ -d "$dir" ] && sudo cp -a "$dir" "$BACKUP/etc/"
done

# Custom systemd units.
if [ -d /etc/systemd/system ]; then
    mkdir -p "$BACKUP/system/systemd"
    find /etc/systemd/system \
        -maxdepth 1 \
        -type f \
        -name '*.service' \
        -o -name '*.timer' \
        -o -name '*.path' \
        -o -name '*.socket' \
        2>/dev/null |
    while read -r file; do
        sudo cp "$file" "$BACKUP/system/systemd/"
    done
fi

echo "==> Creating manifest"

find "$BACKUP" -type f -readable | sort > "$BACKUP/MANIFEST.txt"

echo
echo "======================================"
echo " Configuration backup complete"
echo "======================================"
echo
du -sh "$BACKUP"
echo
echo "Files:"
wc -l "$BACKUP/MANIFEST.txt"