#!/bin/bash

ss_config_path="/etc/shadowsocks-libev"

echo 1. Install shadowsocks-libev, jq
apt-get install shadowsocks-libev jq

echo 2. Edit the server config
jq '.server = "0.0.0.0"' $ss_config_path/config.json > ./temp_config.json && mv ./temp_config.json $ss_config_path/config.json
cat /etc/shadowsocks-libev/config.json

echo 3. Make v2ray-plugin executable
chmod +x ./v2ray-plugin

echo 4. Install acme.sh
curl https://get.acme.sh | sh
export PATH=$PATH:$(pwd)/.acme.sh

echo 5. Check email and cloudflare API key
if [[ -z "$CF_Email"]]; then
    echo Please add CF_Email to the environment variables
    exit 1
fi
if [[ -z "$CF_Key"]]; then
    echo Please add CF_Key to the environment variables
    exit 1
fi

echo 6. Register account
acme.sh --register-account -m $CF_Email

echo 7. Issue certificate
echo -n "Domian: "
read domain
acme.sh --issue --dns dns_cf -d $domain
