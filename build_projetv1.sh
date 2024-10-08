#!/bin/bash -x


#creer les namespaces pour les hôtes
ip netns add poste1
ip netns add poste2
ip netns add poste3
ip netns add poste4

#pour les namespaces des routeurs
ip netns add routeur1
ip netns add routeur2
ip netns add routeurA
ip netns add routeurB

#creer les switches 
ovs-vsctl add-br resB
ovs-vsctl add-br resC
ovs-vsctl add-br resD
ovs-vsctl add-br resE
ovs-vsctl add-br resF
ovs-vsctl add-br resG
ovs-vsctl add-br int

#configuration des postes

#poste 1 du reseau E
ip link add poste1-eth0 type veth peer name resE-poste1
ip link set poste1-eth0 netns poste1
ovs-vsctl add-port resE resE-poste1
ip link set dev resE-poste1 up
ip netns exec poste1 ip link set dev lo up
ip netns exec poste1 ip link set dev poste1-eth0 up
ip netns exec poste1 ip a add dev poste1-eth0 192.168.100.1/24
ip netns exec poste1 ip r add default via 192.168.100.253

#poste2 du reseau G
ip link add poste2-eth0 type veth peer name resG-poste2
ip link set poste2-eth0 netns poste2
ovs-vsctl add-port resG resG-poste2
ip link set dev resG-poste2 up
ip netns exec poste2 ip link set dev lo up
ip netns exec poste2 ip link set dev poste2-eth0 up
ip netns exec poste2 ip a add dev poste2-eth0 192.168.200.1/24
ip netns exec poste2 ip r add default via 192.168.200.253

#poste3 du reseau D
ip link add poste3-eth0 type veth peer name resD-poste3
ip link set poste3-eth0 netns poste3
ovs-vsctl add-port resD resD-poste3
ip link set dev resD-poste3 up
ip netns exec poste3 ip link set dev lo up
ip netns exec poste3 ip link set dev poste3-eth0 up
ip netns exec poste3 ip a add dev poste3-eth0 192.168.100.2/24
ip netns exec poste3 ip r add default via 192.168.100.254

#poste4 du reseau F
ip link add poste4-eth0 type veth peer name resF-poste4
ip link set poste4-eth0 netns poste4
ovs-vsctl add-port resF resF-poste4
ip link set dev resF-poste4 up
ip netns exec poste4 ip link set dev lo up
ip netns exec poste4 ip link set dev poste4-eth0 up
ip netns exec poste4 ip a add dev poste4-eth0 192.168.200.2/24
ip netns exec poste4 ip r add default via 192.168.200.254


#Configuration des routeurs

#routeur 1
ip link add routeur1-eth0 type veth peer name resC-routeur1
ip link add routeur1-eth1 type veth peer name resD-routeur1
ip link add routeur1-eth2 type veth peer name resF-routeur1
ip link set routeur1-eth0 netns routeur1
ip link set routeur1-eth1 netns routeur1
ip link set routeur1-eth2 netns routeur1

ovs-vsctl add-port resC resC-routeur1
ovs-vsctl add-port resD resD-routeur1
ovs-vsctl add-port resF resF-routeur1
ip link set dev resC-routeur1 up
ip link set dev resD-routeur1 up
ip link set dev resF-routeur1 up
ip netns exec routeur1 ip link set dev lo up
ip netns exec routeur1 ip link set dev routeur1-eth0 up
ip netns exec routeur1 ip link set dev routeur1-eth1 up
ip netns exec routeur1 ip link set dev routeur1-eth2 up

ip netns exec routeur1 ip a add dev routeur1-eth0 172.16.1.253/24
ip netns exec routeur1 ip a add dev routeur1-eth1 192.168.100.254/24
ip netns exec routeur1 ip a add dev routeur1-eth2 192.168.200.254/24
ip netns exec routeur1 sudo sysctl net.ipv4.conf.all.forwarding=1

#routeur 2
ip link add routeur2-eth0 type veth peer name resB-routeur2
ip link add routeur2-eth1 type veth peer name resE-routeur2
ip link add routeur2-eth2 type veth peer name resG-routeur2
ip link set routeur2-eth0 netns routeur2
ip link set routeur2-eth1 netns routeur2
ip link set routeur2-eth2 netns routeur2

ovs-vsctl add-port resG resG-routeur2
ovs-vsctl add-port resE resE-routeur2
ovs-vsctl add-port resB resB-routeur2
ip link set dev resG-routeur2 up
ip link set dev resE-routeur2 up
ip link set dev resB-routeur2 up

ip netns exec routeur2 ip link set dev lo up
ip netns exec routeur2 ip link set dev routeur2-eth0 up
ip netns exec routeur2 ip link set dev routeur2-eth1 up
ip netns exec routeur2 ip link set dev routeur2-eth2 up

ip netns exec routeur2 ip a add dev routeur2-eth0 172.16.2.253/24
ip netns exec routeur2 ip a add dev routeur2-eth1 192.168.100.253/24
ip netns exec routeur2 ip a add dev routeur2-eth2 192.168.200.253/24
ip netns exec routeur2 sudo sysctl net.ipv4.conf.all.forwarding=1

#routeurA
ip link add routeurA-eth0 type veth peer name int-routeurA
ip link add routeurA-eth1 type veth peer name resC-routeurA
ip link set routeurA-eth0 netns routeurA
ip link set routeurA-eth1 netns routeurA

ovs-vsctl add-port int int-routeurA
ovs-vsctl add-port resC resC-routeurA
ip link set dev int-routeurA up
ip link set dev resC-routeurA up

ip netns exec routeurA ip link set dev lo up
ip netns exec routeurA ip link set dev routeurA-eth0 up
ip netns exec routeurA ip link set dev routeurA-eth1 up

ip netns exec routeurA ip a add dev routeurA-eth0 10.87.0.1/24
ip netns exec routeurA ip a add dev routeurA-eth1 172.16.1.254/24
ip netns exec routeurA sudo sysctl net.ipv4.conf.all.forwarding=1

#routeurB
ip link add routeurB-eth0 type veth peer name int-routeurB
ip link add routeurB-eth1 type veth peer name resB-routeurB
ip link set routeurB-eth0 netns routeurB
ip link set routeurB-eth1 netns routeurB

ovs-vsctl add-port int int-routeurB
ovs-vsctl add-port resB resB-routeurB
ip link set dev int-routeurB up
ip link set dev resB-routeurB up

ip netns exec routeurB ip link set dev lo up
ip netns exec routeurB ip link set dev routeurB-eth0 up
ip netns exec routeurB ip link set dev routeurB-eth1 up

ip netns exec routeurB ip a add dev routeurB-eth0 10.87.0.2/24
ip netns exec routeurB ip a add dev routeurB-eth1 172.16.2.254/24
ip netns exec routeurB sudo sysctl net.ipv4.conf.all.forwarding=1





