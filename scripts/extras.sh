#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${LOG_FILE:-install.log}"

source "$SCRIPT_DIR/../lib/logging.sh"
source "$SCRIPT_DIR/../lib/functions.sh"

# --- Mise configuration and plugin installation ---
info "Installing Mise core plugins and tools..."
sudo apt update -y && sudo apt install -y gpg sudo wget curl
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update
sudo apt install -y mise

plugins=(
  java
)
for plugin in "${plugins[@]}"; do
  info "Installing Mise plugin: $plugin"
  mise use -g -y "$plugin" >>"$LOG_FILE" 2>&1 || warn "Failed to install Mise plugin: $plugin"
done

info "Installing pinned versions of Java and Python..."
mise install -y java@temurin-17 >>"$LOG_FILE" 2>&1 || warn "Failed to install java@temurin-17"

# Define the expected home directory for asdf.
asdf_home="$HOME/.asdf"
mise_data_target="${MISE_DATA_DIR:-$HOME/.local/share/mise}"

# --- Main logic to manage the ~/.asdf symlink ---

# 1. Handle old asdf-vm directory: if .asdf is a directory, rename it.
if [ -d "$asdf_home" ] && [ ! -L "$asdf_home" ]; then
  warn "Old ASDF directory found. Renaming to .asdf.old"
  mv "$asdf_home" "$asdf_home.old"
fi

# 2. Create or update the symlink.
#    - If $asdf_home does not exist, it creates it.
#    - If $asdf_home exists and is a file (not dir/symlink), it removes it and creates.
#    - If $asdf_home exists and is a symlink (correct or not), it updates/recreates it.
#    - The only case this does NOT handle is if $asdf_home was a directory (handled above).
ln -sfn "$mise_data_target" "$asdf_home"

# 3. Provide feedback based on the outcome.
if [ -L "$asdf_home" ] && [ "$(readlink "$asdf_home")" = "$mise_data_target" ]; then
  # Check if the symlink now exists and points correctly
  success "Symlink created/ensured: ~/.asdf → $mise_data_target"
else
  # This 'else' would only be hit if ln -sfn failed for some reason (e.g., permissions)
  # or if $asdf_home somehow became a directory again after 'mv'.
  warn "Could not ensure symlink ~/.asdf points to $mise_data_target. Manual inspection required."
fi

success "Mise setup completed successfully."

info "Install Docker from official repository"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove $pkg
done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo gpasswd -a $USER bluetooth
info "Docker installed"

info "Install Spotify"
curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client
info "Spotify installed"

info "Install Yazi file manager"
# Add GPG key
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
# Add repository
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
# Update package list
sudo apt update && sudo apt install -y yazi
info "Yazi installed"
