/**
 * migrate_images.js
 * ─────────────────────────────────────────────────────────────────────────────
 * Script tải tất cả ảnh đang lưu URL ngoài mạng trong database về máy local.
 * Ảnh được lưu vào: ../assets/images/
 * DB được cập nhật:  image = http://<SERVER_HOST>/images/<filename>
 *
 * Chạy: node migrate_images.js
 * ─────────────────────────────────────────────────────────────────────────────
 */

import dotenv from 'dotenv';
import fs from 'fs';
import http from 'http';
import https from 'https';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const { Pool } = pg;
const pool = new Pool({
  connectionString:
    process.env.DATABASE_URL ||
    'postgres://postgres:postgres@localhost:5432/backend',
});

// ── Cấu hình ──────────────────────────────────────────────────────────────────
// Thư mục lưu ảnh (tương đối so với file script này)
const SAVE_DIR = path.join(__dirname, '../assets/images');

// Host của server (dùng để tạo URL mới trong DB)
// Có thể đặt SERVER_HOST=192.168.100.66:3000 trong .env
const SERVER_HOST = process.env.SERVER_HOST || '192.168.100.66:3000';
// ─────────────────────────────────────────────────────────────────────────────

// Đảm bảo thư mục tồn tại
if (!fs.existsSync(SAVE_DIR)) {
  fs.mkdirSync(SAVE_DIR, { recursive: true });
}

/** Tải file từ URL về, lưu vào filePath */
function downloadFile(url, filePath) {
  return new Promise((resolve, reject) => {
    const protocol = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(filePath);

    const request = protocol.get(url, (response) => {
      // Theo redirect
      if (response.statusCode === 301 || response.statusCode === 302) {
        file.close();
        fs.unlinkSync(filePath);
        return downloadFile(response.headers.location, filePath)
          .then(resolve)
          .catch(reject);
      }

      if (response.statusCode !== 200) {
        file.close();
        fs.unlinkSync(filePath);
        return reject(new Error(`HTTP ${response.statusCode} khi tải: ${url}`));
      }

      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    });

    request.on('error', (err) => {
      file.close();
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      reject(err);
    });

    request.setTimeout(15000, () => {
      request.destroy();
      file.close();
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
      reject(new Error(`Timeout khi tải: ${url}`));
    });
  });
}

/** Lấy extension từ URL hoặc mặc định .jpg */
function getExtension(url) {
  try {
    const pathname = new URL(url).pathname;
    const ext = path.extname(pathname).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp', '.jfif'].includes(ext)) {
      return ext === '.jfif' ? '.jpg' : ext;
    }
  } catch {}
  return '.jpg';
}

/** Tạo tên file unique từ URL */
function makeFilename(url, prefix = '') {
  try {
    const pathname = new URL(url).pathname;
    // Lấy tên file gốc, bỏ ký tự đặc biệt
    let name = path.basename(pathname, path.extname(pathname))
      .replace(/[^a-zA-Z0-9_-]/g, '_')
      .slice(0, 50);
    if (!name) name = 'img';
    const ext = getExtension(url);
    const base = prefix ? `${prefix}_${name}` : name;
    let filename = `${base}${ext}`;
    let counter = 1;
    // Tránh trùng tên
    while (fs.existsSync(path.join(SAVE_DIR, filename))) {
      filename = `${base}_${counter}${ext}`;
      counter++;
    }
    return filename;
  } catch {
    return `img_${Date.now()}.jpg`;
  }
}

/** Kiểm tra URL có phải là URL ngoài mạng không (không phải local) */
function isExternalUrl(url) {
  if (!url || typeof url !== 'string') return false;
  if (!url.startsWith('http://') && !url.startsWith('https://')) return false;
  // Bỏ qua URL đã trỏ về local server
  if (url.includes('localhost') || url.includes('127.0.0.1') || url.includes(SERVER_HOST)) return false;
  return true;
}

async function migrateTable(tableName, idCol, imageCol) {
  console.log(`\n📦 Đang xử lý bảng: ${tableName}`);

  // Lấy tất cả records có ảnh
  const { rows } = await pool.query(
    `SELECT ${idCol}, ${imageCol} FROM ${tableName} WHERE ${imageCol} IS NOT NULL AND ${imageCol} != ''`
  );

  console.log(`   Tìm thấy ${rows.length} records có ảnh`);

  let success = 0;
  let skipped = 0;
  let failed  = 0;

  for (const row of rows) {
    const url = row[imageCol];

    if (!isExternalUrl(url)) {
      console.log(`   ⏩ Bỏ qua (đã là local): ${url}`);
      skipped++;
      continue;
    }

    const filename    = makeFilename(url, tableName === 'products' ? 'prod' : 'cat');
    const savePath    = path.join(SAVE_DIR, filename);
    const newUrl      = `/images/${filename}`;

    process.stdout.write(`   ⬇️  Tải: ${url.slice(0, 70)}... `);

    try {
      await downloadFile(url, savePath);
      // Cập nhật DB
      await pool.query(
        `UPDATE ${tableName} SET ${imageCol} = $1 WHERE ${idCol} = $2`,
        [newUrl, row[idCol]]
      );
      console.log(`✅ → ${filename}`);
      success++;
    } catch (err) {
      console.log(`❌ Lỗi: ${err.message}`);
      failed++;
    }
  }

  console.log(`   ✅ Thành công: ${success} | ⏩ Bỏ qua: ${skipped} | ❌ Lỗi: ${failed}`);
}

async function main() {
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║          MIGRATE IMAGES FROM INTERNET → LOCAL           ║');
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log(`\n📁 Thư mục lưu ảnh : ${SAVE_DIR}`);
  console.log(`🌐 Server host      : ${SERVER_HOST}`);
  console.log(`\n⚠️  Đảm bảo server đang KHÔNG chạy khi migrate (tránh lock DB)\n`);

  try {
    // Test kết nối DB
    await pool.query('SELECT 1');
    console.log('✅ Kết nối database thành công!\n');

    // Migrate bảng products
    await migrateTable('products', 'id', 'image');

    // Migrate bảng categories
    await migrateTable('categories', 'id', 'image');

    console.log('\n🎉 Hoàn thành! Tất cả ảnh đã được tải về và DB đã cập nhật.');
    console.log(`📁 Ảnh nằm trong: ${SAVE_DIR}`);
    console.log(`\n💡 Tiếp theo: Khởi động lại server để serve ảnh tại /images/`);
  } catch (err) {
    console.error('\n💥 Lỗi:', err.message);
    if (err.message.includes('password') || err.message.includes('ECONNREFUSED')) {
      console.error('\n💡 Gợi ý: Kiểm tra lại DATABASE_URL trong file .env');
    }
  } finally {
    await pool.end();
  }
}

main();
