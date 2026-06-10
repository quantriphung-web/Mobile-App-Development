-- =========================================================
-- MIGRATION SCRIPT: Node.js backend → Java Spring backend
-- Database: backend (localhost:5432)
-- Run with: psql -U postgres -d backend -f migrate_to_java.sql
-- =========================================================

-- ── 1. Tạo bảng roles (nếu chưa có) ─────────────────────
CREATE TABLE IF NOT EXISTS roles (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE
);

-- Chèn role mặc định
INSERT INTO roles (name) VALUES ('ADMIN'), ('STAFF'), ('CUSTOMER')
ON CONFLICT (name) DO NOTHING;

-- ── 2. Tạo bảng staff_accounts (User của Java backend) ───
CREATE TABLE IF NOT EXISTS staff_accounts (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id        UUID REFERENCES roles(id),
    first_name     VARCHAR(100) NOT NULL DEFAULT '',
    last_name      VARCHAR(100) NOT NULL DEFAULT '',
    phone_number   VARCHAR(100),
    email          VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    active         BOOLEAN NOT NULL DEFAULT TRUE,
    image          TEXT,
    placeholder    TEXT,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    provider       VARCHAR(20) NOT NULL DEFAULT 'LOCAL',
    provider_id    VARCHAR(255),
    created_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by     UUID,
    updated_by     UUID
);

-- ── 3. Migrate dữ liệu từ users → staff_accounts ─────────
-- Lấy role CUSTOMER id
DO $$
DECLARE
    v_customer_role_id UUID;
    v_admin_role_id    UUID;
BEGIN
    SELECT id INTO v_customer_role_id FROM roles WHERE name = 'CUSTOMER';
    SELECT id INTO v_admin_role_id    FROM roles WHERE name = 'ADMIN';

    -- Insert users không tồn tại trong staff_accounts (check theo email)
    INSERT INTO staff_accounts (
        id, role_id, first_name, last_name, phone_number,
        email, password_hash, active, image, placeholder,
        email_verified, provider, provider_id, created_at, updated_at
    )
    SELECT
        gen_random_uuid(),
        -- Email admin đầu tiên (quantriphung) → ADMIN, còn lại → CUSTOMER
        CASE
            WHEN u.email = (SELECT email FROM users ORDER BY id ASC LIMIT 1) THEN v_admin_role_id
            ELSE v_customer_role_id
        END,
        COALESCE(NULLIF(u.first_name, ''), SPLIT_PART(u.username, ' ', 1), 'User'),
        COALESCE(NULLIF(u.last_name,  ''), ''),
        u.phone_number,
        u.email,
        u.password,      -- password hash từ bcrypt, tương thích bcrypt Java
        COALESCE(u.active, TRUE),
        u.image,
        u.placeholder,
        FALSE,           -- email_verified
        CASE
            WHEN LOWER(COALESCE(u.auth_provider, 'local')) = 'google'   THEN 'GOOGLE'
            WHEN LOWER(COALESCE(u.auth_provider, 'local')) = 'facebook' THEN 'FACEBOOK'
            ELSE 'LOCAL'
        END,
        -- provider_id: dùng facebook_id nếu có, hoặc google_id
        COALESCE(u.facebook_id, u.google_id),
        COALESCE(u.created_at, NOW()),
        COALESCE(u.updated_at::TIMESTAMP, NOW())
    FROM users u
    WHERE u.email IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM staff_accounts sa WHERE sa.email = u.email
      );

    RAISE NOTICE 'Đã migrate % users → staff_accounts',
        (SELECT COUNT(*) FROM staff_accounts);
END;
$$;

-- ── 4. Tạo bảng refresh_tokens ───────────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token       TEXT NOT NULL UNIQUE,
    user_id     UUID NOT NULL REFERENCES staff_accounts(id) ON DELETE CASCADE,
    expiry_date TIMESTAMP NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ── 5. Tạo bảng customers (người mua hàng) ───────────────
CREATE TABLE IF NOT EXISTS customers (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name    VARCHAR(100),
    last_name     VARCHAR(100),
    email         TEXT,
    password_hash TEXT,
    active        BOOLEAN DEFAULT TRUE,
    registered_at TIMESTAMP DEFAULT NOW(),
    updated_at    TIMESTAMP DEFAULT NOW()
);

-- ── 6. Tạo bảng cards (giỏ hàng) ────────────────────────
CREATE TABLE IF NOT EXISTS cards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL
);

-- ── 7. Tạo bảng card_items ───────────────────────────────
CREATE TABLE IF NOT EXISTS card_items (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    card_id    UUID REFERENCES cards(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity   INTEGER DEFAULT 1
);

-- ── 8. Tạo bảng order_statuses ───────────────────────────
CREATE TABLE IF NOT EXISTS order_statuses (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100)
);
INSERT INTO order_statuses (name) VALUES ('PENDING'),('PROCESSING'),('SHIPPED'),('DELIVERED'),('CANCELLED')
ON CONFLICT DO NOTHING;

-- ── 9. Tạo bảng orders ───────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id                              VARCHAR(50) PRIMARY KEY,
    coupon_id                       UUID,
    customer_id                     UUID REFERENCES customers(id),
    order_status_id                 UUID REFERENCES order_statuses(id),
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    created_at                      TIMESTAMP DEFAULT NOW(),
    updated_at                      TIMESTAMP DEFAULT NOW()
);

-- ── 10. Tạo bảng order_items ──────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id   VARCHAR(50) REFERENCES orders(id),
    product_id UUID REFERENCES products(id),
    quantity   INTEGER DEFAULT 1,
    price      NUMERIC(19,4)
);

-- ── 11. Tạo bảng coupons ──────────────────────────────────
CREATE TABLE IF NOT EXISTS coupons (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code               VARCHAR(50),
    discount_value     NUMERIC(19,4),
    discount_type      VARCHAR(50),
    times_used         NUMERIC(19,4),
    max_usage          NUMERIC(19,4),
    order_amount_limit NUMERIC(19,4),
    coupon_start_date  TIMESTAMP,
    coupon_end_date    TIMESTAMP,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    created_by         UUID,
    updated_by         UUID
);

-- ── 12. Tạo bảng slideshows ───────────────────────────────
CREATE TABLE IF NOT EXISTS slideshows (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title           VARCHAR(80),
    destination_url TEXT,
    image           TEXT,
    placeholder     TEXT,
    description     VARCHAR(160),
    btn_label       VARCHAR(50),
    display_order   INTEGER,
    published       BOOLEAN DEFAULT FALSE,
    clicks          INTEGER DEFAULT 0,
    styles          TEXT,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW(),
    created_by      UUID,
    updated_by      UUID
);

-- ── 13. Tạo bảng gallery (ánh xạ từ product_images) ──────
CREATE TABLE IF NOT EXISTS gallery (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id   UUID REFERENCES products(id) ON DELETE CASCADE,
    image        TEXT,
    placeholder  TEXT,
    is_thumbnail BOOLEAN DEFAULT FALSE,
    created_at   TIMESTAMP DEFAULT NOW(),
    updated_at   TIMESTAMP DEFAULT NOW(),
    created_by   UUID,
    updated_by   UUID
);

-- Migrate product_images → gallery
INSERT INTO gallery (product_id, image, is_thumbnail, created_at)
SELECT
    product_id,
    image_url,
    (sort_order = 1),  -- sort_order = 1 → thumbnail
    COALESCE(created_at, NOW())
FROM product_images
WHERE NOT EXISTS (
    SELECT 1 FROM gallery g WHERE g.product_id = product_images.product_id
      AND g.image = product_images.image_url
);

-- ── 14. Tạo bảng suppliers ────────────────────────────────
CREATE TABLE IF NOT EXISTS suppliers (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255),
    email      TEXT,
    phone      VARCHAR(50),
    address    TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ── 15. Tạo bảng product_suppliers ───────────────────────
CREATE TABLE IF NOT EXISTS product_suppliers (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id  UUID REFERENCES products(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE CASCADE
);

-- ── 16. Tạo bảng notifications ───────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id),
    message     TEXT,
    is_read     BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMP DEFAULT NOW()
);

-- ── 17. Tạo bảng customer_addresses ──────────────────────
CREATE TABLE IF NOT EXISTS customer_addresses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    address     TEXT,
    city        VARCHAR(100),
    country     VARCHAR(100),
    postal_code VARCHAR(20),
    is_default  BOOLEAN DEFAULT FALSE
);

-- ── 18. Tạo bảng shipping_zones ───────────────────────────
CREATE TABLE IF NOT EXISTS shipping_zones (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255)
);

-- ── 19. Tạo bảng countries ────────────────────────────────
CREATE TABLE IF NOT EXISTS countries (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    code VARCHAR(10)
);

-- ── 20. Tạo bảng shipping_rates ───────────────────────────
CREATE TABLE IF NOT EXISTS shipping_rates (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shipping_zone_id UUID REFERENCES shipping_zones(id),
    min_weight       NUMERIC(19,4),
    max_weight       NUMERIC(19,4),
    rate             NUMERIC(19,4)
);

-- ── 21. Tạo bảng shipping_country_zones ──────────────────
CREATE TABLE IF NOT EXISTS shipping_country_zones (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_id       UUID REFERENCES countries(id),
    shipping_zone_id UUID REFERENCES shipping_zones(id)
);

-- ── 22. Tạo bảng sells ────────────────────────────────────
CREATE TABLE IF NOT EXISTS sells (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    quantity   INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ── 23. Thêm cột brand, size vào products nếu chưa có ────
ALTER TABLE products ADD COLUMN IF NOT EXISTS brand VARCHAR(100);
ALTER TABLE products ADD COLUMN IF NOT EXISTS size  VARCHAR(50);

-- ── 24. Thêm cột buying_price, disable_out_of_stock nếu chưa có ──
ALTER TABLE products ADD COLUMN IF NOT EXISTS disable_out_of_stock BOOLEAN DEFAULT TRUE;

-- ── Tạo variant tables ────────────────────────────────────
CREATE TABLE IF NOT EXISTS variants (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    name       VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS variant_options (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID REFERENCES variants(id) ON DELETE CASCADE,
    value      VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS variant_values (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_option_id UUID REFERENCES variant_options(id),
    product_id        UUID REFERENCES products(id)
);

-- ── Tạo attribute tables ──────────────────────────────────
CREATE TABLE IF NOT EXISTS attributes (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS attribute_values (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attribute_id UUID REFERENCES attributes(id),
    value        VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS product_attributes (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id   UUID REFERENCES products(id) ON DELETE CASCADE,
    attribute_id UUID REFERENCES attributes(id)
);

CREATE TABLE IF NOT EXISTS product_attribute_values (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id         UUID REFERENCES products(id) ON DELETE CASCADE,
    attribute_value_id UUID REFERENCES attribute_values(id)
);

-- ── Tạo product_shipping_info ────────────────────────────
CREATE TABLE IF NOT EXISTS product_shipping_info (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id       UUID UNIQUE REFERENCES products(id) ON DELETE CASCADE,
    weight           NUMERIC(19,4),
    weight_unit      VARCHAR(10),
    volume           NUMERIC(19,4),
    volume_unit      VARCHAR(10),
    dimension_width  NUMERIC(19,4),
    dimension_height NUMERIC(19,4),
    dimension_depth  NUMERIC(19,4),
    dimension_unit   VARCHAR(10)
);

-- ── Tạo product_coupons ───────────────────────────────────
CREATE TABLE IF NOT EXISTS product_coupons (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    coupon_id  UUID REFERENCES coupons(id) ON DELETE CASCADE
);

-- ── Tạo category_genres ───────────────────────────────────
CREATE TABLE IF NOT EXISTS category_genres (
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    genre       VARCHAR(255)
);

-- ── Tạo role_account (nếu cần) ───────────────────────────
-- Đã xong. staff_accounts.role_id FK → roles.id

SELECT 'Migration hoàn tất!' AS result,
       (SELECT COUNT(*) FROM staff_accounts) AS staff_count,
       (SELECT COUNT(*) FROM gallery)        AS gallery_count,
       (SELECT COUNT(*) FROM products)       AS product_count,
       (SELECT COUNT(*) FROM categories)     AS category_count;
