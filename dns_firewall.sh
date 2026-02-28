#!/bin/bash

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --set-target=DROP

# Allow DNS (TCP and UDP from port 53)
firewall-cmd --permanent --add-service=dns

# This is redundant but I wanted notes
firewall-cmd --permanent --add-port=53/udp

# Remove default services
firewall-cmd --permanent --remove-service=dhcpv6-client
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.14.0/24" service name="ssh" accept'

firewall-cmd --reload
firewall-cmd --list-all
