#!/bin/bash -x

# Namespaces
ip netns add r1
ip netns add r2
ip netns add rA
ip netns add rB

ip netns add p1
ip netns add p2
ip netns add p3
ip netns add p4

# Ajout des Switches
ovs-vsctl add-br internet
ovs-vsctl add-br resB
ovs-vsctl add-br resC
ovs-vsctl add-br resD
ovs-vsctl add-br resE

# COnfiguration initiale de r1
ip link add r1-eth0 type veth peer name resC-r1
ip link add r1-eth1 type veth peer name resD-r1
ip link set r1-eth0 netns r1
ip link set r1-eth1 netns r1
ovs-vsctl add-port resC resC-r1
ovs-vsctl add-port resD resD-r1
ip link set dev resC-r1 up
ip link set dev resD-r1 up
ip netns exec r1 ip link set dev lo up
ip netns exec r1 ip link set dev r1-eth0 up
ip netns exec r1 ip link set dev r1-eth1 up
ip netns exec r1 ip a add dev r1-eth0 172.16.1.253/24
ip netns exec r1 ip r add default via 172.16.1.254 dev r1-eth0
ip netns exec r1 sudo sysctl net.ipv4.conf.all.forwarding=1


# configuration initiale de R2
ip link add r2-eth0 type veth peer name resB-r2
ip link add r2-eth1 type veth peer name resE-r2
ip link set r2-eth0 netns r2
ip link set r2-eth1 netns r2
ovs-vsctl add-port resB resB-r2
ovs-vsctl add-port resE resE-r2
ip link set dev resB-r2 up
ip link set dev resE-r2 up
ip netns exec r2 ip link set dev lo up
ip netns exec r2 ip link set dev r2-eth0 up
ip netns exec r2 ip link set dev r2-eth1 up
ip netns exec r2 ip a add dev r2-eth0 172.16.2.253/24
ip netns exec r2 ip r add default via 172.16.2.254 dev r2-eth0
ip netns exec r2 sudo sysctl net.ipv4.conf.all.forwarding=1

# COnfiguration de RA
ip link add rA-eth0 type veth peer name resC-rA
ip link add rA-eth1 type veth peer name internet-rA
ip link set rA-eth0 netns rA
ip link set rA-eth1 netns rA
ovs-vsctl add-port resC resC-rA
ovs-vsctl add-port internet internet-rA
ip link set dev resC-rA up
ip link set dev internet-rA up
ip netns exec rA ip link set dev lo up
ip netns exec rA ip link set dev rA-eth0 up
ip netns exec rA ip link set dev rA-eth1 up
ip netns exec rA ip a add dev rA-eth0 172.16.1.254/24
ip netns exec rA ip a add dev rA-eth1 10.87.0.1/24
ip netns exec rA sudo sysctl net.ipv4.conf.all.forwarding=1

# Configuration de RB
ip link add rB-eth0 type veth peer name resB-rB
ip link add rB-eth1 type veth peer name internet-rB
ip link set rB-eth0 netns rB
ip link set rB-eth1 netns rB
ovs-vsctl add-port resB resB-rB
ovs-vsctl add-port internet internet-rB
ip link set dev resB-rB up
ip link set dev internet-rB up
ip netns exec rB ip link set dev lo up
ip netns exec rB ip link set dev rB-eth0 up
ip netns exec rB ip link set dev rB-eth1 up
ip netns exec rB ip a add dev rB-eth0 172.16.2.254/24
ip netns exec rB ip a add dev rB-eth1 10.87.0.2/24
ip netns exec rB sudo sysctl net.ipv4.conf.all.forwarding=1

#LES DIFFERENTS POSTES
#P1
ip link add p1-eth0 type veth peer name resE-p1
ip link set p1-eth0 netns p1
ovs-vsctl add-port resE resE-p1
ip link set dev resE-p1 up
ip netns exec p1 ip link set dev p1-eth0 up
ip netns exec p1 ip link set dev lo up
#vlan sur P1
ip netns exec p1 ip link add link p1-eth0 name p1-eth0.100 type vlan id 100
ip netns exec p1 ip link set p1-eth0.100 up
ip netns exec p1 ip addr add 192.168.100.1/24 dev p1-eth0.100

#P2
ip link add p2-eth0 type veth peer name resE-p2
ip link set p2-eth0 netns p2
ovs-vsctl add-port resE resE-p2
ip link set dev resE-p2 up
ip netns exec p2 ip link set dev p2-eth0 up
ip netns exec p2 ip link set dev lo up
#vlan sur P2
ip netns exec p2 ip link add link p2-eth0 name p2-eth0.200 type vlan id 200
ip netns exec p2 ip link set p2-eth0.200 up
ip netns exec p2 ip addr add 192.168.200.1/24 dev p2-eth0.200

#P3
ip link add p3-eth0 type veth peer name resD-p3
ip link set p3-eth0 netns p3
ovs-vsctl add-port resD resD-p3
ip link set dev resD-p3 up
ip netns exec p3 ip link set dev p3-eth0 up
ip netns exec p3 ip link set dev lo up
#Vlan sur P3
ip netns exec p3 ip link add link p3-eth0 name p3-eth0.100 type vlan id 100
ip netns exec p3 ip link set p3-eth0.100 up
ip netns exec p3 ip addr add 192.168.100.2/24 dev p3-eth0.100

#P4
ip link add p4-eth0 type veth peer name resD-p4
ip link set p4-eth0 netns p4
ovs-vsctl add-port resD resD-p4
ip link set dev resD-p4 up
ip netns exec p4 ip link set dev p4-eth0 up
ip netns exec p4 ip link set dev lo up
#vlan sur P4
ip netns exec p4 ip link add link p4-eth0 name p4-eth0.200 type vlan id 200
ip netns exec p4 ip link set p4-eth0.200 up
ip netns exec p4 ip addr add 192.168.200.2/24 dev p4-eth0.200


##################### Routes par défaut
ip link set internet up
ip netns exec r1 ip r add 172.16.2.0/24 via 172.16.1.254 dev r1-eth0
ip netns exec r2 ip r add 172.16.1.0/24 via 172.16.2.254 dev r2-eth0
ip netns exec rA ip r add 172.16.2.0/24 via 10.87.0.2 dev rA-eth1
ip netns exec rB ip r add 172.16.1.0/24 via 10.87.0.1 dev rB-eth1
ip netns exec p1 ip r add default via 192.168.100.253 dev p1-eth0.100
ip netns exec p2 ip r add default via 192.168.200.253 dev p2-eth0.200
ip netns exec p3 ip r add default via 192.168.100.254 dev p3-eth0.100
ip netns exec p4 ip r add default via 192.168.200.254 dev p4-eth0.200



#Configuration des VLANS 

# Sur R1
ip netns exec r1 ip link add link r1-eth1 name r1-eth1.100 type vlan id 100
ip netns exec r1 ip link set dev r1-eth1.100 up
ip netns exec r1 ip addr add 192.168.100.254/24 dev r1-eth1.100
ip netns exec r1 ip link add link r1-eth1 name r1-eth1.200 type vlan id 200
ip netns exec r1 ip link set dev r1-eth1.200 up
ip netns exec r1 ip addr add 192.168.200.254/24 dev r1-eth1.200


#Sur R2
ip netns exec r2 ip link add link r2-eth1 name r2-eth1.100 type vlan id 100
ip netns exec r2 ip link set dev r2-eth1.100 up
ip netns exec r2 ip addr add 192.168.100.253/24 dev r2-eth1.100
ip netns exec r2 ip link add link r2-eth1 name r2-eth1.200 type vlan id 200
ip netns exec r2 ip link set dev r2-eth1.200 up
ip netns exec r2 ip addr add 192.168.200.253/24 dev r2-eth1.200
