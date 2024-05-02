#!/bin/bash -x


#on fait du cleaning pour r1 et r2
ip netns exec r1 ip link del r1-eth1.100
ip netns exec r1 ip link del r1-eth1.200
ip netns exec r2 ip link del r2-eth1.100
ip netns exec r2 ip link del r2-eth1.200
ip netns exec r1 ip a flush dev r1-eth1
ip netns exec r2 ip a flush dev r2-eth1


#Creation du tunnel l2tpv3
#côté de R1
ip netns exec r1 ip l2tp add tunnel remote 172.16.2.253 local 172.16.1.253 encap ip tunnel_id 3000 peer_tunnel_id 4000
#côté de R2
ip netns exec r2 ip l2tp add tunnel remote 172.16.1.253 local 172.16.2.253 encap ip tunnel_id 4000 peer_tunnel_id 3000

#Etablissement de la session
ip netns exec r1 ip l2tp add session tunnel_id 3000 session_id 1000 peer_session_id 2000
ip netns exec r2 ip l2tp add session tunnel_id 4000 session_id 2000 peer_session_id 1000

#Activation des interfaces du tunnel des deux cotes
ip netns exec r1 ip link set l2tpeth0 up
ip netns exec r2 ip link set l2tpeth0 up

#Ajout du bridge nomme tunnel
#Pour R1
ip netns exec r1 brctl addbr tunnel
ip netns exec r1 brctl addif tunnel l2tpeth0
ip netns exec r1 brctl addif tunnel r1-eth1
#ip netns exec r1 brctl addif tunnel r1-eth2

#Pour R2
ip netns exec r2 brctl addbr tunnel
ip netns exec r2 brctl addif tunnel l2tpeth0
ip netns exec r2 brctl addif tunnel r2-eth1
#ip netns exec r2 brctl addif tunnel r2-eth2

#Activation des interfaces correspondant au bridge
ip netns exec r1 ip link set tunnel up
ip netns exec r2 ip link set tunnel up

#Configuration des etiquettes VLAN et activation des interfaces
#Pour R1
ip netns exec r1 ip link add link tunnel name tunnel.100 type vlan id 100
ip netns exec r1 ip link set tunnel.100 up
ip netns exec r1 ip link add link tunnel name tunnel.200 type vlan id 200
ip netns exec r1 ip link set tunnel.200 up
#Pour R2
ip netns exec r2 ip link add link tunnel name tunnel.100 type vlan id 100
ip netns exec r2 ip link set tunnel.100 up
ip netns exec r2 ip link add link tunnel name tunnel.200 type vlan id 200
ip netns exec r2 ip link set tunnel.200 up

#Configuration IP de l'interface
ip netns exec r1 ip addr add 192.168.100.254/24 dev tunnel.100
ip netns exec r1 ip addr add 192.168.200.254/24 dev tunnel.200
ip netns exec r2 ip addr add 192.168.100.253/24 dev tunnel.100
ip netns exec r2 ip addr add 192.168.200.253/24 dev tunnel.200