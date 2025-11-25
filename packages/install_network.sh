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

# Confirm configuration
echo "Network configuration complete."
echo "systemd-networkd status: $(systemctl is-enabled systemd-networkd 2>/dev/null || echo 'disabled')"
echo "systemd-resolved status: $(systemctl is-enabled systemd-resolved 2>/dev/null || echo 'disabled')"
echo "NetworkManager status: $(systemctl is-enabled NetworkManager.service)"
echo "resolv.conf: $(ls -l /etc/resolv.conf | awk '{print $9, $10, $11}')"