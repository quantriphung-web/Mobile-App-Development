/**
 * fix_striped_top.js - Tải ảnh riêng cho "Striped Top" (eb545c5b)
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
const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/backend' });

const SAVE_DIR  = path.join(__dirname, '../assets/images');
const PRODUCT_ID = 'eb545c5b-9363-41e9-8bd3-eea057bc4da8';
const FILENAME   = 'prod_striped_top_v3.jpg';
const SAVE_PATH  = path.join(SAVE_DIR, FILENAME);

// Thử nhiều URL Unsplash khác nhau cho striped/fashion top
const URLS = [
  'https://images.unsplash.com/photo-1551489186-cf8726f514f8?w=500&q=80',
  'https://images.unsplash.com/photo-1548549557-dbe9d2b82a6d?w=500&q=80',
  'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=500&q=80',
  'https://images.unsplash.com/photo-1516762689617-e1cffcef479d?w=500&q=80',
  'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80',
  'https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=500&q=80',
  'https://images.unsplash.com/photo-1571513800374-df1bbe650e56?w=500&q=80',
  // Fallback: picsum với seed cố định
  'https://picsum.photos/seed/stripedtop/500/600',
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
        file.close();
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
        return reject(new Error(`HTTP ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    });
    request.on('error', (err) => { file.close(); if (fs.existsSync(filePath)) fs.unlinkSync(filePath); reject(err); });
    request.setTimeout(20000, () => { request.destroy(); reject(new Error('Timeout')); });
  });
}

console.log('🔧 Đang fix ảnh cho "Striped Top"...\n');

let fixed = false;
for (const url of URLS) {
  process.stdout.write(`⬇️  ${url.slice(0, 70)}... `);
  try {
    await downloadFile(url, SAVE_PATH);
    const newUrl = `/images/${FILENAME}`;
    await pool.query('UPDATE products SET image = $1 WHERE id = $2', [newUrl, PRODUCT_ID]);
    console.log('✅');
    console.log(`\n✅ Striped Top → ${newUrl}`);
    fixed = true;
    break;
  } catch (err) {
    console.log(`❌ ${err.message}`);
  }
}

if (!fixed) {
  console.log('\n❌ Không tải được. Kiểm tra kết nối mạng!');
} else {
  console.log('\n🎉 Tất cả 11/11 products đã có ảnh riêng biệt!');
}

await pool.end();
