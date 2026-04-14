#!/bin/bash

DB_PATH="../db/knowledge.db"
TEMP_FILE="/tmp/fact_buffer.txt"
EXTRACT_FILE="/tmp/temp_facts.txt"

echo "[*] Scanning for conflicting technical data..."

# Ambil 50 data terbaru dari arsip
sqlite3 "$DB_PATH" "SELECT id, clean_text, url FROM knowledge_archive ORDER BY id DESC LIMIT 50;" > "$TEMP_FILE"

# Regex: Deteksi angka yang berkaitan dengan suhu (contoh kasus teknis)
grep -iE '[0-9]+°c|[0-9]+ c|[0-9]+ derajat' "$TEMP_FILE" > "$EXTRACT_FILE"

# Hitung jumlah temuan
count=$(wc -l < "$EXTRACT_FILE")

if [ "$count" -ge 2 ]; then
    # Ekstrak 2 temuan pertama untuk perbandingan
    source_a=$(head -n 1 "$EXTRACT_FILE")
    source_b=$(tail -n 1 "$EXTRACT_FILE")
    
    url_a=$(echo "$source_a" | awk -F'|' '{print $3}')
    url_b=$(echo "$source_b" | awk -F'|' '{print $3}')
    
    # Hanya log konflik jika data berasal dari URL yang berbeda
    if [ "$url_a" != "$url_b" ]; then
        # Masukkan log konflik ke database dengan cara aman
        sqlite3 "$DB_PATH" "INSERT INTO conflict_logs (topic, entity, value_a, value_b, source_a_url, source_b_url) VALUES ('Sistem Operasional', 'Suhu/Thermal', 'Data A Terdeteksi', 'Data B Terdeteksi', '$url_a', '$url_b');"
        echo "[!] Konflik data tercatat di database. Menunggu tinjauan LLM."
    fi
fi

rm "$TEMP_FILE" "$EXTRACT_FILE" 2>/dev/null
echo "[DONE] Conflict check selesai."
