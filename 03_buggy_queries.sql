-- ============================================================
-- MILESTONE 4 — BUGGY QUERIES TO DEBUG
-- ============================================================
-- Berikut 3 query yang ditulis oleh analyst sebelumnya.
-- Ketiganya bermasalah dengan cara yang berbeda.
-- Tugas kamu: identifikasi, fix, dan jelaskan di komentar.
--
-- Simpan jawaban kamu di file: 04_debugged_queries.sql
-- Format jawaban untuk setiap query:
--   -- ============ QUERY A — DEBUGGED ============
--   -- BUG ANALYSIS:
--   -- [Apa yang salah? Kenapa salah?]
--   --
--   -- FIX:
--   -- [Apa yang kamu ubah dan kenapa?]
--   [query yang sudah difix]
-- ============================================================


-- ============ QUERY A ============
-- Konteks: Bu Sarah minta dashboard monthly performance.
-- Query ini sudah jalan dan menghasilkan output yang benar untuk metrik
-- yang ada sekarang. Tapi Bu Sarah minta tambah 1 kolom baru:
-- "Average Order Value" (revenue / jumlah unique order completed).
--
-- TUGAS:
-- Tambahkan kolom `avg_order_value` di output akhir.
-- Pastikan kamu menambahkannya di CTE yang tepat — jangan hanya hitung
-- di SELECT final tanpa memikirkan granularity.

WITH order_items_clean AS (
    SELECT
        oi.order_id,
        oi.quantity,
        oi.unit_price,
        oi.item_discount,
        o.order_status,
        o.order_discount,
        DATE_TRUNC('month', o.order_date)::date AS order_month
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.quantity > 0
      AND oi.unit_price > 0
),
order_revenue AS (
    SELECT
        order_id,
        order_status,
        order_month,
        SUM(quantity * unit_price - item_discount) - MAX(order_discount) AS net_value
    FROM order_items_clean
    GROUP BY order_id, order_status, order_month
),
monthly_summary AS (
    SELECT
        order_month,
        SUM(CASE WHEN order_status = 'completed' THEN net_value ELSE 0 END) AS revenue,
        SUM(CASE WHEN order_status = 'cancelled' THEN net_value ELSE 0 END) AS loss_cancel,
        COUNT(DISTINCT CASE WHEN order_status = 'completed' THEN order_id END) AS completed_orders
    FROM order_revenue
    GROUP BY order_month
)
SELECT
    TO_CHAR(order_month, 'YYYY-MM') AS month,
    revenue,
    loss_cancel,
    completed_orders
FROM monthly_summary
ORDER BY order_month;


-- ============ QUERY B ============
-- Konteks: Query ini SEBELUMNYA jalan dan dipakai oleh tim Merchandising
-- untuk evaluate margin per produk. Tapi sejak minggu lalu setelah ada
-- batch produk baru di-input oleh tim Operations (untuk persiapan
-- promo Q1), query ini error setiap dijalankan.
--
-- Tim Operations bilang: "Beberapa product baru itu masih nunggu data
-- biaya dari supplier, jadi sementara kami input apa adanya dulu."
--
-- TUGAS:
-- Jalankan query ini, lihat pesan error apa yang muncul.
-- Cari root cause-nya — operasi matematika mana yang bermasalah,
-- dan kenapa data baru men-trigger error tersebut.
-- Fix query supaya jalan lagi tanpa mengubah maksud bisnis (tetap
-- mengukur markup percentage per produk).
--
-- HINT: scan dulu data di tabel products. Apakah ada nilai yang
-- nggak masuk akal di kolom yang dipakai di query ini?

SELECT
    p.product_id,
    p.product_name,
    p.brand,
    p.cost,
    p.current_price,
    (p.current_price - p.cost) / p.cost * 100 AS markup_pct,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS gross_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
  AND oi.quantity > 0
GROUP BY p.product_id, p.product_name, p.brand, p.cost, p.current_price
HAVING SUM(oi.quantity) > 0
ORDER BY markup_pct DESC
LIMIT 20;


-- ============ QUERY C ============
-- Konteks: Query ini "jalan" tanpa error. Hasilnya keluar berupa
-- monthly revenue dan total return loss per bulan.
-- TAPI Bu Sarah complain: "Angka return_loss di sini kok jauh lebih besar
-- dari yang aku lihat di laporan internal tim Logistik? Di laporan mereka,
-- return loss kita kurang lebih Rp 1,1 Milyar setahun, tapi di output
-- query ini totalnya bisa hampir Rp 2,2 Milyar."
--
-- Tim Logistik dan kami pakai data source yang sama. Berarti ada
-- sesuatu yang salah dengan query ini — tapi tanpa error message.
--
-- TUGAS:
-- Telusuri query baris per baris. Identifikasi kenapa angka return_loss
-- inflated, lalu fix supaya hasilnya match dengan kenyataan.
--
-- HINT: pertanyaan kunci yang harus kamu tanyakan ke diri sendiri:
-- "Berapa baris yang dihasilkan tiap JOIN? Apakah granularity-nya
-- konsisten sepanjang query? Apakah semua JOIN yang ditulis di sini
-- benar-benar diperlukan untuk metrik yang dihasilkan?"

WITH order_data AS (
    SELECT
        o.order_id,
        o.order_status,
        DATE_TRUNC('month', o.order_date)::date AS order_month,
        oi.order_item_id,
        oi.quantity,
        oi.unit_price,
        oi.item_discount
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN returns r ON o.order_id = r.order_id
    WHERE oi.quantity > 0
      AND oi.unit_price > 0
),
monthly_metrics AS (
    SELECT
        order_month,
        SUM(CASE WHEN order_status = 'completed'
                 THEN quantity * unit_price - item_discount
                 ELSE 0 END) AS revenue,
        SUM(CASE WHEN order_status = 'returned'
                 THEN quantity * unit_price - item_discount
                 ELSE 0 END) AS return_loss
    FROM order_data
    GROUP BY order_month
)
SELECT
    TO_CHAR(order_month, 'YYYY-MM') AS month,
    revenue,
    return_loss
FROM monthly_metrics
ORDER BY order_month;


-- ============================================================
-- END OF BUGGY QUERIES
-- ============================================================
