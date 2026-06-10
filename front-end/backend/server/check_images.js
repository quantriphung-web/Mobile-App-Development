import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config();
const { Pool } = pg;
const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/backend' });

// Sản phẩm dùng cùng ảnh (lặp)
console.log('=== SẢN PHẨM BỊ LẶP ẢNH ===');
const dup = await pool.query(`
  SELECT image, array_agg(product_name ORDER BY product_name) as products, count(*) as cnt
  FROM products 
  GROUP BY image 
  HAVING count(*) > 1
  ORDER BY cnt DESC
`);
dup.rows.forEach(r => console.log(r.cnt + ' sp: ' + r.products.join(', ') + ' -> ' + r.image));

// Categories bị mất ảnh (file không tồn tại)
console.log('\n=== ALL CATEGORIES ===');
const cats = await pool.query('SELECT id, category_name, image FROM categories ORDER BY category_name');
cats.rows.forEach(r => console.log(r.category_name + ' -> ' + r.image));

await pool.end();
