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
    warn "No packages provided to install_pkg function."
    return 1
  fi

  sudo apt update && sudo apt install -y "$@" >>"$LOG_FILE" 2>&1
  return 0 # Indicate success
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
