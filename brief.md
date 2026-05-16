# 📋 SQL Capability Assessment — Data Analyst HALOCAMP

**Take-Home Assignment · 36 Jam**

---

## 🎬 Skenario

Selamat! Kamu baru saja diterima sebagai **Data Analyst** di **TokoKita**, sebuah e-commerce yang menjual fashion, elektronik, kebutuhan rumah, dan kecantikan. Hari ini adalah hari pertama kamu.

Manager kamu, **Bu Sarah** (Head of CRM), baru saja kirim Slack:

> *"Hi, welcome! Tim CRM lagi siapin strategi Q1 2026, dan aku butuh insight dari data 2025 untuk presentasi ke leadership minggu depan. Aku udah kasih kamu akses ke database production (read-only). Tolong handle deliverable di bawah ini dalam 24 jam. Kalau ada yang nggak jelas, ping aja di group whatsapp HALOCAMP. Semangat!"*
>
> *— Bu Sarah*

Brief lengkap dari Bu Sarah ada di bawah.

---

## 📦 Yang Kamu Terima

1. **`01_schema.sql`** — file SQL berisi DDL. Jalankan schema ini ke database PostgreSQL kamu sebelum mulai.
2. **`02_seed_data.sql`** — file SQL berisi dummy data. Jalankan seed data ini ke database PostgreSQL kamu sebelum mulai.
3. **`03_buggy_queries.sql`** — file SQL berisi 3 query yang sudah ditulis oleh analyst sebelumnya tetapi bermasalah. File ini akan kamu pakai di **Milestone 4 (Debugging)**. Jangan diutak-atik sebelum sampai ke milestone tersebut.
4. **Brief** (file ini).

### Cara Setup Database

```bash
# 1. Buat schema (namespace) baru di dalam database PostgreSQL kamu dan Load schema struktur tabel
#    Jalankan di database default (biasanya 'postgres' atau username kamu)
psql -U postgres -d postgres -f 01_schema.sql

# 2. Load dummy data
psql -U postgres -d postgres -f 02_seed_data.sql

# 3. Verify load berhasil (harus 7 row dengan angka di sebelah nama tabel)
psql -U postgres -d postgres -c "
  SET search_path TO tokokita;
  SELECT 'customers' AS tbl, COUNT(*) FROM customers
  UNION ALL SELECT 'products', COUNT(*) FROM products
  UNION ALL SELECT 'orders', COUNT(*) FROM orders
  UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
  UNION ALL SELECT 'returns', COUNT(*) FROM returns
  UNION ALL SELECT 'promos', COUNT(*) FROM promos
  UNION ALL SELECT 'categories', COUNT(*) FROM categories;
"
```

**Catatan penting:**
- Setiap kali kamu mulai session SQL baru (di psql atau DBeaver), jalankan dulu `SET search_path TO tokokita;` sebelum query, supaya tabel-tabel terbaca tanpa harus prefix `tokokita.` di setiap query.
- Di DBeaver: setelah connect ke database `postgres`, expand **Schemas → tokokita → Tables** untuk lihat semua tabel.

---

## ⏰ Timeline

- **Mulai:** Hari ini, jam 09:00
- **Submit:** Besok, jam 21:00 (36 jam dari sekarang)
- **Late submission:** Tidak diterima. Submit *apa adanya* lebih baik daripada tidak submit.

---

## 📝 Deliverable — 5 Milestone

### Milestone 1 — Data Understanding & ERD (15%)

Sebelum kamu nulis query analisis, kamu harus paham **apa yang ada di database ini**.

**Tugas:**
1. **Eksplorasi 7 tabel** menggunakan SQL. Untuk tiap tabel, catat: jumlah row, range tanggal (kalau ada kolom tanggal), kolom yang sering NULL.
2. **Gambar ERD** dari database ini. Identifikasi PK, FK, dan tipe relasi (1-to-1, 1-to-many, many-to-many). Boleh pakai tools apa saja — draw.io, dbdiagram.io, Excalidraw, atau bahkan tangan di-foto. Output: 1 file gambar (PNG/JPG) atau link ke dbdiagram.io.
3. **Tulis minimal 8 observasi Data Quality** yang kamu temukan. Untuk tiap observasi, jelaskan:
   - Kolom/tabel mana yang bermasalah
   - Dimensi data quality apa yang dilanggar (Completeness / Consistency / Validity / Uniqueness / Accuracy)
   - Query SQL yang kamu pakai untuk menemukannya
   - Berapa banyak row yang terdampak
4. **Tulis 3 asumsi bisnis** yang akan kamu pakai di analisis berikutnya (contoh: *"Order dengan status `cancelled` saya anggap tidak masuk hitungan revenue."*)

**Output Milestone 1:**
- File `01_data_understanding.sql` (semua query eksplorasi)
- File `01_erd.png` atau link ERD
- File `01_observations.xlsx` (observasi DQ + asumsi), menggunakan struktur yang sudah pernah dijelaskan di pertemuan-pertemuan sebelumnya

---

### Milestone 2 — Business Metrics Foundation (25%)

Bu Sarah butuh dashboard metrik bulanan untuk presentasi. Hitung **6 metrik berikut per bulan** dan persiapkan dalam bentuk View dan Materialized View.

**Metrik yang dihitung:**

| Metrik | Definisi |
|---|---|
| `total_gmv` | Gross Merchandise Value: total nilai *semua* order, *sebelum* dikurangi discount apapun. |
| `total_revenue` | Hanya order `completed`, *sudah* dikurangi semua discount (item + order level). |
| `total_nmv` | Net Merchandise Value: order `completed` + `pending`, sudah dikurangi discount. |
| `loss_from_cancel` | Total nilai (sudah dikurangi discount) dari order `cancelled`. |
| `loss_from_return` | Total nilai (sudah dikurangi discount) dari order `returned`. |
| `discount_total` | Total semua discount yang diberikan (`item_discount` + `order_discount`) dari semua order. |

**Tugas tambahan:**
- Hitung juga **monthly retention rate**.
- Buat 1 **VIEW** untuk salah satu metric set.
- Buat 1 **MATERIALIZED VIEW** untuk metric set yang lain.
- Jelaskan di komentar query: kenapa kamu pilih View vs Materialized View untuk masing-masing.

**Catatan penting:**
- Hati-hati dengan data quality issues dari Milestone 1. Kamu harus *handle* dirty data sebelum hitung metrik, jangan biarkan baris bermasalah merusak angka.
- Granularity: per **bulan** (gunakan kolom `order_date`).
- Period: **Januari – Desember 2025**.

**Output Milestone 2:**
- File `02_business_metrics.sql` (query lengkap + DDL View dan Materialized View)

---

### Milestone 3 — Deep Dive Analysis (35%) ⭐

Ini bagian inti. Bu Sarah punya **5 pertanyaan bisnis** yang harus dijawab. Untuk setiap pertanyaan:
1. **Tulis query SQL** yang menjawab pertanyaan tersebut.
2. **Jelaskan hasilnya** dalam 3–5 kalimat naratif (di bawah query, sebagai komentar).

#### Pertanyaan 1 — Customer Segmentation by CLV

> *"Aku mau lihat siapa Top 10 customer kita berdasarkan Customer Lifetime Value (CLV). Selain itu, segmentasikan semua customer aktif kita ke 3 tier: **Low**, **Mid**, **High Value**. Tentukan threshold sendiri (justifikasi pilihan kamu). Tier mana yang paling worth difokuskan di Q1 dari segi kontribusi revenue?"*

Hint: CLV = total revenue per customer dari order completed. Pertimbangkan apakah mau pakai threshold persentil, nilai absolut, atau metode lain.

#### Pertanyaan 2 — Return Analysis

> *"Produk apa yang paling sering di-return? Apakah ada pola — misalnya dari kategori, brand, atau harga tertentu? Berapa rata-rata return rate per kategori, dan kategori mana yang paling 'bermasalah'?"*

Hint: Return rate = total return quantity / total order quantity untuk produk/kategori tersebut.

#### Pertanyaan 3 — Cohort Retention Analysis ⚠️ *(soal terberat)*

> *"Aku mau lihat behavior customer berdasarkan **bulan akuisisi** mereka (cohort). Untuk cohort yang akuisisi-nya antara Jan–Jun 2025, gimana retention rate mereka di bulan M+1, M+3, dan M+6? Bikin tabel cohort yang gampang dibaca, lalu kasih insight: cohort mana yang paling 'loyal', dan apakah ada pattern menarik?"*

Hint: Cohort customer = bulan order pertama mereka. Retention = % customer yang kembali order di periode tertentu setelah cohort_month.

#### Pertanyaan 4 — Discount Effectiveness

> *"Discount kita worth it nggak? Bandingkan customer yang **pernah pakai discount** vs **yang nggak pernah** di 2 dimensi: (a) Average Order Value, (b) Repeat purchase rate. Apa kesimpulan kamu — discount kita driving behavior yang positif atau cuma 'discount addiction'?"*

Hint: 'Pakai discount' = order ada `promo_id IS NOT NULL` atau `order_discount > 0` atau ada `item_discount > 0`.

#### Pertanyaan 5 — Free Find ⭐

> *"Berdasarkan eksplorasi kamu, kasih 1 insight surprising yang menurut kamu belum aku tanya tapi penting buat tim leadership tahu. Bisa apa aja — geographic pattern, payment method behavior, brand performance, seasonality, dll. Sertakan query dan rekomendasi action."*

Ini soal open-ended yang nilai paling tinggi-nya kalau jawabannya genuinely surprising dan actionable.

**Output Milestone 3:**
- File `03_deep_dive.sql` (5 query, masing-masing diberi header `-- Q1`, `-- Q2`, dst.)

---

### Milestone 4 — Code Review & Debugging (15%)

Bu Sarah forward kamu 3 query yang ditulis oleh analyst sebelumnya yang sudah resign. Ada masalah dengan ketiganya — kamu diminta fix.

File `04_buggy_queries.sql` (akan kami sertakan) berisi:

**Query A — Add a column.** Query sudah jalan dan menghasilkan monthly summary. Bu Sarah minta tambah kolom `avg_order_value` (revenue / jumlah order). Pertanyaan: di CTE mana kamu harus tambahkan?

**Query B — Fixing a broken query.** Query tiba-tiba error setelah ada data baru yang masuk. Cari root cause (hint: terkait NULL dan data quality), fix-nya, jelaskan di komentar.

**Query C — Logical bug (silent error).** Query *jalan* tanpa error, tapi angka revenue-nya dobel dari yang seharusnya. Telusuri mana yang salah (hint: JOIN granularity), fix, dan jelaskan kenapa salah.

**Output Milestone 4:**
- File `04_debugged_queries.sql` dengan ketiga query yang sudah difix + komentar penjelasan untuk masing-masing.

> Note: file `04_buggy_queries.sql` akan kamu terima terpisah dari mentor di awal sesi.

---

### Milestone 5 — Executive Summary (10%)

Tulis **1 dokumen 1–2 halaman** (PDF) untuk Bu Sarah sebagai *executive summary* dari semua analisis. Audience: leadership team yang **bukan technical**.

**Isi yang harus ada:**

1. **TL;DR** — 3–4 bullet point inti dari temuan.
2. **3 Rekomendasi Action** — konkret, prioritas, dan justifikasi dari data.
3. **Caveat / Limitasi** — apa saja asumsi yang kamu ambil, dan data apa yang sebenarnya kurang.

**Style guide:**
- Hindari jargon SQL (bukan "pakai LEFT JOIN", tapi "menggabungkan data customer dengan order").
- Pakai bahasa bisnis (revenue, retention, AOV — boleh; tapi bukan "CTE", "window function", dll).
- Visual boleh, tapi opsional — kalau bikin chart, sertakan sebagai gambar.

**Output Milestone 5:**
- File `05_executive_summary.pdf`.

---

## 📤 Submission Format

Submit dalam bentuk **1 folder ZIP** dengan struktur:

```
nama_lengkap_ujian_sql/
├── 01_data_understanding.sql
├── 01_erd.png 
├── 01_observations.xlsx
├── 02_business_metrics.sql
├── 03_deep_dive.sql
├── 04_debugged_queries.sql
└── 05_executive_summary.pdf
```

Upload di link google classroom paling lambat **jam 21:00 besok**.

---

## ⚖️ Aturan Main

✅ **Boleh:**
- Cari syntax SQL di dokumentasi PostgreSQL / Stack Overflow.
- Pakai DBeaver, psql, atau SQL client lain.
- Diskusi konseptual di group whatsapp (tapi bukan minta solusi langsung).
- Tanya klarifikasi soal ke mentor via DM atau group whatsapp.

❌ **Tidak boleh:**
- Copy-paste query dari peserta lain.
- Minta orang lain mengerjakan untukmu.
- Pakai AI assistant (ChatGPT, Claude, Copilot, Gemini, dll) untuk *menulis* query — boleh untuk explain konsep atau debug syntax error spesifik, tapi semua query final harus dari kepala kamu sendiri.

---

## 🎯 Apa yang Dinilai
- **Correctness** (40%) — query menghasilkan angka yang benar
- **Code Quality** (30%) — readability, struktur, naming
- **Analytical Thinking** (20%) — kedalaman insight, justifikasi keputusan
- **Communication** (10%) — kualitas penjelasan & executive summary

---

## 💡 Tips Akhir

- **Mulai dari Milestone 1.** Jangan loncat ke analisis sebelum paham struktur data. Peserta yang terburu-buru di awal selalu kerja dua kali.
- **Manage waktu kamu.** Pembagian kasar yang kami sarankan (36 jam, 09:00 hari ke-1 → 21:00 hari ke-2):

  **Hari ke-1:**
  - 09:00–13:00 → Milestone 1 (4 jam)
  - 13:00–17:00 → Milestone 2 (4 jam)
  - 17:00–23:00 → Milestone 3 bagian 1 (6 jam, dengan istirahat)
  - **Tidur. Seriously.** Jam 23:00–07:00.

  **Hari ke-2:**
  - 07:00–12:00 → Milestone 3 bagian 2 (5 jam) — total Milestone 3: 11 jam
  - 12:00–16:00 → Milestone 4 (4 jam)
  - 16:00–20:00 → Milestone 5 (4 jam)
  - 20:00–21:00 → Final review (1 jam)

- **Quality > Quantity.** Lebih baik 3 query yang clean dan benar daripada 5 query yang berantakan.
- **Commit early, commit often.** Save file kamu tiap selesai 1 milestone.
- **Kalau stuck >30 menit di 1 soal, lompat dulu.** Balik nanti.

Good luck! 🚀

— Tim HALOCAMP
