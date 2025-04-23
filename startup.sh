#!/bin/bash

SS_CONFIG="/etc/shadowsocks-libev/config.json"

HOST="yourdomain.com"
PORT=433

CER_PATH="../.acme.sh/yourdomain.com_ecc/yourdomain.com.cer"
KEY_PATH="../.acme.sh/yourdomain.com_ecc/yourdomain.com.key"

LOG_FILE="./ssv.log"

PLUGIN="./v2ray-plugin"
PLUGIN_OPTS="server;tls;host=$HOST;cert=$CER_PATH;key=$KEY_PATH"

# 检查并终止指定服务的函数
terminate_service() {
    local service_name=$1
    local pids=$(pgrep -x "$service_name")

    echo "🔎 检查 $service_name 运行状态..."

    if [[ -z "$pids" ]]; then
        echo "✅ $service_name 未在运行"
    else
        echo "❌ 检测到 $service_name (PID: $pids) 正在运行"
        echo "➡️ 正在关闭 $service_name ..."
        kill -9 $pids 2>/dev/null && echo "✅ $service_name 已成功关闭" || echo "⚠️ 无法关闭 $service_name"
    fi
}

echo "================= 服务状态检查 ================="

terminate_service "v2ray-plugin"
terminate_service "ss-server"

echo "================================================="
echo "🚀 启动 ss-server + v2ray-plugin 服务"
echo "🔹 配置文件: $SS_CONFIG"
echo "🔹 插件参数: $PLUGIN_OPTS"

nohup ss-server -c "$SS_CONFIG" --plugin "$PLUGIN" --plugin-opts "$PLUGIN_OPTS" >> "$LOG_FILE" 2>&1 &

sleep 3

echo "================================================="
echo "📋 端口占用状态"
netstat -lptun | grep -E "v2ray-plugin|ss-server"
