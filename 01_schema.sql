-- ============================================================
-- E-COMMERCE CRM SCHEMA
-- Database setup for Data Analyst HALOCAMP - 24-hour Final Exam
-- ============================================================

-- Create "namespace"
CREATE SCHEMA IF NOT EXISTS tokokita;
SET search_path TO tokokita, public;

-- ============================================================
-- 1. CUSTOMERS
-- Master data for registered customers
-- ============================================================
CREATE TABLE customers (
    customer_id        INTEGER PRIMARY KEY,
    customer_name      VARCHAR(100),
    email              VARCHAR(100),
    phone              VARCHAR(20),
    gender             VARCHAR(10),
    birth_date         DATE,
    registration_date  TIMESTAMP NOT NULL,
    city               VARCHAR(50),
    province           VARCHAR(50)
);

-- ============================================================
-- 2. CATEGORIES
-- Product category hierarchy (parent -> child)
-- ============================================================
CREATE TABLE categories (
    category_id         INTEGER PRIMARY KEY,
    category_name       VARCHAR(50) NOT NULL,
    parent_category_id  INTEGER REFERENCES categories(category_id)
);

-- ============================================================
-- 3. PRODUCTS
-- Product catalog
-- ============================================================
CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category_id     INTEGER REFERENCES categories(category_id),
    brand           VARCHAR(50),
    current_price   NUMERIC(12,2) NOT NULL,
    cost            NUMERIC(12,2),
    created_at      DATE NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 4. PROMOS
-- Master voucher/promo data
-- ============================================================
CREATE TABLE promos (
    promo_id        INTEGER PRIMARY KEY,
    promo_code      VARCHAR(30) NOT NULL,
    promo_type      VARCHAR(20) NOT NULL,
    discount_value  NUMERIC(12,2) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    min_purchase    NUMERIC(12,2) DEFAULT 0
);

-- ============================================================
-- 5. ORDERS
-- Order header
-- ============================================================
CREATE TABLE orders (
    order_id          VARCHAR(20) PRIMARY KEY,
    customer_id       INTEGER REFERENCES customers(customer_id),
    order_date        TIMESTAMP NOT NULL,
    order_status      VARCHAR(20) NOT NULL,
    payment_method    VARCHAR(30),
    shipping_city     VARCHAR(50),
    shipping_province VARCHAR(50),
    order_discount    NUMERIC(12,2) DEFAULT 0,
    promo_id          INTEGER REFERENCES promos(promo_id)
);

-- ============================================================
-- 6. ORDER_ITEMS
-- Order line items (1 order = many items)
-- ============================================================
CREATE TABLE order_items (
    order_item_id   BIGINT PRIMARY KEY,
    order_id        VARCHAR(20) NOT NULL REFERENCES orders(order_id),
    product_id      INTEGER REFERENCES products(product_id),
    quantity        INTEGER,
    unit_price      NUMERIC(12,2),
    item_discount   NUMERIC(12,2) DEFAULT 0
);

-- ============================================================
-- 7. RETURNS
-- Product return records
-- ============================================================
CREATE TABLE returns (
    return_id        INTEGER PRIMARY KEY,
    order_id         VARCHAR(20) NOT NULL REFERENCES orders(order_id),
    order_item_id    BIGINT REFERENCES order_items(order_item_id),
    return_date      DATE NOT NULL,
    return_reason    VARCHAR(100),
    return_quantity  INTEGER
);

-- ============================================================
-- Useful indexes for query performance
-- ============================================================
CREATE INDEX idx_orders_customer    ON orders(customer_id);
CREATE INDEX idx_orders_date        ON orders(order_date);
CREATE INDEX idx_orders_status      ON orders(order_status);
CREATE INDEX idx_orderitems_order   ON order_items(order_id);
CREATE INDEX idx_orderitems_product ON order_items(product_id);
CREATE INDEX idx_returns_order      ON returns(order_id);
CREATE INDEX idx_products_category  ON products(category_id);
