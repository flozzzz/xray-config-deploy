SERVER=$1
envsubst < config/config.${SERVER}.json.template > /etc/xray/config.json


systemctl restart xray

sleep 3
if ! systemctl is-active --quiet xray; then
    echo "xray down, backup"
    cp ~/xray-config/config.json.backup /etc/xray/config.json
    systemctl restart xray
    exit 1
fi

echo "xray works, deploy successful"
