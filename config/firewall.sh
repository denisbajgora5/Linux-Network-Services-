#!/bin/bash
# Firewall configuration for router

# Removes all current firewall rules (filter table).
iptables -F
# Clears NAT rules.
iptables -t nat -F
# Deletes any custom chains.
iptables -X

# Drops all incoming traffic by default.
iptables -P INPUT DROP
# Blocks all forwarded traffic unless allowed.
iptables -P FORWARD DROP
# Allows all outgoing connections.
iptables -P OUTPUT ACCEPT

# Allows the loopback interface (local machine traffic).
iptables -A INPUT -i lo -j ACCEPT

# Allows responses to traffic you already started (e.g., web browsing).
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Same as above, but for forwarded packets (router traffic).
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allows SSH connections from the internal network.
iptables -A INPUT -p tcp --dport 22 -i enp0s8 -j ACCEPT

# Allows DNS requests.
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT

# Allows DHCP traffic.
iptables -A INPUT -p udp --dport 67:68 -j ACCEPT

# Allow ping from internal network
iptables -A INPUT -p icmp --icmp-type echo-request -i enp0s8 -j ACCEPT

# Allows internal clients to reach the internet.
iptables -A FORWARD -i enp0s8 -o enp0s3 -j ACCEPT

# Enables NAT (internet sharing) on the external interface.
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

echo "Firewall configured successfully"
