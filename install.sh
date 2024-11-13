#!/usr/bin/env bash
set -euo pipefail

# Color-coded logging functions
green="\033[0;32m"
yellow="\033[1;33m"
red="\033[0m" # No Color
nc="\033[0m" # No Color

log_info() {
  echo -e "${green}[INFO]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
  echo -e "${yellow}[WARNING]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
  echo -e "${red}[ERROR]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

print_and_execute() {
  echo -e "${green}+ $@${nc}"
  "$@"
}

# Variables
pkgdir="/tmp/fontinstaller"
dest_dir="/usr/share/fonts/applefonts"
pkgs=("p7zip-full" "curl")

# Check and install dependencies
check_dependencies() {
  for pkg in "${pkgs[@]}"; do
    if ! dpkg-query -W --showformat='${db:Status-Status}' "$pkg" &>/dev/null || [[ "$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg")" != "installed" ]]; then
      log_error "Dependency $pkg is not installed. Please install it for your distro."
      exit 1
    fi
  done
}

# Function to download and extract fonts if they aren't already installed
download_and_extract() {
  local url="$1"
  local pkg_name="$2"
  local font_name="$3" # Used to check if the font is already installed

  if find "$dest_dir" -name "*$font_name*" | grep -q .; then
    log_info "$font_name fonts are already installed. Skipping."
    return
  fi

  log_info "Downloading and extracting $font_name fonts..."
  print_and_execute curl -O "$url"
  print_and_execute 7z x "$pkg_name"

  # Find the extracted directory (assuming only one directory was extracted)
  local extracted_dir
  extracted_dir=$(find . -maxdepth 1 -type d -name "${pkg_name%.*}*" | head -n 1)
  
  if [[ -z "$extracted_dir" ]]; then
    log_error "Failed to find extracted directory for ${pkg_name}"
    return
  fi

  cd "$extracted_dir" || { log_error "Failed to change directory to ${extracted_dir}"; return; }
  
  # Find the .pkg file dynamically
  local pkg_file
  pkg_file=$(find . -maxdepth 1 -type f -name "*.pkg" | head -n 1)

  if [[ -z "$pkg_file" ]]; then
    log_error "No .pkg file found for $font_name. Skipping."
    cd ..
    return
  fi

  print_and_execute 7z x "$pkg_file" || { log_error "Extraction failed for $pkg_file"; cd ..; return; }
  print_and_execute 7z x 'Payload~' || { log_error "Failed to extract Payload for $pkg_file"; cd ..; return; }
  mv Library/Fonts/* "$pkgdir/fontfiles"
  cd .. || { log_error "Failed to return to parent directory"; return; }
}

# Check dependencies
check_dependencies

# Prepare directories
print_and_execute mkdir -p "$pkgdir/fontfiles"
print_and_execute mkdir -p "$dest_dir"

# Main font download and extraction process
cd "$pkgdir" || { log_error "Failed to change directory to $pkgdir"; exit 1; }

# Array of fonts with URL, package name, and font name
fonts=(
  "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg SF-Pro.dmg SF-Pro"
  "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg SF-Compact.dmg SF-Compact"
  "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg SF-Mono.dmg SF-Mono"
  "https://devimages-cdn.apple.com/design/resources/download/SF-Arabic.dmg SF-Arabic.dmg SF-Arabic"
  "https://devimages-cdn.apple.com/design/resources/download/NY.dmg NY.dmg NY"
)

for font in "${fonts[@]}"; do
  IFS=" " read -r url pkg_name font_name <<< "$font"
  download_and_extract "$url" "$pkg_name" "$font_name"
done

# Move fonts to the system directory if not already present
log_info "Moving fonts to $dest_dir"
print_and_execute sudo mkdir -p "$dest_dir"
print_and_execute sudo mv "$pkgdir/fontfiles"/* "$dest_dir" || log_info "All fonts are already installed. Skipping move step."

# Cleanup
log_info "Cleaning up temporary files"
print_and_execute sudo rm -rf "$pkgdir"

log_info "Fonts installation process completed!"
