#!/bin/bash -x

# Sur R1
# Ajout d'une règle pour les paquets provenant du réseau 192.168.100.0/24 pour utiliser la table vlan100
ip netns exec r1 ip rule add from 192.168.100.0/24 lookup vlan100
# Ajout d'une règle pour les paquets provenant du réseau 192.168.200.0/24 pour utiliser la table vlan200
ip netns exec r1 ip rule add from 192.168.200.0/24 lookup vlan200
# Interdiction des paquets provenant du réseau 192.168.200.0/24 d'accéder au VLAN 192.168.100.0/24
ip netns exec r1 ip route add prohibit 192.168.200.0/24 table vlan100
# Interdiction des paquets provenant du réseau 192.168.100.0/24 d'accéder au VLAN 192.168.200.0/24
ip netns exec r1 ip route add prohibit 192.168.100.0/24 table vlan200

#Sur R2
# Ajout d'une règle pour les paquets provenant du réseau 192.168.100.0/24 pour utiliser la table vlan100
ip netns exec r2 ip rule add from 192.168.100.0/24 lookup vlan100
# Ajout d'une règle pour les paquets provenant du réseau 192.168.200.0/24 pour utiliser la table vlan200
ip netns exec r2 ip rule add from 192.168.200.0/24 lookup vlan200
# Interdiction des paquets provenant du réseau 192.168.200.0/24 d'accéder au VLAN 192.168.100.0/24
ip netns exec r2 ip route add prohibit 192.168.200.0/24 table vlan100
# Interdiction des paquets provenant du réseau 192.168.100.0/24 d'accéder au VLAN 192.168.200.0/24
ip netns exec r2 ip route add prohibit 192.168.100.0/24 table vlan200

