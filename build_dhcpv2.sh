#!/bin/bash -x

# run DHCP sever
#vlan 100
sudo ip netns exec r1 dnsmasq -d -z -i r1-eth1.100 --dhcp-range=192.168.100.1,192.168.100.100,255.255.255.0
#vlan 200
sudo ip netns exec r1 dnsmasq -d -z -i r1-eth1.200 --dhcp-range=192.168.200.1,192.168.200.100,255.255.255.0

# connect to get IP address
sudo ip netns exec p1 dhclient p1-eth0.100
sudo ip netns exec p2 dhclient p2-eth0.200
sudo ip netns exec p3 dhclient p3-eth0.100
sudo ip netns exec p4 dhclient p4-eth0.200