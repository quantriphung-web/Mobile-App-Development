import dotenv from 'dotenv';
import pg from 'pg';
dotenv.config();
const pool = new pg.Pool({ connectionString: process.env.DATABASE_URL });
const {rows: p} = await pool.query("SELECT COUNT(*) FROM products WHERE image NOT LIKE 'http://192.168.100.66%' AND image IS NOT NULL");
const {rows: c} = await pool.query("SELECT COUNT(*) FROM categories WHERE image NOT LIKE 'http://192.168.100.66%' AND image IS NOT NULL");
console.log('✅ Kiểm tra xong!');
console.log('Products còn URL ngoài mạng:', p[0].count);
console.log('Categories còn URL ngoài mạng:', c[0].count);
if (p[0].count === '0' && c[0].count === '0') {
  console.log('\n🎉 Tất cả ảnh đã là local! Không còn URL ngoài mạng nào.');
}
await pool.end();
