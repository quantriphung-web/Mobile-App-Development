/**
 * check_cross_duplicates.js
 * Tìm tất cả ảnh bị trùng giữa categories và products
 */
import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config();
const { Pool } = pg;
const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/backend' });

// Trích photo ID từ tên file (vd: cat_photo-1234567890-abcdef.jpg -> 1234567890-abcdef)
function extractPhotoId(imageUrl) {
  if (!imageUrl) return null;
  const match = imageUrl.match(/photo-([\w-]+)\.jpg/);
  return match ? match[1] : null;
}

const cats = await pool.query('SELECT id, category_name, image FROM categories ORDER BY category_name');
const prods = await pool.query('SELECT id, product_name, image FROM products ORDER BY product_name');

console.log('=== TRÙNG LẶP ẢNH GIỮA CATEGORY VÀ PRODUCT ===\n');

let duplicates = [];
for (const cat of cats.rows) {
  const catId = extractPhotoId(cat.image);
  if (!catId) continue;

  for (const prod of prods.rows) {
    const prodId = extractPhotoId(prod.image);
    if (!prodId) continue;
    if (catId === prodId) {
      duplicates.push({
        photoId: catId,
        category: cat.category_name,
        catImage: cat.image,
        product: prod.product_name,
        prodId: prod.id,
        prodImage: prod.image,
      });
    }
  }
}

if (duplicates.length === 0) {
  console.log('✅ Không có trùng lặp nào!');
} else {
  console.log(`❌ Tìm thấy ${duplicates.length} cặp trùng:\n`);
  duplicates.forEach((d, i) => {
    console.log(`${i+1}. Category "${d.category}" ↔ Product "${d.product}"`);
    console.log(`   Photo ID: ${d.photoId}`);
    console.log(`   Product ID: ${d.prodId}`);
    console.log(`   Product image: ${d.prodImage}`);
    console.log();
  });
}

await pool.end();
