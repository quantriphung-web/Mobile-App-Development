/**
 * fix_to_relative_urls.js
 * Chuyển tất cả URL ảnh trong DB từ dạng:
 *   http://192.168.100.66:3000/images/xxx.jpg
 * sang dạng tương đối:
 *   /images/xxx.jpg
 */
import dotenv from 'dotenv';
import pg from 'pg';

dotenv.config();
const { Pool } = pg;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function fixTable(tableName, idCol, imageCol) {
  const { rows } = await pool.query(
    `SELECT ${idCol}, ${imageCol} FROM ${tableName} WHERE ${imageCol} LIKE 'http://%/images/%'`
  );

  console.log(`\n📦 Bảng "${tableName}": ${rows.length} records cần sửa`);
  let count = 0;

  for (const row of rows) {
    const url = row[imageCol];
    // Lấy phần /images/xxx.jpg từ URL
    const match = url.match(/(\/images\/.+)$/);
    if (!match) continue;

    const relativePath = match[1];
    await pool.query(
      `UPDATE ${tableName} SET ${imageCol} = $1 WHERE ${idCol} = $2`,
      [relativePath, row[idCol]]
    );
    count++;
  }

  console.log(`   ✅ Đã cập nhật ${count} records → dạng /images/xxx.jpg`);
}

console.log('╔══════════════════════════════════════════════════════════╗');
console.log('║        CHUYỂN URL SANG DẠNG TƯƠNG ĐỐI (/images/...)    ║');
console.log('╚══════════════════════════════════════════════════════════╝');

await pool.query('SELECT 1');
console.log('✅ Kết nối database thành công!');

await fixTable('products', 'id', 'image');
await fixTable('categories', 'id', 'image');

// Kiểm tra kết quả
const { rows: sample } = await pool.query('SELECT image FROM products LIMIT 3');
console.log('\n📋 Mẫu sau khi sửa:');
sample.forEach(r => console.log(`   ${r.image}`));

console.log('\n🎉 Hoàn thành! URL trong DB giờ là dạng tương đối.');
console.log('💡 Flutter app cần thêm BASE_URL vào trước khi hiển thị ảnh.');

await pool.end();
