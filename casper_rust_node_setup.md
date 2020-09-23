# Requirements

- Ubuntu 20.04
- To use on Ubuntu 18.04 you MUST update cmake to at least 3.16.3-1ubuntu1 

# Install required packages

```
sudo apt install  git curl unattended-upgrades rkhunter fail2ban iperf htop iotop screen lynis nmap jq apt-transport-https ca-certificates gnupg-agent software-properties-common python3 python3-pip python3-dev llvm iptables-persistent
sudo apt install libclang-dev build-essential gcc g++ libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg make clang pkg-config runc cmake
```

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

    mkdir -p /etc/casper/wasm
    cd /etc/casper
    sudo cp -r ~/casper-node/target/wasm32-unknown-unknown/release/* /etc/casper/wasm
    sudo curl -o chainspec.toml https://raw.githubusercontent.com/sacherjj/casper-node/b1b49cbbb2e0527161bbd360334142b0f4fb3661/resources/charlie/chainspec.toml
    sudo curl -o accounts.csv https://raw.githubusercontent.com/CasperLabs/casper-node/c6f40f6335006419abf5bf4f23c2fbcb9d96ad4a/resources/charlie/accounts.csv
    md5sum accounts.csv --> should return e094b414dfe5c13f7f98e81a00c82767  accounts.csv
    md5sum chainspec.toml --> should return 9a38711a047dd7bf1f32bf4e959e04da  chainspec.toml
    sudo cp ~/casper-node/resources/local/config.toml /etc/casper
    
# Create Keys

    cd /home/casper/casper-node/client
    cargo run --release -- keygen $HOME/.client_keys

# Create Config file

    sudo nano /etc/casper/config.toml
    # edit the following lines to match
    chainspec_config_path = '/etc/casper/chainspec.toml'
    secret_key_path = '/home/<YOUR_USERNAME>/.client_keys/secret_key.pem'
    public_address = '<YOUR_IP>:0'

# Edit chainspec.toml

    sudo nano /etc/casper/chainspec.toml
    change the following lines
    
        ```mint_installer_path = '/etc/casper/wasm/mint_install.wasm'
        pos_installer_path = '/etc/casper/wasm/pos_install.wasm'
        standard_payment_installer_path = '/etc/casper/wasm/standard_payment_install.wasm'
        auction_installer_path = '/etc/casper/wasm/auction_install.wasm'
        accounts_path = '/etc/casper/accounts.csv'```


# Create symlinks to the binaries

    sudo ln -s ~/casper-node/target/release/casper-node /etc/
    sudo ln -s ~/casper-node/target/release/casper-client /etc/
    sudo chown -R casper:casper /etc/casper/
    # now we should be able to launch either binary with (casper-node or casper-client)
    
# Create A Service to start the node
    
    sudo nano /etc/systemd/system/casper.service
    
    
- Note: You should probably use a service account for this step 

- I use the user account that I log in with to start the service to avoid permissions issues.
- Paste the following and edit the user/group

    [Unit]
    Description=Casper Node service
    After=network.target

    [Service]
    User=USERNAME
    Group=GROUPNAME
    Type=simple
    ExecStart=/etc/casper-node validator /etc/casper/config.toml

    [Install]
    WantedBy=multi-user.target


# Start the node
    
- You can run the node with debug level INFO to verify it is working.
- I run this in screen (sudo apt install screen) and output to a file
```
screen
env RUST_LOG=INFO casper-node validator /etc/casper/config.toml & > casper.log
```
 
- Logs DEBUG output to your screen (warning its a lot of data)
```
screen    
env RUST_LOG=debug casper-node validator /etc/casper/config.toml & 
``` 

- For Less Detail & output to the console
```
env RUST_LOG=INFO casper-node validator /etc/casper/config.toml & 
```

    # Or run it normally without specifying log information
    casper-node validator /etc/casper/config.toml &
