#!/bin/sh

set -eu

# To change build version change the value for version below
HOSTNAME=$(hostname)
IP=$(hostname -I)
SOURCE=https://github.com/CasperLabs/casper-node.git
VERSION=tags/v0.1.3

echo "* Running on ${HOSTNAME} ($IP)"

echo "* Installing prerequisites via apt"
apt-get -qq update
apt-get -qq dist-upgrade
apt-get -qq install git curl unattended-upgrades jq apt-transport-https ca-certificates gnupg-agent software-properties-common python3 python3-pip python3-dev llvm libclang-dev build-essential gcc g++ libssl-dev libudev-dev g++ g++-multilib lib32stdc++6-7-dbg libx32stdc++6-7-dbg make clang pkg-config runc


echo "* Installing Kitware apt repo and update CMake version"
curl -s https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add -
apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
apt-get -qq update
apt-get -qq install cmake

echo "* Installing rustup"
if [ ! -e $HOME/.rustup ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup
  sh /tmp/rustup -y --default-toolchain none
fi
export PATH=$HOME/.cargo/bin:$PATH

if [ ! -e /src ]; then
echo "* Cloning source"
  rm -rf /src
  mkdir /src
  git clone ${SOURCE} /src/casper-node/
fi

cd /src/casper-node

echo "* Setting up Rust"
git checkout ${VERSION}
make setup-rs

echo "* Building system contracts"
make build-system-contracts -j

echo "* Compiling a release node"
cargo build -p casper-node --release

echo "* Copying built node to /usr/local/bin"
stop service in case it is running
systemctl stop casper-node || true
sleep 0.5
cp -v target/release/casper-node /usr/local/bin

echo "* Dowloading config.toml"
mkdir -p /etc/casper
curl -o /etc/casper/chainspec.toml https://raw.githubusercontent.com/CasperLabs/casper-node/charlie-testnet/resources/charlie/chainspec.toml
curl -o /etc/casper/accounts.csv https://raw.githubusercontent.com/CasperLabs/casper-node/charlie-testnet/resources/charlie/accounts.csv
curl -o /etc/casper/config.toml https://raw.github.com/CasperLabs/casper-node/blob/master/resources/charlie/config-example.toml

echo "* Copying system contracts to /etc/casper/wasm as that is where the config points by default"
mkdir -p /etc/casper/wasm
cp -v target/wasm32-unknown-unknown/release/mint_install.wasm /etc/casper/wasm/
cp -v target/wasm32-unknown-unknown/release/pos_install.wasm /etc/casper/wasm/
cp -v target/wasm32-unknown-unknown/release/standard_payment_install.wasm /etc/casper/wasm/
cp -v target/wasm32-unknown-unknown/release/auction_install.wasm /etc/casper/wasm/

echo "* Setting up the casper user account"
adduser --disabled-login --group --no-create-home --system casper-user
mkdir -p /var/lib/casper-node/storage
chown casper-user:casper-user -R /var/lib/casper-node
chown casper-user:casper-user -R /etc/casper
chmod -R g=,o= /var/lib/casper-node /etc/casper

echo "* Creating systemd unit file"
cat > /etc/systemd/system/casper-node.service <<EOF
[Unit]
Description=CasperLabs blockchain node
Documentation=https://github.com/casperlabs/casper-node
After=network-online.target
Requires=network-online.target
[Service]
Environment=RUST_LOG=debug
ExecStart=/usr/local/bin/casper-node validator /etc/casper/config.toml
StandardOutput=file:/var/log/casper-node.log
StandardError=file:/var/log/casper-node.err
# RestartSec=5
# Restart=on-failure
Restart=never
# FIXME: Once #218 is merged, use notify.
Type=simple
User=casper-user
Group=casper-user
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

echo "* Cleaning up my mess"
rm -rf /src/casper-node

echo "* Please manually configure /etc/casper-node/config.toml and verify md5 matches account.csv and chainspec.toml"
