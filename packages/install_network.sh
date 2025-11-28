#!/bin/bash

# Install required packages
yay -S --noconfirm --needed wireguard-tools networkmanager networkmanager-openvpn

# Disable systemd-networkd if enabled
if systemctl is-enabled systemd-networkd &>/dev/null; then
    sudo systemctl disable systemd-networkd
    sudo systemctl stop systemd-networkd
fi

# Disable systemd-resolved if enabled
if systemctl is-enabled systemd-resolved &>/dev/null; then
    sudo systemctl disable systemd-resolved
    sudo systemctl stop systemd-resolved
fi

# Enable NetworkManager if not already enabled
if ! systemctl is-enabled NetworkManager.service &>/dev/null; then
    sudo systemctl enable NetworkManager.service
    sudo systemctl start NetworkManager.service
fi

# Set up resolv.conf symlink if not correct
if [ ! -L /etc/resolv.conf ] || [ "$(readlink /etc/resolv.conf)" != "/run/NetworkManager/resolv.conf" ]; then
    sudo rm -f /etc/resolv.conf
    sudo ln -s /run/NetworkManager/resolv.conf /etc/resolv.conf
fi

# Check if NetworkManager TUI is installed
DESKTOP_FILE="$HOME/.local/share/applications/NetworkManager.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "Installing NetworkManager TUI shortcut..."

    # Ensure directories exist
    ICON_DIR="$HOME/.local/share/applications/icons"
    mkdir -p "$ICON_DIR"

    # Download icon
    ICON_PATH="$ICON_DIR/NetworkManager.png"
    if curl -sL -o "$ICON_PATH" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/pi-alert.png"; then
        echo "Icon downloaded successfully."
    else
        echo "Failed to download icon."
        exit 1
    fi

    # Create desktop file
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Name=NetworkManager
Comment=NetworkManager TUI
Exec=xdg-terminal-exec -e nmtui
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
StartupWMClass=TUI.float
EOF

    chmod +x "$DESKTOP_FILE"
    echo "NetworkManager TUI shortcut created."
else
    echo "NetworkManager TUI shortcut already exists."
fi

# Confirm configuration
echo "Network configuration complete."
echo "systemd-networkd status: $(systemctl is-enabled systemd-networkd 2>/dev/null || echo 'disabled')"
echo "systemd-resolved status: $(systemctl is-enabled systemd-resolved 2>/dev/null || echo 'disabled')"
echo "NetworkManager status: $(systemctl is-enabled NetworkManager.service)"
echo "resolv.conf: $(ls -l /etc/resolv.conf | awk '{print $9, $10, $11}')"