#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-install.log}"
source "$SCRIPT_DIR/../lib/logging.sh"

info "Configuring dotfiles..."

DOTFILES_REPO="https://github.com/fscotto/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  info "Cloning dotfiles repository"
  git clone --recursive "$DOTFILES_REPO" "$DOTFILES_DIR" >>"$LOG_FILE" 2>&1 && success "Dotfiles repo cloned" || {
    error "Error cloning dotfiles"
    exit 1
  }
else
  info "Dotfiles repo already exists, updating"
  (cd "$DOTFILES_DIR" && git pull) >>"$LOG_FILE" 2>&1 && success "Dotfiles repo updated" || warn "Error updating dotfiles"
fi

if ! command -v stow &>/dev/null; then
  info "Installing stow to manage dotfiles"
  install_pkg stow >>"$LOG_FILE" 2>&1 && success "stow installed" || {
    error "Error installing stow"
    exit 1
  }
fi

info "Applying selected dotfiles with stow"

# List only the dotfiles directories you want to install
declare -a DOTFILES_TO_INSTALL=(
  "bat"
  "doom"
  "fastfetch"
  "flameshot"
  "foot"
  "fuzzel"
  "git"
  "imv"
  "lazygit"
  "lazyvim"
  "mako"
  "mpd"
  "mpv"
  "newsboat"
  "sway"
  "tmux"
  "waybar"
  "yazi"
  "yt-dlp"
  "zathura"
  "zsh"
)

cd "$DOTFILES_DIR" || {
  error "Cannot cd to $DOTFILES_DIR"
  exit 1
}

for dotfile in "${DOTFILES_TO_INSTALL[@]}"; do
  if [[ -d "$dotfile" ]]; then
    info "Stowing $dotfile"
    stow --dotfiles -R --dir "$DOTFILES_DIR" --target="$HOME" "$dotfile" >>"$LOG_FILE" 2>&1 && success "Stowed $dotfile" || warn "Failed to stow $dotfile"
  else
    warn "Dotfile directory $dotfile not found, skipping"
  fi
done

# Change default shell to zsh if not already set and if zsh exists
if command -v zsh &>/dev/null; then
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    info "Changing default shell to zsh for user $USER"
    chsh -s "$(command -v zsh)" && success "Default shell changed to zsh" || warn "Failed to change default shell"
  else
    info "Default shell is already zsh"
  fi
else
  warn "zsh is not installed, skipping shell change"
fi

success "Dotfiles configuration completed"
