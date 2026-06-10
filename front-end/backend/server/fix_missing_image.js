/**
 * fix_missing_image.js
 * Tải ảnh thay thế cho sản phẩm Mini Skirt bị 404
 */
import dotenv from 'dotenv';
import fs from 'fs';
import https from 'https';
import path from 'path';
import { fileURLToPath } from 'url';
import pg from 'pg';

dotenv.config();
const __filename = fileURLToPath(import.meta.url);
const __dirname  = path.dirname(__filename);

const { Pool } = pg;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

const SAVE_DIR    = path.join(__dirname, '../assets/images');
const SERVER_HOST = process.env.SERVER_HOST || '192.168.100.66:3000';
const PRODUCT_ID  = 'b10419cf-505d-44fa-b47b-676a8227d85d';

// Danh sách URL thay thế cho Mini Skirt (thử lần lượt)
const REPLACEMENT_URLS = [
  'https://images.unsplash.com/photo-1588117305388-c2631a279f82?w=600',
  'https://images.unsplash.com/photo-1594938298603-c8148f4851f4?w=600',
  'https://images.unsplash.com/photo-1631233859262-0d4e77d9ce84?w=600',
  'https://picsum.photos/seed/miniskirt/600/800',
];

function downloadFile(url, filePath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(filePath);
    const request = https.get(url, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        file.close(); fs.unlinkSync(filePath);
        return downloadFile(response.headers.location, filePath).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        file.close(); fs.unlinkSync(filePath);
        return reject(new Error(`HTTP ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    });
    request.on('error', (err) => { file.close(); if (fs.existsSync(filePath)) fs.unlinkSync(filePath); reject(err); });
    request.setTimeout(15000, () => { request.destroy(); reject(new Error('Timeout')); });
  });
}

console.log('🔧 Sửa ảnh cho sản phẩm Mini Skirt...\n');

let fixed = false;
for (const url of REPLACEMENT_URLS) {
  const filename = `prod_mini_skirt.jpg`;
  const savePath = path.join(SAVE_DIR, filename);
  const newUrl   = `http://${SERVER_HOST}/images/${filename}`;

  process.stdout.write(`⬇️  Thử: ${url.slice(0, 70)}... `);
  try {
    await downloadFile(url, savePath);
    await pool.query('UPDATE products SET image = $1 WHERE id = $2', [newUrl, PRODUCT_ID]);
    console.log(`✅ OK!`);
    console.log(`\n✅ Đã cập nhật Mini Skirt:`);
    console.log(`   File: ${savePath}`);
    console.log(`   URL:  ${newUrl}`);
    fixed = true;
    break;
  } catch (err) {
    console.log(`❌ ${err.message}`);
  }
}

if (!fixed) console.log('\n❌ Không tải được ảnh nào. Kiểm tra kết nối mạng!');

await pool.end();
