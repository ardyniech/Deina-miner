# Deina-Knowledge-Miner 

**Status:** Active / YOLO-Mode  
**Target Architecture:** Low-Spec Linux Servers (Optimized for Vaio/Laptop nodes)  

Claw-Knowledge-Miner adalah sistem otonom 24/7 yang dirancang untuk mengumpulkan, memfilter, dan mensintesis pengetahuan teknis dari internet. Menggunakan pendekatan **Zero-Token Auditing**, sistem ini meminimalkan penggunaan LLM pada tahap awal pencarian dan deduplikasi, mengandalkan komputasi ringan (Bash, Hash, SQLite) untuk menjaga efisiensi *resource* dan menstabilkan suhu perangkat keras keras.

Sistem ini didesain sebagai modul independen yang sejalan dengan prinsip *self-healing* dan *autonomous operation* pada ekosistem **OpenClaw**.

---

## 🚀 Key Features

* **Zero-Token Efficiency:** Deduplikasi artikel secara mekanis menggunakan *text normalization* dan SHA-256 Checksum, menghilangkan kebutuhan *prompting* berulang yang menguras komputasi.
* **Thermal & Resource Guard:** Terintegrasi dengan sensor suhu sistem (`/sys/class/thermal/`) untuk otomatis melakukan *throttle* atau *sleep* saat suhu mendekati ambang batas kritis (68°C+).
* **Mechanical Discovery (Scout):** Dorking otomatis menggunakan metode *low-footprint* (curl + text parser) tanpa bergantung pada API berbayar.
* **On-Demand AI Synthesis:** Eksekusi `llama.cpp` (GGUF Models) dalam mode *one-shot* hanya pada jadwal tertentu (misal: tengah malam) untuk merangkai fakta unik menjadi dokumen Markdown yang terstruktur.
* **Conflict Logging:** Mendeteksi tabrakan instruksi teknis antar sumber informasi untuk diselesaikan kemudian oleh LLM.

---

## 📂 Project Structure

\`\`\`text
/Deina-miner/
├── core/
│   ├── main.sh         # Orchestrator utama (The Loop)
│   ├── scout.sh        # Modul pencari URL otomatis
│   ├── auditor.sh      # Mekanisme hashing & validasi SQLite
│   └── writer.sh       # Trigger eksekusi llama.cpp
├── db/
│   └── knowledge.db    # SQLite3 Database (WAL mode enabled)
├── drafts/             # Output sintesis AI (.md)
├── logs/               # Log aktivitas sistem & status thermal
├── init_db.sh          # Skrip inisialisasi struktur database
└── README.md           # Dokumentasi ini
\`\`\`

---

## ⚙️ Prerequisites

Karena sistem ini menghindari *runtime* berat seperti Node.js atau Python environment, Anda hanya membutuhkan perangkat bawaan Linux dan beberapa *tools* ringan:

* `bash` (Standard shell)
* `sqlite3` (Database management)
* `curl` (Network requests)
* `pandoc` (HTML to plain text/markdown conversion)
* `llama.cpp` (Untuk fase *writer* - pastikan *binary* dan model GGUF sudah tersedia)

---

## 🛠️ Installation & Setup

**1. Clone the Repository**
\`\`\`bash
git clone <YOUR_GITHUB_REPO_URL>
cd Deina-miner
\`\`\`

**2. Make Scripts Executable**
\`\`\`bash
chmod +x init_db.sh
chmod +x core/*.sh
\`\`\`

**3. Initialize the Database**
Skrip ini akan membangun tabel (`scout_queue`, `knowledge_archive`, `conflict_logs`) dan mengaktifkan mode WAL untuk performa I/O terbaik.
\`\`\`bash
./init_db.sh
\`\`\`

**4. Configure Paths**
Buka file `core/writer.sh` dan sesuaikan *path* menuju *binary* `llama.cpp` dan file model GGUF yang Anda gunakan:
\`\`\`bash
LLAMA_PATH="/path/to/llama.cpp/main"
MODEL_PATH="/path/to/model.gguf"
\`\`\`

---

## ⚡ Running the Miner (YOLO Mode)

Sistem dirancang untuk ditinggal tanpa intervensi. Gunakan `screen`, `tmux`, atau bungkus dalam `systemd` service agar proses tetap berjalan di *background*.

\`\`\`bash
cd core
screen -S claw_miner ./main.sh
\`\`\`

Untuk keluar dari *screen* dan membiarkannya berjalan, tekan `Ctrl+A`, lalu `D`.

---

## 📊 Database Schema Summary

| Table | Purpose |
| :--- | :--- |
| `scout_queue` | Menyimpan URL mentah hasil dorking yang menunggu proses audit. |
| `knowledge_archive` | Menyimpan teks bersih, URL sumber, dan Hash SHA-256 (Data Unik). |
| `conflict_logs` | Mencatat anomali/perbedaan instruksi teknis antar sumber informasi. |

---

## 🛡️ License

Private / Custom deployment.
