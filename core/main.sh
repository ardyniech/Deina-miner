#!/bin/bash

# Menjalankan loop otonom 24/7
echo "=== Project Claw-Knowledge-Miner Activated (YOLO Mode) ==="

while true; do
    echo "[$(date)] Starting cycle..."

    # 1. Jalankan Scouter (Cari URL baru)
    bash scout.sh
    
    # 2. Jalankan Auditor (Proses 5 URL dari antrean)
    for i in {1..5}; do
        bash auditor.sh
        sleep 2 # Jeda singkat agar CPU tidak kaget
    done

    # 3. Jalankan Writer (Hanya jika jam menunjukkan pukul 00:00)
    current_hour=$(date +%H)
    if [ "$current_hour" == "00" ]; then
        echo "[*] Maintenance time: Synthesizing daily knowledge..."
        bash writer.sh
    fi

    echo "[$(date)] Cycle finished. Sleeping for 15 minutes..."
    sleep 900 # Istirahat 15 menit untuk menjaga suhu laptop Vaio
done
