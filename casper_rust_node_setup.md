# Requirements

- Ubuntu 20.04 or
- To use on Ubuntu 18.04 you MUST update cmake to at least 3.16.3 ----> Source for update [Kitware/CMake](https://github.com/Kitware/CMake) 

# Sysctl settings
```
sudo nano /etc/sysctl.conf
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com
# Controls IP packet forwarding
net.ipv4.ip_forward = 0
 
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
 
# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0
 
# Controls whether core dumps will append the PID to the core filename
# Useful for debugging multi-threaded applications
kernel.core_uses_pid = 1


# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

# Controls the use of TCP syncookies
# Turn on SYN-flood protections
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 5

# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#
# Disable IPv6
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
###################################################################
# Magic system request Key
# 0=disable, 1=enable all
# Debian kernels have this set to 0 (disable the key)
# See https://www.kernel.org/doc/Documentation/sysrq.txt
# for what other values do
#kernel.sysrq=1

###################################################################
# Protected links
#
# Protects against creating or following links under certain conditions
# Debian kernels have both set to 1 (restricted) 
# See https://www.kernel.org/doc/Documentation/sysctl/fs.txt
fs.protected_hardlinks=1
fs.protected_symlinks=1

# Accept packets with SRR option? No
net.ipv4.conf.all.accept_source_route = 0


# Log packets with impossible addresses to kernel log? yes
net.ipv4.conf.all.log_martians = 1
# Ignore all ICMP ECHO and TIMESTAMP requests sent to it via broadcast/multicast
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Controls source route verification
net.ipv4.conf.default.rp_filter = 1 

# increase system file descriptor limit    
fs.file-max = 65535
 
#Allow for more PIDs 
kernel.pid_max = 65536
 
#Increase system IP port limits
net.ipv4.ip_local_port_range = 2000 65000
 
# RFC 1337 fix
net.ipv4.tcp_rfc1337=1

#Reboot the machine soon after a kernel panic
kernel.panic=10

#Addresses of mmap base, heap, stack and VDSO page are randomized
kernel.randomize_va_space=2

#Ignore bad ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses=1

# Memory Tuning
vm.swappiness = 10
vm.dirty_background_ratio=20
vm.dirty = 50


# TCPIP Tuning
net.core.wmem_max=12582912
net.core.rmem_max=12582912
net.ipv4.tcp_rmem= 10240 87380 12582912
net.ipv4.tcp_wmem= 10240 87380 12582912
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.core.netdev_max_backlog = 5000

# Enable HugePages
vm.nr_hugepages = 40
```

# Install required packages

```
sudo apt install  git curl unattended-upgrades nmap jq apt-transport-https ca-certificates gnupg-agent software-properties-common python3 python3-pip python3-dev llvm iptables-persistent libclang-dev build-essential gcc g++ libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg make clang pkg-config runc
```
# Setup IPTABLES
```
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -i enp7s0 -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -s 67.231.40.0/24 -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --ports 53,7777,34553,40403 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p udp -m multiport --ports 53,67,68,123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -P INPUT DROP 
```

# Install CMAKE

```,
wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc |
    sudo apt-key add -
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
sudo apt-get update
sudo apt-get install cmake
```

# Install Rustup
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env

### This is where the base image was created

snapshot

# Get the code and compile it

    git clone https://github.com/CasperLabs/casper-node.git
    cd casper-node
    git checkout v0.1.2_0
    make setup-rs
    make build-system-contracts -j
    cargo build -p casper-node --release
    cargo build -p casper-client --release

    

# Move the files to common location
[Source](https://www.pathname.com/fhs/pub/fhs-2.3.html#USRLOCALLOCALHIERARCHY) <--- Correct path locations

bin	Local binaries
etc	Host-specific system configuration for local binaries
    
    cd target
    sudo mkdir /etc/casper
    sudo mkdir /etc/casper/wasm
    sudo cp -r wasm32-unknown-unknown/ /etc/casper/wasm
    cd release
    sudo cp casper-node* /usr/local/bin
    sudo cp casper-client* /usr/local/bin
    sudo cp libcasper* /usr/local/bin
    cd /etc/casper
    sudo curl -o chainspec.toml https://raw.githubusercontent.com/sacherjj/casper-node/b1b49cbbb2e0527161bbd360334142b0f4fb3661/resources/charlie/chainspec.toml
    sudo curl -o accounts.csv https://raw.githubusercontent.com/CasperLabs/casper-node/c6f40f6335006419abf5bf4f23c2fbcb9d96ad4a/resources/charlie/accounts.csv
    md5sum accounts.csv --> should return e094b414dfe5c13f7f98e81a00c82767  accounts.csv
    md5sum chainspec.toml --> should return 9a38711a047dd7bf1f32bf4e959e04da  chainspec.toml
    sudo cp ~/casper-node/resources/local/config.toml /etc/casper
    
# Create Config file

    sudo nano config.toml
    # edit the following lines to match
    chainspec_config_path = '/etc/chainspec.toml'
    secret_key_path = '/home/<YOUR_USERNAME>/.client_keys/secret_key.pem'
    public_address = '<YOUR_IP>:0'
    NOTE add remote servers

# Edit chainspec.toml

    sudo nano /usr/local/bin/casper/chainspec.toml
    edit name = 'casper-charlie-testnet-5'
    
# Create Keys
    
    cd home
    casper-client keygen .client_keys/testaccount

# Create Service Account and Grant Permissions

    sudo adduser casper-service --shell=/bin/false --no-create-home --disabled-login --disabled-password
    sudo usermod -G casper-service casperadm
    sudo chown -R casperadm:casperadm /etc/casper
    sudo chown -R casperadm:casperadm /usr/local/bin/c*

# Create the Service
Not working. Do another time..

    sudo nano /etc/systemd/system/casper.service
    [Unit]
    Description=Casper Node Service
    After=network.target

    [Service]
    User=casper-service
    Group=casper-service
    Type=simple
***    ExecStart=nohup env RUST_LOG=INFO casper-node validator /etc/casper/config.toml```
    StandardOutput=file:/var/log/casper-node.log
    StandardError=file:/var/log/casper-node.err 

    [Install]
    WantedBy=multi-user.target    

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

# If you change your confirguration

- Clear Local State

`sudo rm -rf /home/<USER>/.local/share/casper-node`
