import bcrypt from 'bcryptjs';
import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import jwt from 'jsonwebtoken';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const jwtSecret = process.env.JWT_SECRET || 'dev_secret_change_me';
const jwtExpiresIn = process.env.JWT_EXPIRES_IN || '1d';
const { Pool } = pg;

const pool = new Pool({
  connectionString:
    process.env.DATABASE_URL ||
    'postgres://postgres:postgres@localhost:5432/backend',
});

app.use(cors());
app.use(express.json());

// ── Serve ảnh đã tải về local ──────────────────────────────────────────────
// Truy cập: http://<host>:3000/images/<filename>
app.use('/images', express.static(path.join(__dirname, '../assets/images')));

// ── Serve ảnh upload từ review ───────────────────────────────────────────────
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
app.use('/uploads', express.static(uploadsDir));

// ── Multer config ─────────────────────────────────────────────────────────────
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `review_${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) cb(null, true);
    else cb(new Error('Only image files are allowed'));
  },
});

async function ensureSchema() {
  // Tạo bảng nếu chưa có (email nullable để hỗ trợ FB không có email)
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id          SERIAL PRIMARY KEY,
      username    VARCHAR(50)  UNIQUE NOT NULL,
      email       VARCHAR(100) UNIQUE,
      password    VARCHAR(255) NOT NULL,
      facebook_id VARCHAR(255) UNIQUE,
      created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // Migrate nếu bảng đã tồn tại: bỏ NOT NULL trên email
  await pool.query(`
    ALTER TABLE users ALTER COLUMN email DROP NOT NULL
  `).catch(() => {});

  // Migrate: thêm cột facebook_id nếu chưa có
  await pool.query(`
    ALTER TABLE users ADD COLUMN IF NOT EXISTS facebook_id VARCHAR(255) UNIQUE
  `).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name   VARCHAR(100)`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name    VARCHAR(100)`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR(100)`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS role_id      INTEGER`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS active       BOOLEAN DEFAULT TRUE`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS image        TEXT`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS placeholder  TEXT`).catch(() => {});
  await pool.query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP`).catch(() => {});

  // Migrate: thêm cột photo_urls vào product_reviews nếu chưa có
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_reviews (
      id            SERIAL PRIMARY KEY,
      product_id    VARCHAR(50) NOT NULL,
      user_id       INTEGER,
      reviewer_name VARCHAR(100),
      avatar_letter VARCHAR(5),
      avatar_color  VARCHAR(20),
      rating        INTEGER DEFAULT 5,
      review_text   TEXT,
      review_date   VARCHAR(50),
      has_photo     BOOLEAN DEFAULT FALSE,
      helpful_count INTEGER DEFAULT 0,
      photo_urls    TEXT[],
      created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `).catch(() => {});
  await pool.query(`ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS photo_urls TEXT[]`).catch(() => {});
  await pool.query(`ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS helpful_count INTEGER DEFAULT 0`).catch(() => {});
  await pool.query(`ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS user_id INTEGER`).catch(() => {});
  // Try to add foreign key constraint (ignore if already exists)
  await pool.query(`ALTER TABLE product_reviews ADD CONSTRAINT product_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL`).catch(() => {});
}

function createToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      username: user.username,
      email: user.email,
    },
    jwtSecret,
    { expiresIn: jwtExpiresIn },
  );
}

function requireFields(fields, body) {
  for (const field of fields) {
    if (!body[field] || String(body[field]).trim() === '') {
      return `${field} is required`;
    }
  }
  return null;
}

function normalizeUsername(value, email) {
  const fallback = (email || 'user').split('@')[0] || 'user';
  const normalized = String(value || fallback)
    .trim()
    .replace(/\s+/g, ' ');
  return normalized.slice(0, 50) || fallback.slice(0, 50) || 'user';
}

async function createUniqueUsername(baseUsername, email) {
  const base = normalizeUsername(baseUsername, email);
  let username = base;
  let suffix = 1;

  while (true) {
    const existing = await pool.query(
      'SELECT id FROM users WHERE username = $1 LIMIT 1',
      [username],
    );

    if (existing.rowCount === 0) {
      return username;
    }

    suffix += 1;
    const suffixText = ` ${suffix}`;
    username = `${base.slice(0, 50 - suffixText.length)}${suffixText}`;
  }
}

async function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const [scheme, token] = authHeader.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Bearer token is required' });
  }

  try {
    req.user = jwt.verify(token, jwtSecret);
    return next();
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.post(['/signup', '/api/auth/register'], async (req, res) => {
  const validationError = requireFields(['username', 'email', 'password'], req.body);
  if (validationError) {
    return res.status(400).json({ message: validationError });
  }

  const username     = String(req.body.username).trim();
  const email        = String(req.body.email).trim().toLowerCase();
  const passwordHash = await bcrypt.hash(String(req.body.password), 10);

  // ✅ Tách username → first_name + last_name
  const parts      = username.split(/\s+/);
  const last_name  = parts.length > 1 ? parts.pop() : '';
  const first_name = parts.join(' ');

  try {
    const result = await pool.query(
      `INSERT INTO users (username, email, password, first_name, last_name, active, updated_at)
       VALUES ($1, $2, $3, $4, $5, TRUE, NOW())
       RETURNING id, username, email, first_name, last_name`,
      [username, email, passwordHash, first_name, last_name],
    );

    const user = result.rows[0];
    return res.status(201).json({ token: createToken(user), user });
  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ message: 'Username or email already exists' });
    }
    console.error(error);
    return res.status(500).json({ message: 'Signup failed' });
  }
});

app.post(['/login', '/api/auth/login'], async (req, res) => {
  const validationError = requireFields(['email', 'password'], req.body);

  if (validationError) {
    return res.status(400).json({ message: validationError });
  }

  const email = String(req.body.email).trim().toLowerCase();
  const password = String(req.body.password);

  try {
    const result = await pool.query(
      'SELECT id, username, email, password FROM users WHERE email = $1 LIMIT 1',
      [email],
    );

    if (result.rowCount === 0) {
      return res.status(401).json({ message: 'Email or password is incorrect' });
    }

    const user = result.rows[0];
    const passwordMatches = await bcrypt.compare(password, user.password);

    if (!passwordMatches) {
      return res.status(401).json({ message: 'Email or password is incorrect' });
    }

    return res.json({
      token: createToken(user),
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Login failed' });
  }
});

app.get(['/me', '/api/me'], authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, username, email FROM users WHERE id = $1 LIMIT 1',
      [req.user.sub],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load user' });
  }
});

app.post(['/google-login', '/api/auth/google'], async (req, res) => {
  const validationError = requireFields(['email', 'username'], req.body);

  if (validationError) {
    return res.status(400).json({ message: validationError });
  }

  const email = String(req.body.email).trim().toLowerCase();
  const username = normalizeUsername(req.body.username, email);
  const createAccount =
    req.body.createAccount === true || req.body.createAccount === 'true';

  try {
    const existingUserResult = await pool.query(
      'SELECT id, username, email FROM users WHERE email = $1 LIMIT 1',
      [email],
    );

    let user = existingUserResult.rows[0];

    if (!user && !createAccount) {
      return res
        .status(404)
        .json({ message: 'Google account is not registered' });
    }

    if (!user) {
      const uniqueUsername = await createUniqueUsername(username, email);
      const passwordHash = await bcrypt.hash('google_oauth', 10);
      const parts = uniqueUsername.split(/\s+/);
const g_last  = parts.length > 1 ? parts.pop() : '';
const g_first = parts.join(' ');

const newUserResult = await pool.query(
  `INSERT INTO users (username, email, password, first_name, last_name, active, updated_at)
   VALUES ($1, $2, $3, $4, $5, TRUE, NOW())
   RETURNING id, username, email`,
  [uniqueUsername, email, passwordHash, g_first, g_last],
);
      user = newUserResult.rows[0];
    }

    return res.json({
      token: createToken(user),
      user,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Google login failed' });
  }
});

app.post(['/facebook-login', '/api/auth/facebook'], async (req, res) => {
  const validationError = requireFields(['email', 'username'], req.body);

  if (validationError) {
    return res.status(400).json({ message: validationError });
  }

  const email = String(req.body.email).trim().toLowerCase();
  const username = normalizeUsername(req.body.username, email);
  const createAccount =
    req.body.createAccount === true || req.body.createAccount === 'true';

  // Lấy facebook_id từ body (Flutter gửi lên) hoặc parse từ email placeholder
  const facebookId =
    req.body.facebook_id?.toString().trim() ||
    (email.startsWith('fb_') ? email.split('@')[0].replace('fb_', '') : null);

  try {
    // ✅ Tìm user theo facebook_id trước (chính xác hơn)
    // Fallback tìm theo email nếu không có facebook_id
    let existingResult;
    if (facebookId) {
      existingResult = await pool.query(
        'SELECT id, username, email FROM users WHERE facebook_id = $1 LIMIT 1',
        [facebookId],
      );
    }

    // Nếu không tìm thấy qua facebook_id, thử tìm qua email
    if (!facebookId || existingResult.rowCount === 0) {
      existingResult = await pool.query(
        'SELECT id, username, email FROM users WHERE email = $1 LIMIT 1',
        [email],
      );
    }

    let user = existingResult.rows[0];

    if (!user && !createAccount) {
      return res
        .status(404)
        .json({ message: 'Facebook account is not registered' });
    }

    if (!user) {
      // Tạo tài khoản mới
      const uniqueUsername = await createUniqueUsername(username, email);
      const passwordHash = await bcrypt.hash('facebook_oauth', 10);
      const parts = uniqueUsername.split(/\s+/);
const f_last  = parts.length > 1 ? parts.pop() : '';
const f_first = parts.join(' ');

const newUserResult = await pool.query(
  `INSERT INTO users (username, email, password, facebook_id, first_name, last_name, active, updated_at)
   VALUES ($1, $2, $3, $4, $5, $6, TRUE, NOW())
   RETURNING id, username, email`,
  [uniqueUsername, email, passwordHash, facebookId || null, f_first, f_last],
);
      user = newUserResult.rows[0];
    } else if (facebookId && !user.facebook_id) {
      // Cập nhật facebook_id cho user cũ chưa có
      await pool.query(
        'UPDATE users SET facebook_id = $1 WHERE id = $2',
        [facebookId, user.id],
      );
    }

    return res.json({
      token: createToken(user),
      user,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Facebook login failed' });
  }
});

ensureSchema()
  .then(() => {
    app.listen(port, () => {
      console.log(`Auth API listening on http://localhost:${port}`);
    });
  })
  .catch((error) => {
    console.error('Cannot initialize PostgreSQL schema');
    console.error(error);
    process.exit(1);
  });

  // Lấy sản phẩm sale (product_type = 'sale')
app.get(['/products/sale', '/api/products/sale'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM products 
       WHERE product_type = 'sale' AND published = TRUE
       ORDER BY created_at DESC`
    );
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load sale products' });
  }
});

// Lấy sản phẩm new (product_type = 'new')
app.get(['/products/new', '/api/products/new'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM products 
       WHERE product_type = 'new' AND published = TRUE
       ORDER BY created_at DESC`
    );
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load new products' });
  }
});
app.post(['/products', '/api/products'], async (req, res) => {
  const {
    slug, product_name, sku, sale_price, compare_price,
    short_description, product_description, product_type,
    published, image
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO products 
        (slug, product_name, sku, sale_price, compare_price, short_description, 
         product_description, product_type, published, image)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING *`,
      [slug, product_name, sku, sale_price, compare_price,
       short_description, product_description, product_type,
       published ?? true, image]
    );
    return res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot create product' });
  }
});
app.patch(['/products/:id', '/api/products/:id'], async (req, res) => {
  const { id } = req.params;
  const fields = req.body;

  // Tạo dynamic SET clause: { product_type: 'sale', sale_price: 10 } → "product_type=$1, sale_price=$2"
  const keys = Object.keys(fields);
  if (keys.length === 0) {
    return res.status(400).json({ message: 'No fields to update' });
  }

  const setClause = keys.map((key, i) => `${key} = $${i + 1}`).join(', ');
  const values = Object.values(fields);

  try {
    const result = await pool.query(
      `UPDATE products SET ${setClause}, updated_at = NOW()
       WHERE id = $${keys.length + 1}
       RETURNING *`,
      [...values, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot update product' });
  }
});
app.put(['/products/:id', '/api/products/:id'], async (req, res) => {
  const { id } = req.params;
  const {
    slug, product_name, sku, sale_price, compare_price,
    short_description, product_description, product_type,
    published, image
  } = req.body;

  try {
    const result = await pool.query(
      `UPDATE products SET
        slug = $1,
        product_name = $2,
        sku = $3,
        sale_price = $4,
        compare_price = $5,
        short_description = $6,
        product_description = $7,
        product_type = $8,
        published = $9,
        image = $10,
        updated_at = NOW()
       WHERE id = $11
       RETURNING *`,
      [slug, product_name, sku, sale_price, compare_price,
       short_description, product_description, product_type,
       published, image, id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot update product' });
  }
});
// ═══════════════════════════════════════════════════════════════════
// THÊM CÁC ĐOẠN NÀY VÀO CUỐI FILE server.js (trước dòng cuối cùng)
// ═══════════════════════════════════════════════════════════════════

// ── GET /products ────────────────────────────────────────────────────
// Query params: ?category_id=&sort=price_asc|price_desc|newest|popular|rating
//               &min_price=&max_price=&published=true
app.get(['/products', '/api/products'], async (req, res) => {
  try {
    const {
      category_id,
      sort = 'newest',
      min_price,
      max_price,
      published = 'true',
    } = req.query;

    const params = [];
    let paramIdx = 1;
    const conditions = ['1=1'];
    const joins = [];

    if (published !== 'all') {
      conditions.push(`p.published = $${paramIdx++}`);
      params.push(published === 'true');
    }

    if (category_id) {
      joins.push(`INNER JOIN product_categories pc ON pc.product_id = p.id`);
      conditions.push(`pc.category_id = $${paramIdx++}`);
      params.push(category_id);
    }

    if (min_price) {
      conditions.push(`p.sale_price >= $${paramIdx++}`);
      params.push(Number(min_price));
    }

    if (max_price) {
      conditions.push(`p.sale_price <= $${paramIdx++}`);
      params.push(Number(max_price));
    }

    const sortMap = {
      price_asc:  'p.sale_price ASC',
      price_desc: 'p.sale_price DESC',
      newest:     'p.created_at DESC',
      popular:    'p.quantity DESC',
      rating:     'p.created_at DESC',
    };

    const query = `
      SELECT p.*,
        img.images
      FROM products p
      ${joins.join(' ')}
      LEFT JOIN LATERAL (
        SELECT COALESCE(json_agg(pi2.image_url ORDER BY pi2.sort_order), '[]'::json) AS images
        FROM product_images pi2
        WHERE pi2.product_id = p.id
      ) img ON true
      WHERE ${conditions.join(' AND ')}
      ORDER BY ${sortMap[sort] || sortMap.newest}
    `;

    const result = await pool.query(query, params);
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load products' });
  }
});

// ── GET /products/:id ────────────────────────────────────────────────
app.get(['/products/:id', '/api/products/:id'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*,
        COALESCE(
          json_agg(DISTINCT c.*) FILTER (WHERE c.id IS NOT NULL), '[]'
        ) AS categories,
        COALESCE(
          json_agg(DISTINCT t.*) FILTER (WHERE t.id IS NOT NULL), '[]'
        ) AS tags,
        (
          SELECT COALESCE(json_agg(pi2.image_url ORDER BY pi2.sort_order), '[]'::json)
          FROM product_images pi2
          WHERE pi2.product_id = p.id
        ) AS images
      FROM products p
      LEFT JOIN product_categories pc ON pc.product_id = p.id
      LEFT JOIN categories c ON c.id = pc.category_id
      LEFT JOIN product_tags pt ON pt.product_id = p.id
      LEFT JOIN tags t ON t.id = pt.tag_id
      WHERE p.id = $1
      GROUP BY p.id`,
      [req.params.id]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }
    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load product' });
  }
});

// ── GET /categories ──────────────────────────────────────────────────
// Query params: ?parent_id=  (để lấy sub-categories)
//               ?root=true   (chỉ lấy categories gốc)
app.get(['/categories', '/api/categories'], async (req, res) => {
  try {
    const { parent_id, root } = req.query;
    let query = `SELECT * FROM categories WHERE active = TRUE`;
    const params = [];

    if (root === 'true') {
      query += ` AND parent_id IS NULL`;
    } else if (parent_id) {
      query += ` AND parent_id = $1`;
      params.push(parent_id);
    }

    query += ` ORDER BY category_name ASC`;

    const result = await pool.query(query, params);
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load categories' });
  }
});

// ── GET /categories/:id ──────────────────────────────────────────────
app.get(['/categories/:id', '/api/categories/:id'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM categories WHERE id = $1 AND active = TRUE`,
      [req.params.id]
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Category not found' });
    }
    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load category' });
  }
});

// ── GET /brands ──────────────────────────────────────────────────────
// Lấy danh sách brand duy nhất từ bảng products (không có bảng brands riêng)
app.get(['/brands', '/api/brands'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT DISTINCT product_type AS brand
       FROM products
       WHERE product_type IS NOT NULL AND published = TRUE
       ORDER BY brand ASC`
    );
    return res.json(result.rows.map(r => r.brand));
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load brands' });
  }
});
// ── GET /products/:id/related ────────────────────────────────────────
app.get(['/products/:id/related', '/api/products/:id/related'], async (req, res) => {
  try {
    const { id } = req.params;
    const limit = parseInt(req.query.limit) || 10;

    // Dùng CTE để lấy unique products trước, rồi join images sau
    const result = await pool.query(
      `WITH related AS (
         SELECT DISTINCT ON (p.id) p.*
         FROM products p
         INNER JOIN product_categories pc ON pc.product_id = p.id
         WHERE pc.category_id IN (
           SELECT category_id FROM product_categories WHERE product_id = $1
         )
         AND p.id != $1
         AND p.published = TRUE
         ORDER BY p.id, p.created_at DESC
       )
       SELECT r.*,
         (
           SELECT COALESCE(json_agg(pi2.image_url ORDER BY pi2.sort_order), '[]'::json)
           FROM product_images pi2
           WHERE pi2.product_id = r.id
         ) AS images
       FROM related r
       ORDER BY r.created_at DESC
       LIMIT $2`,
      [id, limit]
    );
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load related products' });
  }
});

// ── GET /products/:id/shipping ──────────────────────────────────────────
app.get(['/products/:id/shipping', '/api/products/:id/shipping'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM product_shipping WHERE product_id = $1 LIMIT 1`,
      [req.params.id]
    );
    if (result.rowCount === 0) {
      return res.json({
        estimated_days: '3-5',
        carrier: 'Standard Shipping',
        free_threshold: 50,
        return_days: 30,
        note: 'Standard shipping applies.'
      });
    }
    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load shipping info' });
  }
});

// ── GET /products/:id/support ───────────────────────────────────────────
app.get(['/products/:id/support', '/api/products/:id/support'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM product_support WHERE product_id = $1 LIMIT 1`,
      [req.params.id]
    );
    if (result.rowCount === 0) {
      return res.json({
        contact_email: 'support@fashionstore.com',
        phone: '+1 (800) 123-4560',
        hours: 'Mon–Fri 9am–6pm EST',
        faq: 'Machine washable. Standard care.',
        warranty: '30-day quality guarantee.'
      });
    }
    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load support info' });
  }
});

// ── GET /products/:id/reviews ───────────────────────────────────────────
app.get(['/products/:id/reviews', '/api/products/:id/reviews'], async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, product_id, user_id, reviewer_name, avatar_letter, avatar_color,
              rating, review_text, review_date, has_photo, helpful_count,
              COALESCE(photo_urls, ARRAY[]::TEXT[]) AS photo_urls,
              created_at
       FROM product_reviews WHERE product_id = $1 ORDER BY created_at DESC`,
      [req.params.id]
    );
    return res.json(result.rows);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot load reviews' });
  }
});

// ── POST /upload/review-images ──────────────────────────────────────────────
app.post(['/upload/review-images', '/api/upload/review-images'], upload.array('photos', 5), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }
    const host = `${req.protocol}://${req.get('host')}`;
    const urls = req.files.map(f => `${host}/uploads/${f.filename}`);
    return res.json({ urls });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Upload failed' });
  }
});

// ── POST /products/:id/reviews ──────────────────────────────────────────
// Requires authentication; review is linked to the authenticated user
app.post(['/products/:id/reviews', '/api/products/:id/reviews'], authMiddleware, upload.array('photos', 5), async (req, res) => {
  try {
    let {
      reviewer_name, avatar_letter, avatar_color,
      rating, review_text, has_photo, photo_urls
    } = req.body;

    // If files were uploaded directly with the request, build URLs
    let urls = Array.isArray(photo_urls) ? photo_urls : [];
    if ((!urls || urls.length === 0) && req.files && req.files.length > 0) {
      const host = `${req.protocol}://${req.get('host')}`;
      urls = req.files.map(f => `${host}/uploads/${f.filename}`);
    }
    const actualHasPhoto = (has_photo === true || has_photo === 'true') || (urls && urls.length > 0);

    // Get username for reviewer display
    let reviewer = reviewer_name;
    try {
      const userRes = await pool.query('SELECT username FROM users WHERE id = $1 LIMIT 1', [req.user.sub]);
      if (userRes.rowCount > 0) reviewer = userRes.rows[0].username;
    } catch (_) {}

    const result = await pool.query(
      `INSERT INTO product_reviews 
        (product_id, user_id, reviewer_name, avatar_letter, avatar_color, rating,
         review_text, review_date, has_photo, photo_urls)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING *`,
      [
        req.params.id,
        req.user.sub,
        reviewer || 'Anonymous',
        avatar_letter || 'A',
        avatar_color || '#EF9A9A',
        Math.min(5, Math.max(1, parseInt(rating) || 5)),
        review_text || '',
        new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }),
        actualHasPhoto,
        urls.length > 0 ? urls : null,   // lưu NULL nếu không có ảnh
      ]
    );
    return res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot save review' });
  }
});

// ── PATCH /products/:id/reviews/:reviewId ───────────────────────────────
app.patch([
  '/products/:id/reviews/:reviewId',
  '/api/products/:id/reviews/:reviewId'
], authMiddleware, async (req, res) => {
  try {
    const { rating, review_text, photo_urls } = req.body;
    const reviewId = req.params.reviewId;
    // Verify ownership
    const exist = await pool.query('SELECT user_id FROM product_reviews WHERE id = $1 AND product_id = $2 LIMIT 1', [reviewId, req.params.id]);
    if (exist.rowCount === 0) return res.status(404).json({ message: 'Review not found' });
    const ownerId = exist.rows[0].user_id;
    if (ownerId == null || ownerId.toString() !== req.user.sub.toString()) {
      return res.status(403).json({ message: 'Not allowed' });
    }

    const urls = Array.isArray(photo_urls) ? photo_urls : null;
    const actualHasPhoto = urls != null && urls.length > 0;

    const result = await pool.query(
      `UPDATE product_reviews SET rating = $1, review_text = $2, photo_urls = $3, has_photo = $4, review_date = $5, created_at = NOW()
       WHERE id = $6 RETURNING *`,
      [Math.min(5, Math.max(1, parseInt(rating) || 5)), review_text || '', urls, actualHasPhoto, new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }), reviewId]
    );
    return res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot update review' });
  }
});

// ── DELETE /products/:id/reviews/:reviewId ──────────────────────────────
app.delete([
  '/products/:id/reviews/:reviewId',
  '/api/products/:id/reviews/:reviewId'
], authMiddleware, async (req, res) => {
  try {
    const reviewId = req.params.reviewId;
    const del = await pool.query('DELETE FROM product_reviews WHERE id = $1 AND product_id = $2 AND user_id = $3 RETURNING *', [reviewId, req.params.id, req.user.sub]);
    if (del.rowCount === 0) return res.status(404).json({ message: 'Review not found or not allowed' });
    return res.status(204).send();
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Cannot delete review' });
  }
});
