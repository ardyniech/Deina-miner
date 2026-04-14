#!/bin/bash

LOG_FILE="../logs/system_health.log"
DB_PATH="../db/knowledge.db"
LOCK_FILE="/tmp/claw_auditor.lock"

# Buat folder log jika belum ada
mkdir -p ../logs

echo "[$(date)] Running Self-Healing Monitor..." >> "$LOG_FILE"

# 1. Cek apakah orchestrator utama berjalan
if ! pgrep -f "main.sh" > /dev/null; then
    echo "[!] main.sh is NOT running! Calculating health score penalty (-10)." >> "$LOG_FILE"
    echo "[REPAIR] Restarting deina-agent.service..." >> "$LOG_FILE"
    systemctl --user restart deina-agent.service
else
    echo "[OK] System is healthy. Health Score: 100." >> "$LOG_FILE"
fi

# 2. Cek Stale Lock File (Auditor Crash)
if [ -e "$LOCK_FILE" ]; then
    # Jika lock file usianya lebih dari 15 menit, berarti proses nyangkut
    if test "$(find "$LOCK_FILE" -mmin +15)"; then
        echo "[!] Stale lock file detected. Repairing..." >> "$LOG_FILE"
        rm "$LOCK_FILE"
        echo "[REPAIR] Stale lock removed." >> "$LOG_FILE"
    fi
fi

# 3. Pembersihan log lama agar storage tidak penuh
find ../logs/ -type f -name "*.log" -mtime +7 -exec rm {} \;

echo "[OK] Maintenance sequence finished." >> "$LOG_FILE"
