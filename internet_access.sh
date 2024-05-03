#!/bin/bash -x


# On active le forwarding sur la machine
sysctl net.ipv4.conf.all.forwarding=1
sudo sysctl -w net.ipv4.conf.all.rp_filter=0

# attribuer une adresse internet
ip a add dev internet 10.87.0.254/24 

iptables -t nat -A POSTROUTING -s 10.87.0.0/24 -j MASQUERADE

# Les routes par défaut pour rA et rB
ip netns exec rA ip route add default via 10.87.0.254
ip netns exec rB ip route add default via 10.87.0.254

# On fait du SNAT pour les machines
ip netns exec rA iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -j MASQUERADE
ip netns exec rB iptables -t nat -A POSTROUTING -s 172.16.2.0/24 -j MASQUERADE

# Pareil pour R1 et R2
# r1
ip netns exec r1 iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
ip netns exec r1 iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -j MASQUERADE

# r2
ip netns exec r2 iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
ip netns exec r2 iptables -t nat -A POSTROUTING -s 192.168.200.0/24 -j MASQUERADE



