#!/bin/bash
# =============================================
# Phantom Adaptive Tunnel - Auto Adapter
# Автор: Kraken992
# =============================================

cd /root/pat

echo "[$(date)] Запуск адаптации ключей..." >> /var/log/sing-box/adapt.log

# Генерируем новые ключи
NEW_UUID=$(sing-box generate uuid)
NEW_SHORT_ID=$(openssl rand -hex 4)
NEW_HY_PASS=$(openssl rand -hex 24)

# Обновляем config.json
sed -i "s/\"uuid\": \".*\"/\"uuid\": \"$NEW_UUID\"/" /etc/sing-box/config.json
sed -i "s/\"short_id\": \[\s*\"[^\"]*\".*\]/\"short_id\": [\"$NEW_SHORT_ID\"]/" /etc/sing-box/config.json
sed -i "s/\"password\": \".*\"/\"password\": \"$NEW_HY_PASS\"/" /etc/sing-box/config.json

# Перезапускаем сервис
systemctl restart pat

echo "[$(date)] Адаптация завершена. Новый ShortID: $NEW_SHORT_ID" >> /var/log/sing-box/adapt.log
echo "✅ Адаптация выполнена. Новые ключи сгенерированы."
