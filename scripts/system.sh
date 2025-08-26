#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-install.log}"

source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/functions.sh"

info "Enable contrib and non-free repositories"

# Add contrib if not present
# if ! grep -q '\bcontrib\b' /etc/apt/sources.list; then
sudo sed -r -i 's/^deb(.*)$/deb\1 contrib /g' /etc/apt/sources.list
info "Added contrib repository to sources.list"
# else
#   info "contrib already present in sources.list"
# fi

# Add non-free if not present
# if ! grep -q '\bnon-free\b' /etc/apt/sources.list; then
sudo sed -r -i 's/^deb(.*)$/deb\1 non-free /g' /etc/apt/sources.list
info "Added non-free repository to sources.list"
# else
#   info "non-free already present in sources.list"
# fi

# Add non-free-firmware if not present
# if ! grep -q '\bnon-free-firmware\b' /etc/apt/sources.list; then
sudo sed -r -i 's/^deb(.*)$/deb\1 non-free-firmware /g' /etc/apt/sources.list
info "Added non-free-firmware repository to sources.list"
# else
#   info "non-free-firmware already present in sources.list"
# fi

# Refresh repositories and upgrade system
info "Refresh repositories index and upgrade system"
sudo apt update && sudo apt upgrade -y

# telegram-desktop
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
  cliphist
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
  hexyl
  htop
  hugo
  hwinfo
  imv
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
  miller
  moreutils
  mpd
  mpv
  nasm
  neomutt
  neovim
  net-tools
  network-manager
  network-manager-applet
  newsboat
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
  wl-clipboard
  wlogout
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  xournalpp
  yarnpkg
  yt-dlp
  zathura
  zathura-djvu
  zathura-ps
  zoxide
  zsh
)

info "Installing base system packages..."
install_pkg "${PACKAGES[@]}"
info "...done"

info "Configure packages"
batcat cache --build

info "Installing Doom Emacs"
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

info "Enable services"
enable_service bluez-alsa
enable_service bluetoothd
enable_service networkmanager
enable_service polkitd

sudo gpasswd -a $USER bluetooth
