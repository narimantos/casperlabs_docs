# Install required packages
    
    sudo apt install  git curl unattended-upgrades rkhunter fail2ban iperf htop iotop screen lynis nmap jq apt-transport-https ca-certificates gnupg-agent software-properties-common python3 python3-pip python3-dev llvm iptables-persistent
    sudo apt install libclang-dev build-essential gcc g++ libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg make clang pkg-config runc cmake
    
# Install Rustup and tools
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    rustup component add clippy-preview
    rustup default nightly
    source ~/.profile
    
# Get the code and compile it

    git clone https://github.com/CasperLabs/casper-node.git
    cd casper-node
    make setup-rs
    make build-system-contracts -j
    cargo build -p casper-node --release
    
# Move the files to common location

    mkdir -p /usr/local/bin/casper/wasm
    cd /usr/local/bin/casper
    sudo cp -r ~/casper-node/target/wasm32-unknown-unknown/release/* /usr/local/bin/casper/wasm
    sudo curl -o chainspec.toml https://raw.githubusercontent.com/sacherjj/casper-node/b1b49cbbb2e0527161bbd360334142b0f4fb3661/resources/charlie/chainspec.toml
    sudo curl -o accounts.csv https://raw.githubusercontent.com/CasperLabs/casper-node/c6f40f6335006419abf5bf4f23c2fbcb9d96ad4a/resources/charlie/accounts.csv
    md5sum accounts.csv --> should return e094b414dfe5c13f7f98e81a00c82767  accounts.csv
    md5sum chainspec.toml --> should return 9a38711a047dd7bf1f32bf4e959e04da  chainspec.toml
    sudo cp ~/casper-node/resources/local/config.toml /usr/local/bin/casper

# Create a service user account for casper

    sudo useradd -rM casper
    
# Create Keys

    cd /home/casper/casper-node/client
    cargo run --release -- keygen $HOME/.client_keys

# Create Config file

    sudo nano /usr/local/bin/casper/config.toml
    # edit the following lines to match
    chainspec_config_path = '/usr/local/bin/casper/chainspec.toml'
    secret_key_path = '/home/<YOUR_USERNAME>/.client_keys/secret_key.pem'
    public_address = '<YOUR_IP>:0'

# Edit the chainspec file

    sudo nano /usr/local/bin/casper/chainspec.toml
    change the following lines 
mint_installer_path = '/usr/local/bin/casper/wasm/mint_install.wasm'
pos_installer_path = '/usr/local/bin/casper/wasm/pos_install.wasm'
standard_payment_installer_path = '/usr/local/bin/casper/wasm/standard_payment_install.wasm'
auction_installer_path = '/usr/local/bin/casper/wasm/auction_install.wasm'
accounts_path = '/usr/local/bin/casper/accounts.csv'


# Create symlinks to the binaries

    sudo ln -s ~/casper-node/target/release/casper-node /usr/local/bin/
    sudo ln -s ~/casper-node/target/release/casper-client /usr/local/bin/
    sudo chown -R casper:casper /usr/local/bin/casper/
    # now we should be able to launch either binary with (casper-node or casper-client)
# Create A Service to start the node
    
    sudo nano /etc/systemd/system/casper.service
    
    
Paste the following
    ```    
    [Unit]
    Description=Prometheus Node Exporter Service
    After=network.target

    [Service]
    User=casper
    Group=casper
    Type=simple
    ExecStart=/usr/local/bin/casper-node validator /usr/local/bin/casper/config.toml

    [Install]
    WantedBy=multi-user.target
    ```

# Start the node
    
    You can run the node with debug level logging to verify it is working.
    I run this in screen (sudo apt install screen)
    
    Console Logs output to your screen
    env RUST_LOG=debug casper-node validator /usr/local/bin/casper/config.toml & > casper.log
    
    # For Less Detail
    env RUST_LOG=INFO casper-node validator /usr/local/bin/casper/config.toml & > casper.log
    
    # No Real Output
    casper validator /usr/local/bin/casper/config.toml