#!/bin/bash

DB_PATH="../db/knowledge.db"
LLAMA_PATH="/home/ardy/llama.cpp/main" # Sesuaikan path ini nanti
MODEL_PATH="/home/ardy/models/tinyllama-1.1b.Q4_K_M.gguf"    # Sesuaikan path ini nanti

# Ambil 5 data unik terbaru untuk dijadikan bahan draf
facts=$(sqlite3 "$DB_PATH" "SELECT clean_text FROM knowledge_archive ORDER BY id DESC LIMIT 5;")

if [ -n "$facts" ]; then
    echo "[*] Synthesizing knowledge with LLM..."
    
    prompt="Tuliskan ringkasan teknis yang detail dalam format Markdown berdasarkan fakta berikut: $facts"
    
    # Jalankan llama.cpp (One-shot mode)
    # Gunakan --temp 0.7 agar hasil kreatif tapi tetap teknis
    $LLAMA_PATH -m $MODEL_PATH -p "$prompt" -n 512 --temp 0.7 > "../drafts/draft_$(date +%Y%m%d_%H%M).md"
    
    echo "[DONE] Draft saved in drafts/ folder."
else
    echo "[!] No new data to write."
fi
