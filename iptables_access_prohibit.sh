#!/bin/bash -x

# Sur R1, on bloque les paquets inter-vlans
ip netns exec r1 iptables -t filter -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24  -j DROP
ip netns exec r1 iptables -t filter -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24  -j DROP

# Pareil sur R2
ip netns exec r2 iptables -t filter -A FORWARD -s 192.168.200.0/24 -d 192.168.100.0/24  -j DROP
ip netns exec r2 iptables -t filter -A FORWARD -s 192.168.100.0/24 -d 192.168.200.0/24  -j DROP