# Deploy Script Instructions

- This script should be run as ROOT
If you are not logged in with root you can switch using 
```
sudo su
```

- Once you are root then.
```
wget https://github.com/crypto-guys/casperlabs_docs/deploy-script/install.sh
chmod +x install.sh
./install.sh
```

### After completion 

- Edit config.toml

- Verify the path to chainspec.toml is like this
```
chainspec_config_path = '/etc/casper/chainspec.toml'
```

- Verify Key Path is the correct path for where you will store your keys
```
secret_key_path = '/etc/casper/validator_keys/secret_key.pem'
```

- Enter your validator public ip address
  
```
public_address = '<IP ADDRESS>:0'
```
example  ```public_address = '100.100.100.1:0'```
  
