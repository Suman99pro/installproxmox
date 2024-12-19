#!/bin/bash

set -e

echo "Updating and upgrading the system..."
# Disable the CD-ROM repository if it exists
if grep -q "cdrom:" /etc/apt/sources.list; then
  echo "Disabling CD-ROM repository..."
  sed -i '/cdrom:/s/^/#/' /etc/apt/sources.list
fi

# Update the system
apt update --fix-missing
apt upgrade -y
apt full-upgrade -y

# Install required tools
echo "Installing required packages..."
apt install -y wget curl gnupg

# Add the Proxmox VE repository
echo "Adding Proxmox VE repository..."
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve.list

# Add the Proxmox VE repository key
echo "Adding Proxmox VE repository key..."
wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/proxmox-release.gpg

# Update package lists
echo "Updating package lists..."
apt update --fix-missing

# Install Proxmox VE
echo "Installing Proxmox VE..."
apt install -y proxmox-ve postfix open-iscsi

echo "Installation completed. Rebooting the system..."
reboot
