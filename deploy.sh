#!/bin/bash

RED="\e[31m"
BLUE="\e[34m"
GREEN="\e[32m"
NORMAL="\e[0m"

ss_config_path="/etc/shadowsocks-libev"


echo "$GREEN 1. Install shadowsocks-libev, jq $NORMAL"
apt-get install shadowsocks-libev jq

echo "$GREEN 2. Edit the server config $NORMAL"
jq '.server = "0.0.0.0"' $ss_config_path/config.json > ./temp_config.json && mv ./temp_config.json $ss_config_path/config.json
cat /etc/shadowsocks-libev/config.json

echo "$GREEN 3. Make v2ray-plugin executable $NORMAL"
chmod +x ./v2ray-plugin

echo "$GREEN 4. Install acme.sh $NORMAL"
curl https://get.acme.sh | sh
export PATH=$PATH:$(pwd)/.acme.sh

echo "$GREEN 5. Check email and cloudflare API key $NORMAL"
if [[ -z "$CF_Email"]]; then
    echo "$RED Please add CF_Email to the environment variables $NORMAL"
    exit 1
fi
if [[ -z "$CF_Key"]]; then
    echo "$RED Please add CF_Key to the environment variables $NORMAL"
    exit 1
fi

echo "$GREEN 6. Register account $NORMAL"
acme.sh --register-account -m $CF_Email

echo "$GREEN 7. Issue certificate $NORMAL"
echo -n "$BLUE Domian: $NORMAL"
read domain
acme.sh --issue --dns dns_cf -d $domain
