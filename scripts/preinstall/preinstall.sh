#!/bin/bash

# Color definitions
RESET="\033[0m"
BLUE="\033[1;34m"   # Blue
GREEN="\033[1;32m"  # Green
YELLOW="\033[1;33m" # Yellow
RED="\033[1;31m"    # Red
PURPLE="\033[1;35m" # Purple for debug

# Emoji definitions
INFO_EMOJI=""
SUCCESS_EMOJI="✔  "
WARN_EMOJI="⚠️ "
ERROR_EMOJI="✘  "
DEBUG_EMOJI="🐛 "

# Log function
log() {
  local level=$1
  local message=$2

  # Using a switch-like statement to define the color and emoji based on the level
  case $level in
  info)
    color=$BLUE
    emoji=$INFO_EMOJI
    ;;
  success)
    color=$GREEN
    emoji=$SUCCESS_EMOJI
    ;;
  warn)
    color=$YELLOW
    emoji=$WARN_EMOJI
    ;;
  error)
    color=$RED
    emoji=$ERROR_EMOJI
    ;;
  debug)
    color=$PURPLE
    emoji=$DEBUG_EMOJI
    ;;
  *)
    color=$RESET # Default to 'info'
    emoji=$INFO_EMOJI
    ;;
  esac

  # Display the message with the color and prefixed emoji
  echo -e "${color}${emoji}$message$RESET"
}

# Usage examples
# log "info" "Starting the installation process for package X."
# log "success" "Package X has been installed successfully!"
# log "warn" "The current version of package Y might be *outdated*."
# log "error" "Failed to install package Z."
# log "debug" "This is a generic debugging message."
# log "undefined" "This message should appear as info, since 'undefined' is not defined."

# Global variable to store the package check status
APT_UPDATED=false

# Função para verificar pacotes do sistema, usando variável global
check_system_packages() {
  if [ "$APT_UPDATED" = false ]; then
    log "info" "🔍 Checking system packages..."
    sudo apt update -y
    echo -e "\n"
    APT_UPDATED=true
  fi
}

# Function to install or update essential packages
install_package() {
  PACKAGE=$1

  # Calls the package check function
  check_system_packages

  log "info" "📦 Checking if package \`$PACKAGE\` is installed or needs updating."

  # Check if the package is installed
  if dpkg -l | grep -q $PACKAGE; then
    # If the package is installed, check the version
    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' $PACKAGE)
    # log "info" "🔧 $PACKAGE is already installed. Checking for updates..."

    # Update the package if needed
    sudo apt install --only-upgrade $PACKAGE -y >/dev/null 2>&1

    # Check the version after the update
    UPDATED_VERSION=$(dpkg-query -W -f='${Version}' $PACKAGE)

    # If the version was updated, show success
    if [ "$INSTALLED_VERSION" != "$UPDATED_VERSION" ]; then
      log "success" "$PACKAGE updated to version $UPDATED_VERSION!"
    else
      log "success" "You are already using the latest version of $PACKAGE ($INSTALLED_VERSION).\n"
    fi
  else
    # If the package is not installed, install it
    log "info" "🚨 $PACKAGE not found. Installing..."
    sudo apt install $PACKAGE -y >/dev/null 2>&1 && log "success" "$PACKAGE installed successfully\n" || log "error" "Failed to install $PACKAGE\n"
  fi
}

# Function to install NVM (Node Version Manager)
install_nvm() {
  log "info" "📦 Checking the \`NVM\` package for installation or updates..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

  # Load NVM for the current session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads NVM
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads NVM autocomplete

  log "success" "NVM installed successfully!"
}

# Function to install or update NVM
install_or_update_nvm() {
  log "info" "📦 Checking \`NVM\` for installation or updates..."

  LATEST_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)",/\1/')
  LATEST_VERSION=${LATEST_VERSION#v} # Remove the 'v' from the version

  # Load NVM to ensure we can check the version
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads NVM

  # If NVM is not installed, call the function to install it
  if ! command -v nvm &>/dev/null; then
    install_nvm
  else
    INSTALLED_VERSION=$(nvm -v)
    # If the installed version is not the latest, update NVM
    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
      log "info" "🔧 Updating NVM..."
      install_nvm
      log "success" "NVM updated to version $LATEST_VERSION!\n"
    else
      log "success" "You are already using the latest version of NVM ($INSTALLED_VERSION).\n"
    fi
  fi
}

# Function to update NPM
update_npm() {
  log "info" "📦 Checking NPM for installation or updates..."

  # Check the installed version of NPM
  INSTALLED_VERSION=$(npm -v)

  # Get the latest version of NPM
  LATEST_VERSION=$(npm show npm version)

  # Compare the versions
  if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    log "info" "🔧 Updating NPM..."
    npm install --global npm@latest || log "error" "Failed to update NPM"
    log "success" "NPM updated to version $LATEST_VERSION!\n"
  else
    log "success" "You are already using the latest version of NPM ($INSTALLED_VERSION).\n"
  fi
}

# Main function
main() {
  install_package "build-essential"
  install_package "curl"
  install_package "wget"
  install_package "git"

  install_or_update_nvm

  update_npm

  log "success" "Project dependencies installation and configuration completed successfully."
}

# Run the main function
main
