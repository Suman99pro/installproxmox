#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update and upgrade system
echo "Updating and upgrading the system..."
apt update && apt upgrade -y

# Install necessary packages
echo "Installing required packages..."
apt install -y gnupg wget curl

# Add Proxmox repository
echo "Adding Proxmox VE repository..."
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve.list

# Add Proxmox key
echo "Adding Proxmox VE repository key..."
wget -qO- https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/proxmox-release.gpg

# Update package lists
echo "Updating package lists..."
apt update

# Install Proxmox VE
echo "Installing Proxmox VE..."
apt install -y proxmox-ve postfix open-iscsi

# Configure /etc/hosts
echo "Configuring /etc/hosts..."
read -p "Enter the server's hostname (e.g., proxmox): " hostname
read -p "Enter the server's IP address: " ip_address
echo "$ip_address $hostname" >> /etc/hosts
echo "$hostname" > /etc/hostname

# Disable subscription nag
echo "Disabling Proxmox VE subscription nag screen..."
sed -i "s|deb http://enterprise.proxmox.com/debian/pve bullseye pve-enterprise|# deb http://enterprise.proxmox.com/debian/pve bullseye pve-enterprise|" /etc/apt/sources.list

# Reboot prompt
echo "Proxmox VE installation completed. It's recommended to reboot the server now."
read -p "Would you like to reboot now? (y/n): " reboot_now
if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
  reboot
else
  echo "Please reboot the server manually to complete the installation."
fi
