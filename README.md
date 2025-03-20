# Aptos Benchmark Validator + Fullnode setup

## Setup

2 AWS instances: aws1 and aws2

### AWS Setup

Relevant docs: https://aptos.dev/en/network/nodes/validator-node/deploy-nodes/using-source-code

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

We use AWS1 as the initial and only peer in the genesis ceremony and have AWS2 join the network as a validator.

Relevant docs: https://aptos.dev/en/build/cli/public-network

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

Relevant docs: https://aptos.dev/en/network/nodes/validator-node/connect-nodes/staking-pool-operations

```bash
# On any machine
# Private key must match AWS1 account private key in aws1/private-keys.yaml
## When prompted, use http://<AWS1_IP_ADDRESS>:8082 as the REST URL endpoint
## 'skip' the faucet
aptos init --profile mainnet-operator-aws1 --network custom --private-key 0xa48ae00b261e62257941cb4ed95c6e669217a0a86d87544f66e86b745958e5ea 

# On AWS1
# This FAILS because it appears the genesis timestamp is not set correctly
aptos stake create-staking-contract \                                                                                                          
  --operator 0x994a745b3700fcc728bcaf94936b8aedb5eceee0567b6264451818be3ac96ef6 \
  --voter 0x994a745b3700fcc728bcaf94936b8aedb5eceee0567b6264451818be3ac96ef6 \
  --amount 100000000000000 \
  --commission-percentage 10 \
  --profile mainnet-operator-aws1
```

#### Additional Errors:

```bash
# Genesis balances (defined in `balances.yaml`) do not seem to be respected / used

# For example, this returns 0 balance
# Relevant docs: https://aptos.dev/en/network/nodes/validator-node/connect-nodes/connect-to-aptos-network
aptos account list --profile mainnet-operator-aws1
```