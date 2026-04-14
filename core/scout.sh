#!/bin/bash

# Konfigurasi
DB_PATH="../db/knowledge.db"
SEARCH_QUERY="self-hosted+autonomous+ai+agent+linux"

echo "[*] Searching for: $SEARCH_QUERY"

# Mencari URL menggunakan DuckDuckGo HTML (Tanpa API/Token)
# Mengambil link yang mengandung 'http' dan memfilter hasil dari duckduckgo sendiri
links=$(curl -s -A "Mozilla/5.0" "https://html.duckduckgo.com/html/?q=$SEARCH_QUERY" | \
        grep -oP 'http[s]?://[^"&]+' | \
        grep -v 'duckduckgo.com')

for url in $links; do
    # Masukkan ke database, abaikan jika URL sudah ada (UNIQUE constraint)
    sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO scout_queue (url, topic) VALUES ('$url', '$SEARCH_QUERY');"
    echo "[+] Queued: $url"
done

echo "[*] Scouting selesai."
