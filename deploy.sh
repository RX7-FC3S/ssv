ss_config_path="/etc/shadowsocks-libev"

echo 1. Install shadowsocks-libev, jq
apt-get install shadowsocks-libev jq | awk '{print "apt-get: " $0}'

echo 2. Edit the server config
jq '.server = "0.0.0.0"' $ss_config_path/config.json > ./temp_config.json && mv ./temp_config.json $ss_config_path/config.json
cat /etc/shadowsocks-libev/config.json

echo 3. Make v2ray-plugin executable
chmod +x ./v2ray-plugin

