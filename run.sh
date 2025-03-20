#!/bin/bash

# Check arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <validator|fullnode> [keys_dir]"
    echo "  For Linux systems, keys_dir must be specified (aws1 or aws2)"
    exit 1
fi

# Determine the environment and set paths
if [ "$(uname)" = "Darwin" ]; then
    KEYS_DIR="aws2"
    APTOS_CMD="aptos-node"
elif [ "$(uname)" = "Linux" ]; then
    if [ "$#" -lt 2 ]; then
        echo "Error: On Linux systems, you must specify the keys directory (aws1 or aws2) as the second argument"
        exit 1
    fi
    KEYS_DIR="$2"
    if [ "$KEYS_DIR" != "aws1" ] && [ "$KEYS_DIR" != "aws2" ]; then
        echo "Error: keys_dir must be either 'aws1' or 'aws2'"
        exit 1
    fi
    APTOS_CMD="/home/ubuntu/aptos-core/target/release/aptos-node"
else
    echo "Unsupported OS type: $(uname)"
    exit 1
fi

# Get public IP address
PUBLIC_IP=$(curl -4 ifconfig.me)
if [ $? -ne 0 ]; then
    echo "Failed to get public IP address"
    exit 1
fi

# Create node configs directory
sudo rm -rf /opt/aptos/node-configs && sudo mkdir -p /opt/aptos/node-configs

# Copy config files
sudo cp -r custom-node-config/* /opt/aptos/node-configs/

# Copy genesis files from custom-chain-genesis to custom-node-config/mainnet
sudo cp custom-chain-genesis/output/genesis.blob custom-node-config/mainnet/
sudo cp custom-chain-genesis/output/waypoint.txt custom-node-config/mainnet/

# Function to generate config from template
generate_config() {
    local node_type=$1
    local template="/opt/aptos/node-configs/mainnet/${node_type}.template.yaml"
    local output="/opt/aptos/node-configs/mainnet/${node_type}.yaml"
    
    # Create config from template with substitutions
    sudo sed -e "s|<KEYSDIR>|$KEYS_DIR|g" \
        -e "s|<VALIPADDR>|$PUBLIC_IP|g" \
        "$template" | sudo tee "$output" > /dev/null
}

# Check arguments
if [ "$1" = "validator" ]; then
    echo "Starting validator node with $KEYS_DIR keys..."
    generate_config "validator"
    $APTOS_CMD -f /opt/aptos/node-configs/mainnet/validator.yaml
elif [ "$1" = "fullnode" ]; then
    echo "Starting fullnode with $KEYS_DIR keys..."
    generate_config "fullnode"
    $APTOS_CMD -f /opt/aptos/node-configs/mainnet/fullnode.yaml

    echo "Please specify either 'validator' or 'fullnode' as an argument"
    exit 1
fi