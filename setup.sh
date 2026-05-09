```bash
#!/bin/bash
# =============================================
# Phantom Adaptive Tunnel (PAT) Installer
# Автор: Kraken992
# =============================================

set -e

echo "=== Phantom Adaptive Tunnel (PAT) v1.0 ==="
echo "Установка для пользователя Kraken992..."

apt update && apt upgrade -y
apt install curl git unzip openssl certbot -y

echo "[+] Устанавливаем sing-box..."
bash -c "$(curl -L https://sing-box.sagernet.org/install.sh)"

mkdir -p /etc/sing-box /var/log/sing-box /root/pat/{scripts,config,keys}

cd /root/pat

# Генерация ключей
echo "[+] Генерация ключей..."
UUID=$(sing-box generate uuid)
KEYPAIR=$(sing-box generate reality-keypair)
PRIVATE_KEY=$(echo "$KEYPAIR" | grep -oP 'PrivateKey: \K\S+')
HY_PASS=$(openssl rand -hex 32)

echo "UUID: $UUID" > keys/keys.log
echo "PrivateKey: $PRIVATE_KEY" >> keys/keys.log
echo "Hy2_Password: $HY_PASS" >> keys/keys.log
echo "Generated at: $(date)" >> keys/keys.log

echo "[+] Ключи сохранены в /root/pat/keys/keys.log"

# Копируем или создаём конфиг
if [ -f config/config.json.template ]; then
    cp config/config.json.template /etc/sing-box/config.json
    sed -i "s|YOUR_UUID|$UUID|g" /etc/sing-box/config.json
    sed -i "s|YOUR_PRIVATE_KEY|$PRIVATE_KEY|g" /etc/sing-box/config.json
    sed -i "s|YOUR_HY2_PASS|$HY_PASS|g" /etc/sing-box/config.json
else
    echo "[-] Шаблон не найден. Создаём базовый конфиг..."
    cat > /etc/sing-box/config.json << EOF
{
  "log": { "level": "warn", "timestamp": true },
  "inbounds": [
    { "type": "hysteria2", "tag": "hy2-primary", "listen": "::", "listen_port": 443, "users": [{"password": "$HY_PASS"}], "tls": { "enabled": true, "server_name": "www.microsoft.com" }, "masquerade": "https://www.microsoft.com" },
    { "type": "vless", "tag": "reality-fallback", "listen": "::", "listen_port": 8443, "users": [{"uuid": "$UUID", "flow": "xtls-rprx-vision"}], "tls": { "enabled": true, "reality": { "enabled": true, "private_key": "$PRIVATE_KEY", "short_id": ["a1b2c3d4"] } } }
  ],
  "outbounds": [{ "type": "direct", "tag": "direct" }],
  "route": { "rules": [{ "inbound": ["hy2-primary","reality-fallback"], "outbound": "direct" }] }
}
EOF
fi

# Systemd
cat > /etc/systemd/system/pat.service << EOF
[Unit]
Description=Phantom Adaptive Tunnel (PAT) - Kraken992
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now pat

echo "=================================================="
echo "✅ Установка завершена успешно!"
echo "🔑 Ключи: cat /root/pat/keys/keys.log"
echo "📊 Статус: systemctl status pat"
echo "=================================================="
