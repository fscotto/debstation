#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-install.log}"

source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/functions.sh"

info "Install required packages"

install_pkg software-properties-common

info "Enable contrib and non-free repositories"

sudo apt-add-repository contrib non-free-firmware non-free

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
  qemu
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
  telegram-desktop
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

info "Configuring $USER groups (docker, bluetooth)"

sudo gpasswd -a $USER docker
sudo gpasswd -a $USER bluetooth

success "Added $USER to groups bluetooth"
