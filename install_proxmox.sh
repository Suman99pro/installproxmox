#!/bin/bash

set -e

echo "Disabling CD-ROM repository if present..."
# Disable the CD-ROM repository
if grep -q "cdrom:" /etc/apt/sources.list; then
  sed -i '/cdrom:/s/^/#/' /etc/apt/sources.list
fi

echo "Adding missing repositories..."
# Ensure Debian Bullseye main repository is enabled
if ! grep -q "deb http://deb.debian.org/debian bullseye main contrib" /etc/apt/sources.list; then
  echo "deb http://deb.debian.org/debian bullseye main contrib" >> /etc/apt/sources.list
  echo "deb http://deb.debian.org/debian bullseye-updates main contrib" >> /etc/apt/sources.list
  echo "deb http://security.debian.org/debian-security bullseye-security main contrib" >> /etc/apt/sources.list
fi

echo "Updating package lists..."
apt update --fix-missing

echo "Upgrading the system..."
apt upgrade -y
apt full-upgrade -y

echo "Installing required tools..."
apt install -y wget curl gnupg software-properties-common

echo "Adding Proxmox VE repository..."
# Add Proxmox VE no-subscription repository
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve.list

echo "Adding Proxmox VE repository key..."
wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/proxmox-release.gpg

echo "Updating package lists..."
apt update --fix-missing

echo "Installing Proxmox VE and required dependencies..."
apt install -y proxmox-ve postfix open-iscsi || {
  echo "Attempting to resolve unmet dependencies..."
  apt --fix-broken install -y
  apt install -y proxmox-ve postfix open-iscsi
}

echo "Installation completed successfully. Please reboot the system."
