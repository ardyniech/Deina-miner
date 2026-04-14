#!/bin/bash

# Konfigurasi Path
DB_PATH="../db/knowledge.db"
TEMP_FILE="/tmp/claw_process.tmp"
LOCK_FILE="/tmp/claw_auditor.lock"

# 1. Thermal Guard Function
check_thermal() {
    # Membaca suhu (biasanya dalam miliderajat Celcius)
    local temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
    local temp=$((temp_raw / 1000))
    
    if [ "$temp" -gt 68 ]; then
        echo "[!] Suhu kritis: ${temp}°C. Cooling down 5 menit..."
        sleep 300
    fi
}

# 2. Text Normalization & Hashing
# Membersihkan HTML -> Markdown -> Plain Text (Lowercase & No Special Chars)
generate_hash() {
    local input_html="$1"
    
    # Normalisasi: Pandoc -> Lowercase -> Hapus karakter non-alfa -> SHA256
    clean_text=$(echo "$input_html" | pandoc -f html -t plain | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
    echo "$clean_text" | sha256sum | awk '{print $1}'
}

# 3. Main Audit Logic
audit_url() {
    local url="$1"
    local raw_content="$2"
    local topic="$3"

    echo "[*] Auditing: $url"
    
    # Generate Hash dari konten bersih
    local content_hash=$(generate_hash "$raw_content")
    
    # Cek duplikasi di SQLite
    local exists=$(sqlite3 "$DB_PATH" "SELECT id FROM knowledge_archive WHERE hash='$content_hash';")

    if [ -n "$exists" ]; then
        echo "[SKIP] Konten duplikat terdeteksi (Hash: $content_hash)."
        return 1
    else
        # Simpan jika unik
        local clean_md=$(echo "$raw_content" | pandoc -f html -t markdown)
        local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
        
        sqlite3 "$DB_PATH" <<EOF
INSERT INTO knowledge_archive (hash, url, clean_text, timestamp) 
VALUES ('$content_hash', '$url', '$(echo "$clean_md" | sed "s/'/''/g")', '$timestamp');
EOF
        echo "[OK] Data unik tersimpan."
        return 0
    fi
}

# --- Execution Flow ---
# Cek Lockfile agar tidak double process
if [ -e "$LOCK_FILE" ]; then
    echo "Auditor masih berjalan."
    exit 1
fi
touch "$LOCK_FILE"

# Logic pengambilan antrean dari database scout_queue bisa diletakkan di sini
# ...

check_thermal
# audit_url "http://example.com" "<html>...</html>" "Topic"

rm "$LOCK_FILE"
