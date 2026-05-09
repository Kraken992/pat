#!/bin/bash
# Генератор шумового трафика (чтобы туннель не выглядел пустым)

while true; do
    curl -s -m 10 https://www.microsoft.com > /dev/null 2>&1 || true
    curl -s -m 10 https://www.google.com > /dev/null 2>&1 || true
    sleep $((RANDOM % 180 + 60))  # от 1 до 4 минут
done
