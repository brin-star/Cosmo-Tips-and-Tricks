#!/bin/bash

systemctl enable firewalld
systemctl start firewalld

firewall-cmd --permanent --set-target=DROP

 firewall-cmd --permanent --add-service=dns

firewall-cmd --permanent --add-port=53/udp

firewall-cmd --reload

firewall-cmd --list-all