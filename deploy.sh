#!/bin/bash

ss_config_path="/etc/shadowsocks-libev/config.json"

print() {
    local color="$1"
    local msg="$2"

    case "$color" in
    red) color_code="\033[0;31m" ;;
    green) color_code="\033[0;32m" ;;
    yellow) color_code="\033[0;33m" ;;
    blue) color_code="\033[0;34m" ;;
    cyan) color_code="\033[0;36m" ;;
    *) color_code="\033[0m" ;;
    esac

    echo -e "${color_code}${msg}\033[0m"
}

print green '1. Install shadowsocks-libev and jq'
apt-get install shadowsocks-libev jq

print green '2. Edit the server config'
jq '.server = "0.0.0.0"' $ss_config_path >./temp_config.json
mv ./temp_config.json $ss_config_path
cat /etc/shadowsocks-libev/config.json

print green '3. Make v2ray-plugin executable'
chmod +x ./v2ray-plugin

print green '4. Install acme.sh'
curl https://get.acme.sh | sh
acme_path="$HOME/.acme.sh"
export PATH="$PATH:$acme_path"

print green '5. Check acme.sh required configs'
print blue 'Select your DNS provider:'
PS3='Please enter your choice(1/2): '
select dns_provider in 'Cloudflare' 'Aliyun'; do
    case "$dns_provider" in
    Cloudflare)
        dns='dns_cf'
        if [[ -z "$CF_Email" || -z "$CF_Key" ]]; then
            print red 'Please set environment variable CF_Email and CF_Key'
            exit 1
        fi
        break
        ;;
    Aliyun)
        dns='ali'
        if [[ -z "$Ali_Secret" || -z "$Ali_Key" ]]; then
            print red 'Please set environment variable Ali_Secret and Ali_Key'
            exit 1
        fi
        break
        ;;
    *)
        print red 'Invalid input'
        ;;
    esac
done

print green '6. Register account'
acme.sh --register-account -m "$CF_Email"

print green '7. Issue certificate'
echo -en "\033[0;34mDomain: \033[0m"
read -r domain
acme.sh --issue --dns "$dns" -d "$domain"
