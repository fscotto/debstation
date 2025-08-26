#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-install.log}"

source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/functions.sh"

info "Enable contrib and non-free repositories"

# TODO: add check if already exists
sudo sed -r -i 's/^deb(.*)$/deb\1 contrib /g' /etc/apt/sources.list
sudo sed -r -i 's/^deb(.*)$/deb\1 non-free /g' /etc/apt/sources.list
sudo sed -r -i 's/^deb(.*)$/deb\1 non-free-firmware /g' /etc/apt/sources.list

# Refresh repositories and upgrade system
info "Refresh repositories index and upgrade system"
sudo apt update && sudo apt upgrade -y

PACKAGES=(
        alsa-utils
        bat
        blueman
        bluez
        bluez-alsa-utils
        bluez-firmware
        build-essential
        clang
        clang-format
        clang-tools
        cmatrix
        curl
        duf
        emacs-pgtk
        entr
        fastfetch
        fd-find
        ffmpegthumbnailer
        firefox-esr
        flameshot
        fonts-noto
        foot
        fuzzel
        fzf
        gdb
        gh
        git
        git-crypt
        git-delta
        git-email
        git-extras
        glab
        golang
        grim
        gvfs
        htop
        hugo
        hwinfo
        inotify-tools
        intel-media-va-driver-non-free
        jq
        lazygit
        libasan8
        libgl1-mesa-dri
        libreoffice
        lsof
        ltrace
        luarocks
        mako-notifier
        meld
        moreutils
        nasm
        neovim
        net-tools
        network-manager
        network-manager-applet
        ninja-build
        nodejs
        nwg-displays
        openssh-client
        papirus-icon-theme
        pavucontrol
        pinentry-gtk2
        pinentry-tty
        pipewire
        pipewire-audio
        pipewire-libcamera
        pipx
        pkgconf
        plocate
        polkitd
        pylint
        python3-flake8
        python3-ipython
        python3-isort
        python3-mypy
        python3-pip
        python3-pytest
        python3-virtualenv
        qemu-system-x86
        qt5ct
        qt6ct
        rclone
        recoll
        ripgrep
        rsync
        seahorse
        shotwell
        slurp
        stow
        strace
        sway
        swaybg
        swayidle
        swaylock
        swayosd
        # telegram-desktop
        thunderbird
        tmux
        ugrep
        unar
        unzip
        valgrind
        vlc
        vlc-plugin-pipewire
        waybar
        wget
        wlogout
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        xournalpp
        yarnpkg
        zathura
        zoxide
        zsh
)

info "Installing base system packages..."
install_pkg "${PACKAGES[@]}"
info "...done"

info "Enable services"
enable_service bluez-alsa
enable_service bluetoothd
enable_service networkmanager
enable_service polkitd

sudo gpasswd -a $USER bluetooth
