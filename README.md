# Phantom Adaptive Tunnel (PAT)

**Твоя личная адаптивная система обхода блокировок 2026**

Многослойный shadow tunnel на базе **sing-box** с автоматической адаптацией под блокировки.

### Основные возможности
- **Primary**: Hysteria 2 (высокая скорость + устойчивость к потерям)
- **Fallback**: VLESS + Reality + XHTTP
- Автоматическая смена ключей (short_id, password, SNI)
- Генератор шумового трафика
- Минимальное потребление ресурсов
- Полностью под одного пользователя

## Быстрая установка

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Kraken992/phantom-adaptive-tunnel/main/setup.sh)
