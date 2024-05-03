#!/bin/bash -x

# run DHCP sever
#ROuteur 1
#vlan 100
sudo ip netns exec r1 dnsmasq -d -z -i tunnel.100 --dhcp-range=192.168.100.1,192.168.100.100,255.255.255.0 --dhcp-option=option:router,192.168.100.254
#vlan 200
sudo ip netns exec r1 dnsmasq -d -z -i tunnel.200 --dhcp-range=192.168.200.1,192.168.200.100,255.255.255.0 --dhcp-option=option:router,192.168.200.254


#Routeur 2
#vlan 100
sudo ip netns exec r2 dnsmasq -d -z -i tunnel.100 --dhcp-range=192.168.100.1,192.168.100.100,255.255.255.0 --dhcp-option=option:router,192.168.100.253
#vlan 200
sudo ip netns exec r2 dnsmasq -d -z -i tunnel.200 --dhcp-range=192.168.200.1,192.168.200.100,255.255.255.0 --dhcp-option=option:router,192.168.200.253


# connect to get IP address
sudo ip netns exec p1 dhclient p1-eth0.100
sudo ip netns exec p2 dhclient p2-eth0.200
sudo ip netns exec p3 dhclient p3-eth0.100
sudo ip netns exec p4 dhclient p4-eth0.200