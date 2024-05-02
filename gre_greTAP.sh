#!/bin/bash -x

#on fait du cleaning pour r1 et r2
ip netns exec r1 ip link del r1-eth1.100
ip netns exec r1 ip link del r1-eth1.200
ip netns exec r2 ip link del r2-eth1.100
ip netns exec r2 ip link del r2-eth1.200
ip netns exec r1 ip a flush dev r1-eth1
ip netns exec r2 ip a flush dev r2-eth1

#Ajout du tunnel GRE

#sur R1
ip netns exec r1 ip link add eoip1 type gretap remote 172.16.2.253 local 172.16.1.253 nopmtudisc
ip netns exec r1 ip link set eoip1 up
ip netns exec r1 brctl addbr tunnel
ip netns exec r1 brctl addif tunnel eoip1
ip netns exec r1 brctl addif tunnel r1-eth1
ip netns exec r1 ip link set tunnel up
ip netns exec r1 ip link add link tunnel name tunnel.100 type vlan id 100
ip netns exec r1 ip link set tunnel.100 up
ip netns exec r1 ip link add link tunnel name tunnel.200 type vlan id 200
ip netns exec r1 ip link set tunnel.200 up
ip netns exec r1 ip addr add 192.168.100.254/24 dev tunnel.100
ip netns exec r1 ip addr add 192.168.200.254/24 dev tunnel.200

# Sur R2
ip netns exec r2 ip link add eoip1 type gretap remote 172.16.1.253 local 172.16.2.253 nopmtudisc
ip netns exec r2 ip link set eoip1 up
ip netns exec r2 brctl addbr tunnel
ip netns exec r2 brctl addif tunnel eoip1
ip netns exec r2 brctl addif tunnel r2-eth1
ip netns exec r2 ip link set tunnel up
ip netns exec r2 ip link add link tunnel name tunnel.100 type vlan id 100
ip netns exec r2 ip link set tunnel.100 up
ip netns exec r2 ip link add link tunnel name tunnel.200 type vlan id 200
ip netns exec r2 ip link set tunnel.200 up
ip netns exec r2 ip addr add 192.168.100.253/24 dev tunnel.100
ip netns exec r2 ip addr add 192.168.200.253/24 dev tunnel.200
