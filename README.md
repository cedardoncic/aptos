# Aptos Benchmark Validator + Fullnode setup

## Setup

2 AWS instances: aws1 and aws2

### AWS Setup

```bash
sudo apt upgrade && sudo apt update

git clone https://github.com/aptos-labs/aptos-core
cd aptos-core 

# Install Rust
curl https://sh.rustup.rs -sSf | sh
. "$HOME/.cargo/env" # note the leading dot

sudo ./scripts/dev_setup.sh 
rustup toolchain install 1.84.0-aarch64-unknown-linux-gnu # if on Linux ARM machine

cargo build -p aptos --release
cargo build -p aptos-node --release

export PATH="/home/ubuntu/aptos-core/target/release:$PATH"

# Make sure ports are open on both machines
```

### Genesis

```bash
# Update genesis/aws[1,2]/operator.yaml with the correct IP addresses

# Generate genesis
aptos genesis generate-genesis --local-repository-dir genesis --output-dir genesis/output --mainnet --assume-yes 

# Copy to custom-node-config/mainnet
cp genesis/output/genesis.blob custom-node-config/mainnet/genesis.blob
cp genesis/output/waypoint.txt custom-node-config/mainnet/waypoint.txt
```

### Run the Node

```bash
# On AWS1 (validator)
sudo sh ./run.sh validator aws1 

# On AWS2 (validator)
sudo sh ./run.sh validator aws2

#################################
######### For Fullnodes #########
#################################

# On AWS1 (fullnode)
sudo sh ./run.sh fullnode aws1

# On AWS2 (fullnode)
sudo sh ./run.sh fullnode aws2
```

### Setting up stake pool

```bash

```