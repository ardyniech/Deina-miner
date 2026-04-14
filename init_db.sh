#!/bin/bash

# Konfigurasi
DB_DIR="../db"
DB_PATH="$DB_DIR/knowledge.db"

echo "[*] Initializing Database for Claw-Knowledge-Miner..."

# Buat folder db jika belum ada
mkdir -p $DB_DIR

# Bangun tabel-tabel utama
sqlite3 "$DB_PATH" <<EOF
CREATE TABLE IF NOT EXISTS scout_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url TEXT UNIQUE,
    topic TEXT,
    status TEXT DEFAULT 'pending'
);

CREATE TABLE IF NOT EXISTS knowledge_archive (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hash TEXT UNIQUE,
    url TEXT,
    clean_text TEXT,
    timestamp DATETIME
);

CREATE TABLE IF NOT EXISTS conflict_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic TEXT,
    entity TEXT,
    value_a TEXT,
    value_b TEXT,
    source_a_url TEXT,
    source_b_url TEXT,
    status TEXT DEFAULT 'unresolved'
);

-- Optimasi Performa untuk Low-Resource
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
EOF

echo "[OK] Database ready at $DB_PATH"
