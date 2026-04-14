#!/bin/bash

# Menjalankan loop otonom 24/7
echo "=== Project Claw-Knowledge-Miner Activated (YOLO Mode) ==="

# Jalankan Self-Healing di background setiap 30 menit
while true; do bash self_healing.sh; sleep 1800; done &

while true; do
    echo "[$(date)] Starting cycle..."

    # 1. Scouter (Cari URL baru)
    bash scout.sh
    
    # 2. Auditor (Proses 5 URL dari antrean)
    for i in {1..5}; do
        bash auditor.sh
        sleep 2
    done

    # 3. Mekanisme Resolusi Konflik (Zero-Token Check)
    bash conflict_resolver.sh

    # 4. Writer (Sintesis LLM hanya di jam 00:00)
    current_hour=$(date +%H)
    if [ "$current_hour" == "00" ]; then
        echo "[*] Maintenance time: Synthesizing daily knowledge..."
        bash writer.sh
    fi

    echo "[$(date)] Cycle finished. Sleeping for 15 minutes..."
    sleep 900
done
