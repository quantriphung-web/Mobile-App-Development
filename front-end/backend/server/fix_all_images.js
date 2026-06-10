/**
 * fix_all_images.js
 * ─────────────────────────────────────────────────────────────────────────────
 * 1. Tải ảnh mới cho 4 categories bị mất hình: Girls, Pants, Shorts, Skirts
 * 2. Tải ảnh riêng biệt cho các products đang bị lặp hình:
 *    - Knit Sweater (đang dùng cùng ảnh với Pullover)
 *    - T-shirt      (đang dùng cùng ảnh với Striped Top)
 * ─────────────────────────────────────────────────────────────────────────────
 */

import dotenv from 'dotenv';
import fs from 'fs';
import https from 'https';
import http from 'http';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const { Pool } = pg;
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/backend',
});

const SAVE_DIR    = path.join(__dirname, '../assets/images');
const SERVER_HOST = process.env.SERVER_HOST || '192.168.100.66:3000';

if (!fs.existsSync(SAVE_DIR)) fs.mkdirSync(SAVE_DIR, { recursive: true });

// ── Danh sách cần fix ─────────────────────────────────────────────────────────

const CATEGORY_FIXES = [
  {
    name: 'Girls',
    filename: 'cat_girls.jpg',
    // Bé gái mặc đầm/thời trang trẻ em gái
    urls: [
      'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=500&q=80',
      'https://images.unsplash.com/photo-1476234251651-f353703a034d?w=500&q=80',
      'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=500&q=80',
    ],
  },
  {
    name: 'Pants',
    filename: 'cat_pants.jpg',
    // Quần dài thời trang
    urls: [
      'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500&q=80',
      'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&q=80',
      'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=500&q=80',
    ],
  },
  {
    name: 'Shorts',
    filename: 'cat_shorts.jpg',
    // Quần short thời trang
    urls: [
      'https://images.unsplash.com/photo-1591195853828-11db59a44f43?w=500&q=80',
      'https://images.unsplash.com/photo-1579782483458-83d02161294e?w=500&q=80',
      'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=500&q=80',
    ],
  },
  {
    name: 'Skirts',
    filename: 'cat_skirts.jpg',
    // Váy/chân váy thời trang
    urls: [
      'https://images.unsplash.com/photo-1583496661160-fb5974ca5d84?w=500&q=80',
      'https://images.unsplash.com/photo-1570976447640-ac859083963f?w=500&q=80',
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&q=80',
    ],
  },
];

// Products đang bị lặp ảnh (cần ảnh mới độc lập)
const PRODUCT_FIXES = [
  {
    name: 'Knit Sweater',
    // Hiện đang dùng cùng ảnh Unsplash với Pullover (photo-1434389677669)
    filename: 'prod_knit_sweater.jpg',
    urls: [
      'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?w=500&q=80',
      'https://images.unsplash.com/photo-1611312449408-fcece27cdbb7?w=500&q=80',
      'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=500&q=80',
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&q=80',
    ],
    // Tìm product theo tên (để lấy id)
    findQuery: "SELECT id FROM products WHERE product_name ILIKE '%Knit Sweater%' LIMIT 1",
  },
  {
    name: 'T-shirt',
    // Hiện đang dùng cùng ảnh Unsplash với Striped Top (photo-1562157873)
    filename: 'prod_tshirt_unique.jpg',
    urls: [
      'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?w=500&q=80',
      'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500&q=80',
      'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=500&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&q=80',
    ],
    // T-shirt có nhiều cái, ta lấy cái đang dùng file _1 (lặp)
    findQuery: "SELECT id FROM products WHERE product_name ILIKE '%T-shirt%' AND image LIKE '%_1.jpg%' LIMIT 1",
  },
];

// ── Hàm tải file ──────────────────────────────────────────────────────────────

function downloadFile(url, filePath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(filePath);

    const request = protocol.get(url, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        file.close();
        fs.unlinkSync(filePath);
        return downloadFile(response.headers.location, filePath).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        file.close();
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
        return reject(new Error(`HTTP ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    });

    request.on('error', (err) => {
      file.close();
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      reject(err);
    });
    request.setTimeout(15000, () => {
      request.destroy();
      reject(new Error('Timeout'));
    });
  });
}

// Thử lần lượt các URL, dừng khi thành công
async function tryDownload(urls, filePath) {
  for (const url of urls) {
    process.stdout.write(`   ⬇️  ${url.slice(0, 60)}... `);
    try {
      await downloadFile(url, filePath);
      console.log('✅');
      return true;
    } catch (err) {
      console.log(`❌ ${err.message}`);
    }
  }
  return false;
}

// ── Main ──────────────────────────────────────────────────────────────────────

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║          FIX ALL IMAGES (Categories + Products)          ║');
console.log('╚══════════════════════════════════════════════════════════╝\n');

try {
  await pool.query('SELECT 1');
  console.log('✅ Kết nối database thành công!\n');
} catch (err) {
  console.error('❌ Không kết nối được DB:', err.message);
  process.exit(1);
}

// ── 1. Fix categories bị mất ảnh ─────────────────────────────────────────────
console.log('══ STEP 1: Fix categories bị mất ảnh ══════════════════════\n');

for (const cat of CATEGORY_FIXES) {
  console.log(`📂 Category: ${cat.name}`);
  const savePath = path.join(SAVE_DIR, cat.filename);
  const newUrl   = `/images/${cat.filename}`;

  const ok = await tryDownload(cat.urls, savePath);
  if (ok) {
    // Cập nhật tất cả categories có tên match
    const res = await pool.query(
      `UPDATE categories SET image = $1 WHERE category_name ILIKE $2 AND (image LIKE '%cat_300%' OR image IS NULL OR image = '')`,
      [newUrl, cat.name]
    );
    console.log(`   💾 Cập nhật DB: ${res.rowCount} categories → ${newUrl}\n`);
  } else {
    console.log(`   ⚠️  Bỏ qua ${cat.name} do không tải được ảnh\n`);
  }
}

// ── 2. Fix products bị lặp ảnh ────────────────────────────────────────────────
console.log('══ STEP 2: Fix products bị lặp ảnh ════════════════════════\n');

for (const prod of PRODUCT_FIXES) {
  console.log(`📦 Product: ${prod.name}`);

  // Tìm product id
  const idRes = await pool.query(prod.findQuery);
  if (idRes.rowCount === 0) {
    console.log(`   ⚠️  Không tìm thấy product "${prod.name}" cần fix\n`);
    continue;
  }
  const productId = idRes.rows[0].id;
  console.log(`   🔑 ID: ${productId}`);

  const savePath = path.join(SAVE_DIR, prod.filename);
  const newUrl   = `/images/${prod.filename}`;

  const ok = await tryDownload(prod.urls, savePath);
  if (ok) {
    await pool.query('UPDATE products SET image = $1 WHERE id = $2', [newUrl, productId]);
    console.log(`   💾 Cập nhật DB: ${prod.name} → ${newUrl}\n`);
  } else {
    console.log(`   ⚠️  Bỏ qua ${prod.name} do không tải được ảnh\n`);
  }
}

// ── 3. Kiểm tra kết quả ───────────────────────────────────────────────────────
console.log('══ STEP 3: Kiểm tra kết quả ════════════════════════════════\n');

console.log('📋 Categories sau khi fix:');
const cats = await pool.query('SELECT category_name, image FROM categories ORDER BY category_name');
for (const r of cats.rows) {
  const filename = r.image?.split('/').pop() || 'NULL';
  const exists   = r.image ? fs.existsSync(path.join(SAVE_DIR, filename)) : false;
  const status   = r.image ? (exists ? '✅' : '❌ FILE MISSING') : '❌ NO IMAGE';
  console.log(`   ${status} ${r.category_name}: ${r.image ?? 'null'}`);
}

console.log('\n📋 Products bị lặp ảnh (còn không?):');
const dup = await pool.query(`
  SELECT image, array_agg(product_name ORDER BY product_name) as products, count(*) as cnt
  FROM products 
  GROUP BY image 
  HAVING count(*) > 1
  ORDER BY cnt DESC
`);
if (dup.rowCount === 0) {
  console.log('   ✅ Không còn sản phẩm nào bị lặp ảnh!');
} else {
  dup.rows.forEach(r => console.log(`   ⚠️  ${r.cnt} sp cùng ảnh: ${r.products.join(', ')} → ${r.image}`));
}

console.log('\n🎉 Hoàn thành! Restart server để áp dụng thay đổi.\n');
await pool.end();
