# Requirements

- Ubuntu 20.04
- To use on Ubuntu 18.04 you MUST update cmake to at least 3.16.3 ----> Source for update [Kitware/CMake](https://github.com/Kitware/CMake) 

# Install required packages

```
sudo apt install  git curl unattended-upgrades rkhunter fail2ban iperf htop iotop screen lynis nmap jq apt-transport-https ca-certificates gnupg-agent software-properties-common python3 python3-pip python3-dev llvm iptables-persistent
sudo apt install libclang-dev build-essential gcc g++ libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg make clang pkg-config runc cmake
```

# Install Rustup
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    
# Get the code and compile it

    git clone https://github.com/CasperLabs/casper-node.git
    cd casper-node
    git checkout v0.1.1_0
    make setup-rs
    make build-system-contracts -j
    cargo build -p casper-node --release
    
# Move the files to common location

    mkdir -p /etc/casper/wasm
    cd /etc/casper
    sudo cp ~/casper-node/casper-node /etc/casper
    sudo cp ~/casper-node/casper-client /etc/casper
    sudo cp -r ~/casper-node/target/wasm32-unknown-unknown/release/* /etc/casper/wasm
    sudo curl -o chainspec.toml https://raw.githubusercontent.com/sacherjj/casper-node/b1b49cbbb2e0527161bbd360334142b0f4fb3661/resources/charlie/chainspec.toml
    sudo curl -o accounts.csv https://raw.githubusercontent.com/CasperLabs/casper-node/c6f40f6335006419abf5bf4f23c2fbcb9d96ad4a/resources/charlie/accounts.csv
    md5sum accounts.csv --> should return e094b414dfe5c13f7f98e81a00c82767  accounts.csv
    md5sum chainspec.toml --> should return 9a38711a047dd7bf1f32bf4e959e04da  chainspec.toml
    sudo cp ~/casper-node/resources/local/config.toml /etc/casper
    
# Create Config file

    sudo nano /etc/casper/config.toml
    # edit the following lines to match
    chainspec_config_path = '/etc/casper/chainspec.toml'
    secret_key_path = '/home/<YOUR_USERNAME>/.client_keys/secret_key.pem'
    public_address = '<YOUR_IP>:0'

# Edit chainspec.toml

    sudo nano /etc/casper/chainspec.toml
    
- Change the following lines
```    
mint_installer_path = '/etc/casper/wasm/mint_install.wasm'
pos_installer_path = '/etc/casper/wasm/pos_install.wasm'
standard_payment_installer_path = '/etc/casper/wasm/standard_payment_install.wasm'
auction_installer_path = '/etc/casper/wasm/auction_install.wasm'
accounts_path = '/etc/casper/accounts.csv'
```

# Create symlinks to the binaries

    sudo ln -s ~/casper-node/target/release/casper-node /etc/
    sudo ln -s ~/casper-node/target/release/casper-client /etc/
    sudo chown -R casper:casper /etc/casper/
    # now we should be able to launch either binary with (casper-node or casper-client)

# Create Keys

    casper-client keygen $HOME/.client_keys
    
# Create the Service
    
    sudo nano /etc/systemd/system/casper.service
    
    
- Note: You should probably use a service account for this step 

- I used root for initial config: TODO update how to do with service account
- Paste the following
```
[Unit]
Description=Casper Node Service
After=network.target

[Service]
User=root
Group=root
Type=simple
ExecStart=nohup env RUST_LOG=INFO /etc/casper/casper-node validator /etc/casper/config.toml
StandardOutput=file:/var/log/casper-node.log
StandardError=file:/var/log/casper-node.err
[Install]
WantedBy=multi-user.target
```

# Starting the node with systemd

```
sudo systemctl daemon-reload
sudo systemctl start casper
sudo systemctl status casper
```

# Stopping the node

```
sudo systemctl stop casper
```

# Check the log file

- Node Log
```
sudo cat /var/log/casper-node.log
```

- Error Log
```
sudo cat /var/log/casper-node.err
```
