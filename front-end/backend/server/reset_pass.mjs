import bcrypt from 'bcryptjs';
import pg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://postgres:123@localhost:5432/backend',
});

const email = 'quantriphung@gmail.com'; // email muốn reset
const newPassword = '123456';

const hash = await bcrypt.hash(newPassword, 10);
const result = await pool.query(
  'UPDATE users SET password = $1 WHERE email = $2 RETURNING id, email, username',
  [hash, email]
);

if (result.rowCount === 0) {
  console.log('❌ Không tìm thấy user với email:', email);
} else {
  console.log('✅ Reset mật khẩu thành công!');
  console.log('   Email   :', result.rows[0].email);
  console.log('   Username:', result.rows[0].username);
  console.log('   Password mới: 123456');
}

// Test login ngay
const userResult = await pool.query('SELECT password FROM users WHERE email = $1', [email]);
const match = await bcrypt.compare(newPassword, userResult.rows[0].password);
console.log('✅ Xác nhận bcrypt.compare:', match ? 'ĐÚNG' : 'SAI');

await pool.end();
