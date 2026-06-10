/**
 * fix_cross_duplicates.js
 * ─────────────────────────────────────────────────────────────────────────────
 * Tải ảnh MỚI, ĐỘC LẬP cho 11 products đang dùng cùng ảnh với categories.
 * Giữ nguyên ảnh categories, chỉ thay ảnh products.
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

const SAVE_DIR = path.join(__dirname, '../assets/images');
if (!fs.existsSync(SAVE_DIR)) fs.mkdirSync(SAVE_DIR, { recursive: true });

// ── 11 Products cần ảnh mới (không trùng với bất kỳ category nào) ─────────────
// Ảnh được chọn lọc từ Unsplash với photo ID HOÀN TOÀN MỚI
const FIXES = [
  {
    productId: 'f1000000-0000-0000-0000-000000000011',
    productName: 'Classic Blazer',
    filename: 'prod_classic_blazer.jpg',
    // Blazer/suit - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=500&q=80',
      'https://images.unsplash.com/photo-1617127365659-c47fa864d8bc?w=500&q=80',
      'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=500&q=80',
    ],
  },
  {
    productId: '16a030d8-878b-49a0-ab4e-821339272ccf',
    productName: 'Boys Graphic Tee',
    filename: 'prod_boys_graphic_tee.jpg',
    // Kids boy wearing graphic tee - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1571945153237-4929e783af4a?w=500&q=80',
      'https://images.unsplash.com/photo-1503342394128-c104d54dba01?w=500&q=80',
      'https://images.unsplash.com/photo-1502945015378-0e284ca1a5be?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000007',
    productName: 'Striped top',
    filename: 'prod_striped_top_v2.jpg',
    // Striped/patterned top - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1533659828870-95ee305cee3e?w=500&q=80',
      'https://images.unsplash.com/photo-1554568218-0f1715e72254?w=500&q=80',
      'https://images.unsplash.com/photo-1551489186-cf8726f514f8?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000012',
    productName: 'Skinny Jeans',
    filename: 'prod_skinny_jeans.jpg',
    // Skinny jeans - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1604176354204-9268737828e4?w=500&q=80',
      'https://images.unsplash.com/photo-1541823709867-1b206113eafd?w=500&q=80',
      'https://images.unsplash.com/photo-1475178626620-a4d074967452?w=500&q=80',
    ],
  },
  {
    productId: 'f21dfa05-5d01-4692-9015-cc4655d1f0f2',
    productName: 'Casual Jumpsuit',
    filename: 'prod_casual_jumpsuit.jpg',
    // Casual jumpsuit - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=500&q=80',
      'https://images.unsplash.com/photo-1567958451986-2de427a4a0be?w=500&q=80',
      'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=500&q=80',
    ],
  },
  {
    productId: 'b8fc0ad3-459e-4752-8b28-c1eaa8f62af8',
    productName: 'Girls Floral Dress',
    filename: 'prod_girls_floral_dress.jpg',
    // Girls floral dress - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=500&q=80',
      'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=500&q=80',
      'https://images.unsplash.com/photo-1551489186-cf8726f514f8?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000001',
    productName: 'Pullover',
    filename: 'prod_pullover.jpg',
    // Pullover/sweater - photo ID mới (khác prod_knit_sweater.jpg)
    urls: [
      'https://images.unsplash.com/photo-1617952739538-dad3f8c49d42?w=500&q=80',
      'https://images.unsplash.com/photo-1636455571124-e0e5e82b19e2?w=500&q=80',
      'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000013',
    productName: 'Trench Coat',
    filename: 'prod_trench_coat.jpg',
    // Trench coat - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1544022613-e87ca75a784a?w=500&q=80',
      'https://images.unsplash.com/photo-1520013817300-1f4c1cb245ef?w=500&q=80',
      'https://images.unsplash.com/photo-1548126032-079a0fb0099d?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000002',
    productName: 'Blouse',
    filename: 'prod_blouse.jpg',
    // Blouse/shirt - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=500&q=80',
      'https://images.unsplash.com/photo-1583744946564-b52ac1c389c8?w=500&q=80',
      'https://images.unsplash.com/photo-1594938298603-c8148f4851f4?w=500&q=80',
    ],
  },
  {
    productId: 'f1000000-0000-0000-0000-000000000005',
    productName: 'T-Shirt SPANISH',
    filename: 'prod_tshirt_spanish.jpg',
    // T-shirt (unique) - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500&q=80',
      'https://images.unsplash.com/photo-1503341733017-1901578f9f1e?w=500&q=80',
      'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=500&q=80',
    ],
  },
  {
    productId: 'eb545c5b-9363-41e9-8bd3-eea057bc4da8',
    productName: 'Striped Top',
    filename: 'prod_striped_top_v3.jpg',
    // Striped top (unique) - photo ID mới
    urls: [
      'https://images.unsplash.com/photo-1594938236736-ca3e97bb5e33?w=500&q=80',
      'https://images.unsplash.com/photo-1583497491815-2ef27b9c44e5?w=500&q=80',
      'https://images.unsplash.com/photo-1585344914895-6b82e1f2fd6f?w=500&q=80',
    ],
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
    request.setTimeout(20000, () => {
      request.destroy();
      reject(new Error('Timeout'));
    });
  });
}

async function tryDownload(urls, filePath) {
  for (const url of urls) {
    process.stdout.write(`      ⬇️  ${url.slice(0, 65)}... `);
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
console.log('║     FIX CROSS-DUPLICATES: Categories ↔ Products         ║');
console.log('╚══════════════════════════════════════════════════════════╝\n');

try {
  await pool.query('SELECT 1');
  console.log('✅ Kết nối database thành công!\n');
} catch (err) {
  console.error('❌ Không kết nối được DB:', err.message);
  process.exit(1);
}

let successCount = 0;
let failCount = 0;

for (let i = 0; i < FIXES.length; i++) {
  const fix = FIXES[i];
  console.log(`[${i+1}/${FIXES.length}] 📦 ${fix.productName}`);

  const savePath = path.join(SAVE_DIR, fix.filename);
  const newUrl   = `/images/${fix.filename}`;

  // Kiểm tra file đã tồn tại chưa (tránh tải lại)
  if (fs.existsSync(savePath)) {
    console.log(`      ⏩ File đã tồn tại: ${fix.filename}`);
    // Vẫn cập nhật DB phòng trường hợp DB chưa được cập nhật
    await pool.query('UPDATE products SET image = $1 WHERE id = $2', [newUrl, fix.productId]);
    console.log(`      💾 DB → ${newUrl}\n`);
    successCount++;
    continue;
  }

  const ok = await tryDownload(fix.urls, savePath);
  if (ok) {
    await pool.query('UPDATE products SET image = $1 WHERE id = $2', [newUrl, fix.productId]);
    console.log(`      💾 DB cập nhật: ${fix.productName} → ${newUrl}\n`);
    successCount++;
  } else {
    console.log(`      ⚠️  KHÔNG tải được ảnh cho ${fix.productName}\n`);
    failCount++;
  }
}

// ── Kiểm tra lại ─────────────────────────────────────────────────────────────
console.log('══ KẾT QUẢ KIỂM TRA ════════════════════════════════════════\n');

// Trích photo ID
function extractPhotoId(imageUrl) {
  if (!imageUrl) return null;
  const match = imageUrl.match(/photo-([\w-]+)\.jpg/);
  return match ? match[1] : null;
}

const cats = await pool.query('SELECT category_name, image FROM categories');
const prods = await pool.query('SELECT product_name, image FROM products');

let remaining = 0;
for (const cat of cats.rows) {
  const catId = extractPhotoId(cat.image);
  if (!catId) continue;
  for (const prod of prods.rows) {
    const prodId = extractPhotoId(prod.image);
    if (prodId && catId === prodId) {
      console.log(`   ⚠️  Còn trùng: Category "${cat.category_name}" ↔ Product "${prod.product_name}"`);
      remaining++;
    }
  }
}

if (remaining === 0) {
  console.log('   ✅ Tất cả ảnh đã HOÀN TOÀN ĐỘC LẬP giữa categories và products!');
}

console.log(`\n📊 Tổng kết:`);
console.log(`   ✅ Thành công: ${successCount}/${FIXES.length}`);
if (failCount > 0) console.log(`   ❌ Thất bại : ${failCount}/${FIXES.length}`);
console.log('\n🎉 Hoàn thành! App Flutter sẽ hiển thị ảnh đúng sau khi hot-reload.\n');

await pool.end();
