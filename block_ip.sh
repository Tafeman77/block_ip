#!/bin/bash

# Prompt for SSH username
read -p "Enter the SSH username: " SSH_USER
if [ -z "$SSH_USER" ]; then
    echo "Error: SSH username cannot be empty"
    exit 1
fi

# Prompt for remote host
read -p "Enter the remote host (e.g., hostname or IP): " REMOTE_HOST
if [ -z "$REMOTE_HOST" ]; then
    echo "Error: Remote host cannot be empty"
    exit 1
fi

# Prompt for SSH port number
read -p "Enter the SSH port number (default is 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}  # Default to 22 if not provided
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
    echo "Error: Invalid port number. Must be between 1 and 65535."
    exit 1
fi

# Prompt for IP address to block
read -p "Enter the IP address to block: " IP_ADDRESS
if [ -z "$IP_ADDRESS" ]; then
    echo "Error: IP address cannot be empty"
    exit 1
fi

# Validate IP address format
if ! [[ $IP_ADDRESS =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Error: Invalid IP address format"
    exit 1
fi

# SSH into the remote machine and execute iptables commands
ssh -p "$SSH_PORT" "$SSH_USER@$REMOTE_HOST" << EOF
    # Obtain Root access
    nano /etc/passwd
    su root
    
    # Block all incoming traffic from the specified IP
    sudo iptables -A INPUT -s "$IP_ADDRESS" -j DROP

    # Block all outgoing traffic to the specified IP
    sudo iptables -A OUTPUT -d "$IP_ADDRESS" -j DROP

    echo "IP address $IP_ADDRESS has been blocked on $REMOTE_HOST."
EOF

if [ $? -eq 0 ]; then
    echo "Successfully blocked IP $IP_ADDRESS on $REMOTE_HOST via port $SSH_PORT."
else
    echo "Error: Failed to execute commands on $REMOTE_HOST."
    exit 1
fi
