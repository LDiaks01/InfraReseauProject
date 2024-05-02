#!/bin/bash -x

# IPsec propose également deux modes de fonctionnement (Transport et Tunnel) : Nous on a choisi d'utiliser le mode Transport

# Cote r1
ip netns exec r1 ip xfrm state flush
ip netns exec r1 ip xfrm policy flush
# AH, " Authentication Header ", pour l’authentification utilisant un clé de longeur 256 bit et ESP, " Encapsulating Security Payload ", pour le chiffrement et l’authentification " utilsant une clé de longeur 160 bit

ip netns exec r1 ip xfrm state add src 172.16.1.253 dst 172.16.2.253 proto esp spi 0x12345678 reqid 0x12345678 mode transport auth sha256 0x323730ed6f1b9ff0cb084af15b197e862b7c18424a7cdfb74cd385ae23bc4f17 enc "rfc3686(ctr(aes))" 0x27b90b8aec1ee32a8150a664e8faac761e2d305b
ip netns exec r1 ip xfrm state add src 172.16.2.253 dst 172.16.1.253 proto esp spi 0x12345678 reqid 0x12345678 mode transport auth sha256 0x44d65c50b7581fd3c8169cf1fa0ebb24e0d55755b1dc43a98b539bb144f2067f enc "rfc3686(ctr(aes))" 0x9df7983cb7c7eb2af01d88d36e462b5f01d10bc1

# Les politiques de sécurité
ip netns exec r1 ip xfrm policy add src 172.16.2.253 dst 172.16.1.253 dir in tmpl src 172.16.2.253 dst 172.16.1.253 proto esp reqid 0x12345678 mode transport
ip netns exec r1 ip xfrm policy add src 172.16.1.253 dst 172.16.2.253 dir out tmpl src 172.16.1.253 dst 172.16.2.253 proto esp reqid 0x12345678 mode transport

# Cote r2
ip netns exec r2 ip xfrm state flush
ip netns exec r2 ip xfrm policy flush

# AH, " Authentication Header ", pour l’authentification utilisant un clé de longeur 256 bit et ESP, " Encapsulating Security Payload ", pour le chiffrement et l’authentification " utilsant une clé de longeur 160 bit
ip netns exec r2 ip xfrm state add src 172.16.1.253 dst 172.16.2.253 proto esp spi 0x12345678 reqid 0x12345678 mode transport auth sha256 0x323730ed6f1b9ff0cb084af15b197e862b7c18424a7cdfb74cd385ae23bc4f17 enc "rfc3686(ctr(aes))" 0x27b90b8aec1ee32a8150a664e8faac761e2d305b
ip netns exec r2 ip xfrm state add src 172.16.2.253 dst 172.16.1.253 proto esp spi 0x12345678 reqid 0x12345678 mode transport auth sha256 0x44d65c50b7581fd3c8169cf1fa0ebb24e0d55755b1dc43a98b539bb144f2067f enc "rfc3686(ctr(aes))" 0x9df7983cb7c7eb2af01d88d36e462b5f01d10bc1

# Les politiques de sécurité
ip netns exec r2 ip xfrm policy add src 172.16.2.253 dst 172.16.1.253 dir out tmpl src 172.16.2.253 dst 172.16.1.253 proto esp reqid 0x12345678 mode transport
ip netns exec r2 ip xfrm policy add src 172.16.1.253 dst 172.16.2.253 dir in tmpl src 172.16.1.253 dst 172.16.2.253 proto esp reqid 0x12345678 mode transport