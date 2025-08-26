#!/usr/bin/env bash

IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging.sh"

# install_pkg() - Installs multiple Debian GNU/Linux packages at once.
# Arguments: Takes a space-separated list of package names as arguments.
# Example: install_pkg "package1" "package2" "package3"
# Or: install_pkg "${PACKAGES[@]}"
install_pkg() {
  # Ensure at least one package name is provided
  if [ "$#" -eq 0 ]; then
    warn "No packages passed to the install_pkg function."
    return 1
  fi

  info "Updating package list..."
  sudo apt update | tee -a "$LOG_FILE"

  info "Installing packages: $*"
  for pkg in "$@"; do
    info "Installing $pkg..."
    sudo apt install --assume-yes "$pkg" 2>&1 | tee -a "$LOG_FILE"
    if [ "${PIPESTATUS[0]}" -ne 0 ]; then
      warn "Installation of $pkg failed. Check $LOG_FILE for details."
      return 1
    else
      info "$pkg installed successfully."
    fi
  done

  return 0
}

enable_service() {
  service="$1"
  info "Enable $service service"
  if sudo systemctl enable --now "$service"; then
    warn "Failed to enable $service service"
    return 0
  fi
  return 0
}
