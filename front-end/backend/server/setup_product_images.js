/**
 * setup_product_images.js
 * 1. Tạo bảng product_images trong DB
 * 2. Thêm ảnh thứ 2 cho mỗi sản phẩm (dùng ảnh có sẵn trong assets/images)
 * 3. Đảm bảo ảnh chính cũng nằm trong bảng (sort_order = 1)
 */
import pg from 'pg';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import https from 'https';
import http from 'http';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const { Pool } = pg;
const pool = new Pool({
  connectionString: 'postgres://postgres:postgres@localhost:5432/backend',
});

const assetsDir = path.join(__dirname, '../assets/images');

// Mapping sản phẩm → ảnh thứ 2 (dùng những ảnh đã có trong assets)
// Chọn ảnh khác nhau cho từng sản phẩm
const productSecondImages = {
  'Blouse':         '/images/prod_photo-1503944168849-8bf86875bbd8.jpg',
  'Bomber Jacket':  '/images/prod_photo-1539533113208-f6df8cc8b543.jpg',
  'Boys Cargo Shorts': '/images/prod_photo-1515886657613-9f3515b0c78f.jpg',
  'Boys Graphic Tee':  '/images/prod_photo-1521572163474-6864f9cf17ab.jpg',
  'Cable Knit Top':    '/images/prod_knit_sweater.jpg',
  'Casual Jumpsuit':   '/images/prod_photo-1548624313-0396c75e4b1a.jpg',
  'Classic Blazer':    '/images/prod_photo-1541099649105-f69ad21f3246.jpg',
  'Crop Top':          '/images/prod_photo-1576566588028-4147f3842f27.jpg',
  'Chino Pants':       '/images/prod_photo-1496747611176-843222e1e57c.jpg',
  'Denim Jumpsuit':    '/images/prod_casual_jumpsuit.jpg',
  'Denim Shorts':      '/images/prod_photo-1564257631407-4deb1f99d992.jpg',
  'Evening Dress':     '/images/prod_photo-1496747611176-843222e1e57c.jpg',
  'Famous dress':      '/images/prod_photo-1566174053879-31528523f8ae.jpg',
  'Floral Shorts':     '/images/prod_photo-1506629082955-511b1aa562c8.jpg',
  'Girls Floral Dress':'/images/prod_photo-1476234251651-f353703a034d.jpg',
  'Girls Ruffle Top':  '/images/prod_girls_floral_dress.jpg',
  'Knit Sweater':      '/images/prod_pullover.jpg',
  'Leather Jacket':    '/images/prod_photo-1520975954732-35dd22299614.jpg',
  'Light blouse':      '/images/prod_blouse.jpg',
  'Maxi Skirt':        '/images/prod_mini_skirt.jpg',
  'Midi Dress':        '/images/prod_photo-1623609163859-ca93c959b98a.jpg',
  'Mini Skirt':        '/images/prod_photo-1570976447640-ac859083963f.jpg',
  'Polo Shirt':        '/images/prod_photo-1607345366928-199ea26cfe3e.jpg',
  'Pullover':          '/images/prod_knit_sweater.jpg',
  'Shirt':             '/images/prod_photo-1586363104862-3a5e2ab60d99.jpg',
  'Skinny Jeans':      '/images/prod_photo-1473966968600-fa801b869a1a.jpg',
  'Sport Dress':       '/images/prod_photo-1502716119720-b23a93e5fe1b.jpg',
  'Striped top':       '/images/prod_striped_top_v3.jpg',
  'Striped Top':       '/images/prod_striped_top_v2.jpg',
  'Striped Top 2':     '/images/prod_photo-1503342217505-b0a15ec3261c.jpg',
  'Summer Dress':      '/images/prod_photo-1502716119720-b23a93e5fe1b.jpg',
  'T-shirt':           '/images/prod_tshirt_spanish.jpg',
  'T-Shirt SPANISH':   '/images/prod_tshirt_unique.jpg',
  'Trench Coat':       '/images/prod_classic_blazer.jpg',
  'White Shirt':       '/images/prod_photo-1521572163474-6864f9cf17ab.jpg',
};

async function main() {
  console.log('🔧 Tạo bảng product_images...');

  // 1. Tạo bảng product_images
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_images (
      id         SERIAL PRIMARY KEY,
      product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      image_url  TEXT NOT NULL,
      sort_order INTEGER DEFAULT 1,
      alt_text   TEXT,
      created_at TIMESTAMP DEFAULT NOW()
    );
  `);

  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_product_images_product_id 
    ON product_images(product_id);
  `);

  console.log('✅ Bảng product_images đã sẵn sàng');

  // 2. Xóa dữ liệu cũ nếu có
  await pool.query('DELETE FROM product_images');
  console.log('🗑️  Đã xóa dữ liệu cũ');

  // 3. Lấy tất cả sản phẩm
  const productsResult = await pool.query(
    'SELECT id, product_name, image FROM products WHERE published = true ORDER BY product_name'
  );
  const products = productsResult.rows;
  console.log(`📦 Tìm thấy ${products.length} sản phẩm`);

  // 4. Insert ảnh cho từng sản phẩm
  let inserted = 0;
  for (const product of products) {
    const mainImage = product.image;
    const secondImage = productSecondImages[product.product_name] || mainImage;

    if (mainImage) {
      // Ảnh chính (sort_order = 1)
      await pool.query(
        `INSERT INTO product_images (product_id, image_url, sort_order, alt_text)
         VALUES ($1, $2, 1, $3)`,
        [product.id, mainImage, `${product.product_name} - main`]
      );

      // Ảnh phụ (sort_order = 2) - khác với ảnh chính
      const img2 = secondImage !== mainImage ? secondImage : '/images/prod_photo-1562157873-818bc0726f68.jpg';
      await pool.query(
        `INSERT INTO product_images (product_id, image_url, sort_order, alt_text)
         VALUES ($1, $2, 2, $3)`,
        [product.id, img2, `${product.product_name} - view 2`]
      );

      inserted++;
      console.log(`  ✓ ${product.product_name}: ${mainImage} + ${img2}`);
    }
  }

  console.log(`\n✅ Hoàn thành! Đã thêm ảnh cho ${inserted} sản phẩm`);
  await pool.end();
}

main().catch(e => {
  console.error('❌ Lỗi:', e.message);
  pool.end();
  process.exit(1);
});
