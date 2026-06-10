/**
 * setup_product_details.js
 * Tạo bảng shipping_info, support_info, product_reviews
 * Mỗi sản phẩm có dữ liệu khác nhau
 */
import pg from 'pg';
import { fileURLToPath } from 'url';

const { Pool } = pg;
const pool = new Pool({
  connectionString: 'postgres://postgres:postgres@localhost:5432/backend',
});

// ─── Dữ liệu Shipping Info theo tên sản phẩm ───────────────────────────────
const shippingData = {
  'Blouse': {
    estimated_days: '3-5',
    carrier: 'FedEx Standard',
    free_threshold: 50,
    return_days: 30,
    note: 'Free returns on all blouses. Shipped in eco-friendly packaging.'
  },
  'Bomber Jacket': {
    estimated_days: '5-7',
    carrier: 'UPS Ground',
    free_threshold: 80,
    return_days: 14,
    note: 'Bulky item. Extra packaging applied for jacket protection.'
  },
  'Boys Cargo Shorts': {
    estimated_days: '2-4',
    carrier: 'USPS First Class',
    free_threshold: 35,
    return_days: 30,
    note: 'Fast delivery for kids items. Gift wrapping available.'
  },
  'Boys Graphic Tee': {
    estimated_days: '2-3',
    carrier: 'USPS Priority',
    free_threshold: 30,
    return_days: 30,
    note: 'Ships within 24 hours on weekdays.'
  },
  'Cable Knit Top': {
    estimated_days: '3-5',
    carrier: 'FedEx Home Delivery',
    free_threshold: 60,
    return_days: 21,
    note: 'Delicate knit. Handled with extra care during shipping.'
  },
  'Casual Jumpsuit': {
    estimated_days: '3-6',
    carrier: 'DHL Express',
    free_threshold: 70,
    return_days: 30,
    note: 'Available for express 2-day shipping at checkout.'
  },
  'Classic Blazer': {
    estimated_days: '5-8',
    carrier: 'FedEx Express',
    free_threshold: 100,
    return_days: 14,
    note: 'Premium packaging. Arrives in garment bag.'
  },
  'Crop Top': {
    estimated_days: '2-4',
    carrier: 'USPS Priority',
    free_threshold: 30,
    return_days: 30,
    note: 'Lightweight. Free shipping on orders over $30.'
  },
  'Chino Pants': {
    estimated_days: '3-5',
    carrier: 'UPS Standard',
    free_threshold: 55,
    return_days: 30,
    note: 'Exchange size for free within 30 days.'
  },
  'Denim Jumpsuit': {
    estimated_days: '4-7',
    carrier: 'FedEx Standard',
    free_threshold: 75,
    return_days: 21,
    note: 'Heavy denim item. Shipping rate applies for standard delivery.'
  },
  'Denim Shorts': {
    estimated_days: '2-4',
    carrier: 'USPS Priority Mail',
    free_threshold: 40,
    return_days: 30,
    note: 'Free shipping on all denim items this season.'
  },
  'Evening Dress': {
    estimated_days: '5-7',
    carrier: 'FedEx Express',
    free_threshold: 90,
    return_days: 14,
    note: 'Formal wear. Arrives in protective garment bag with hanger.'
  },
  'Famous dress': {
    estimated_days: '3-5',
    carrier: 'DHL Standard',
    free_threshold: 65,
    return_days: 30,
    note: 'One of our bestsellers. Ships fast due to high demand.'
  },
  'Floral Shorts': {
    estimated_days: '2-3',
    carrier: 'USPS First Class',
    free_threshold: 35,
    return_days: 30,
    note: 'Ships within 24h. Perfect for summer.'
  },
  'Girls Floral Dress': {
    estimated_days: '2-4',
    carrier: 'FedEx Home Delivery',
    free_threshold: 40,
    return_days: 30,
    note: 'Kids special packaging. Gift message available.'
  },
  'Girls Ruffle Top': {
    estimated_days: '2-3',
    carrier: 'USPS Priority',
    free_threshold: 35,
    return_days: 30,
    note: 'Ships next business day.'
  },
  'Knit Sweater': {
    estimated_days: '3-5',
    carrier: 'UPS Ground',
    free_threshold: 55,
    return_days: 21,
    note: 'Machine washable. Returns accepted within 21 days with tags.'
  },
  'Leather Jacket': {
    estimated_days: '5-8',
    carrier: 'FedEx Express Saver',
    free_threshold: 150,
    return_days: 14,
    note: 'Premium leather. Ships with authenticity card and care guide.'
  },
  'Light blouse': {
    estimated_days: '2-4',
    carrier: 'USPS Priority Mail',
    free_threshold: 45,
    return_days: 30,
    note: 'Lightweight summer item. Free returns available.'
  },
  'Maxi Skirt': {
    estimated_days: '3-6',
    carrier: 'FedEx Standard',
    free_threshold: 55,
    return_days: 30,
    note: 'Arrives folded in tissue paper packaging.'
  },
  'Midi Dress': {
    estimated_days: '3-5',
    carrier: 'DHL Express',
    free_threshold: 65,
    return_days: 30,
    note: 'Available in express shipping. Perfect for events.'
  },
  'Mini Skirt': {
    estimated_days: '2-4',
    carrier: 'USPS First Class',
    free_threshold: 35,
    return_days: 30,
    note: 'Quick ship. Order before 2pm for same day dispatch.'
  },
  'Polo Shirt': {
    estimated_days: '2-4',
    carrier: 'UPS Standard',
    free_threshold: 40,
    return_days: 30,
    note: 'Classic style. Free size exchange within 30 days.'
  },
  'Pullover': {
    estimated_days: '3-5',
    carrier: 'FedEx Home Delivery',
    free_threshold: 50,
    return_days: 21,
    note: 'Warm knit. Returns accepted in original condition.'
  },
  'Shirt': {
    estimated_days: '2-3',
    carrier: 'USPS Priority Mail',
    free_threshold: 40,
    return_days: 30,
    note: 'Fast dispatch. Wrinkle-free packaging.'
  },
  'Skinny Jeans': {
    estimated_days: '3-5',
    carrier: 'UPS Ground',
    free_threshold: 50,
    return_days: 30,
    note: 'Denim item. Exchange size for free once.'
  },
  'Sport Dress': {
    estimated_days: '2-4',
    carrier: 'USPS Priority',
    free_threshold: 35,
    return_days: 30,
    note: 'Active wear. Fast shipping to get you moving.'
  },
  'Striped top': {
    estimated_days: '2-3',
    carrier: 'USPS First Class',
    free_threshold: 35,
    return_days: 30,
    note: 'Popular item. Ships quickly.'
  },
  'Striped Top': {
    estimated_days: '2-4',
    carrier: 'FedEx Standard',
    free_threshold: 45,
    return_days: 30,
    note: 'Classic stripe. Available for express delivery.'
  },
  'Striped Top 2': {
    estimated_days: '2-4',
    carrier: 'DHL Express',
    free_threshold: 45,
    return_days: 30,
    note: 'New arrival. Ships within 48 hours.'
  },
  'Summer Dress': {
    estimated_days: '2-3',
    carrier: 'USPS Priority Mail',
    free_threshold: 40,
    return_days: 30,
    note: 'Light and breezy. Ships in eco-packaging.'
  },
  'T-shirt': {
    estimated_days: '1-3',
    carrier: 'USPS First Class',
    free_threshold: 25,
    return_days: 30,
    note: 'Fastest ship time. Get it in 1 day with express.'
  },
  'T-Shirt SPANISH': {
    estimated_days: '2-3',
    carrier: 'FedEx Standard',
    free_threshold: 30,
    return_days: 30,
    note: 'Limited edition. Ships while supplies last.'
  },
  'Trench Coat': {
    estimated_days: '5-8',
    carrier: 'FedEx Express',
    free_threshold: 120,
    return_days: 14,
    note: 'Premium outerwear. Ships with duster bag and belt.'
  },
  'White Shirt': {
    estimated_days: '2-4',
    carrier: 'USPS Priority',
    free_threshold: 40,
    return_days: 30,
    note: 'Classic white. Ironed and packaged to avoid creases.'
  },
};

// ─── Dữ liệu Support theo tên sản phẩm ───────────────────────────────────
const supportData = {
  'Blouse': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4560',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Machine washable cold. Dry flat. Iron on low heat.',
    warranty: '6-month quality guarantee on all blouses.'
  },
  'Bomber Jacket': {
    contact_email: 'jackets@fashionstore.com',
    phone: '+1 (800) 123-4561',
    hours: 'Mon–Sat 8am–8pm EST',
    faq: 'Hand wash recommended. Do not tumble dry.',
    warranty: '1-year stitching and zipper warranty.'
  },
  'Boys Cargo Shorts': {
    contact_email: 'kids@fashionstore.com',
    phone: '+1 (800) 123-4562',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Machine washable. Safe for children 3+.',
    warranty: '30-day satisfaction guarantee.'
  },
  'Boys Graphic Tee': {
    contact_email: 'kids@fashionstore.com',
    phone: '+1 (800) 123-4562',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Wash inside out to preserve print. Cold water only.',
    warranty: '60-day print quality guarantee.'
  },
  'Cable Knit Top': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4563',
    hours: 'Mon–Fri 10am–6pm EST',
    faq: 'Hand wash cold. Lay flat to dry.',
    warranty: '90-day yarn integrity guarantee.'
  },
  'Casual Jumpsuit': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4564',
    hours: 'Mon–Fri 9am–7pm EST',
    faq: 'Machine washable gentle cycle. Do not bleach.',
    warranty: '30-day return or exchange policy.'
  },
  'Classic Blazer': {
    contact_email: 'premium@fashionstore.com',
    phone: '+1 (800) 123-4565',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Dry clean only. Professional pressing recommended.',
    warranty: '1-year seam and lining warranty.'
  },
  'Crop Top': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4566',
    hours: 'Mon–Sun 10am–8pm EST',
    faq: 'Machine wash cold. Tumble dry low.',
    warranty: '30-day quality guarantee.'
  },
  'Chino Pants': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4567',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Machine washable. Iron on medium for crisp look.',
    warranty: '6-month seam warranty.'
  },
  'Denim Jumpsuit': {
    contact_email: 'denim@fashionstore.com',
    phone: '+1 (800) 123-4568',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Wash inside out cold. Do not bleach. Tumble dry low.',
    warranty: '90-day quality guarantee on hardware.'
  },
  'Denim Shorts': {
    contact_email: 'denim@fashionstore.com',
    phone: '+1 (800) 123-4569',
    hours: 'Mon–Sat 9am–7pm EST',
    faq: 'Machine wash cold. Air dry for best shape retention.',
    warranty: '90-day stitching guarantee.'
  },
  'Evening Dress': {
    contact_email: 'formal@fashionstore.com',
    phone: '+1 (800) 123-4570',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Dry clean only. Handle with care. Store on padded hanger.',
    warranty: '1-year construction warranty for formal wear.'
  },
  'Famous dress': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4571',
    hours: 'Mon–Fri 9am–7pm EST',
    faq: 'Hand wash recommended. Delicate cycle acceptable.',
    warranty: '30-day return policy.'
  },
  'Floral Shorts': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4572',
    hours: 'Mon–Sun 10am–6pm EST',
    faq: 'Machine wash cold. Tumble dry low. Do not iron print.',
    warranty: '30-day color fastness guarantee.'
  },
  'Girls Floral Dress': {
    contact_email: 'kids@fashionstore.com',
    phone: '+1 (800) 123-4573',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Machine wash gentle cold. Safe for sensitive skin.',
    warranty: 'OEKO-TEX certified. 30-day satisfaction guarantee.'
  },
  'Girls Ruffle Top': {
    contact_email: 'kids@fashionstore.com',
    phone: '+1 (800) 123-4574',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Wash gentle cold. Iron ruffles on low heat with cloth.',
    warranty: '30-day quality guarantee.'
  },
  'Knit Sweater': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4575',
    hours: 'Mon–Fri 10am–6pm EST',
    faq: 'Hand wash cold. Lay flat to dry. Do not wring.',
    warranty: '6-month pilling resistance guarantee.'
  },
  'Leather Jacket': {
    contact_email: 'premium@fashionstore.com',
    phone: '+1 (800) 123-4576',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Wipe clean with damp cloth. Use leather conditioner monthly.',
    warranty: '2-year craftsmanship warranty on genuine leather.'
  },
  'Light blouse': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4577',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Hand wash or delicate cycle. Do not tumble dry.',
    warranty: '30-day satisfaction guarantee.'
  },
  'Maxi Skirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4578',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Machine wash cold gentle. Hang to dry.',
    warranty: '30-day color and hem guarantee.'
  },
  'Midi Dress': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4579',
    hours: 'Mon–Sat 9am–7pm EST',
    faq: 'Machine washable. Tumble dry low. Iron if needed.',
    warranty: '30-day return or size exchange.'
  },
  'Mini Skirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4580',
    hours: 'Mon–Sun 10am–8pm EST',
    faq: 'Machine wash cold. Air dry for best fit.',
    warranty: '30-day fit guarantee.'
  },
  'Polo Shirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4581',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Machine washable. Iron collar for neat look.',
    warranty: '6-month color retention guarantee.'
  },
  'Pullover': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4582',
    hours: 'Mon–Fri 10am–6pm EST',
    faq: 'Hand wash cold. Lay flat to dry. Avoid direct sunlight.',
    warranty: '90-day yarn quality guarantee.'
  },
  'Shirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4583',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Machine wash or dry clean. Iron for best appearance.',
    warranty: '6-month button and seam warranty.'
  },
  'Skinny Jeans': {
    contact_email: 'denim@fashionstore.com',
    phone: '+1 (800) 123-4584',
    hours: 'Mon–Sat 9am–7pm EST',
    faq: 'Wash inside out cold. Air dry to maintain stretch.',
    warranty: '90-day stretch and seam guarantee.'
  },
  'Sport Dress': {
    contact_email: 'active@fashionstore.com',
    phone: '+1 (800) 123-4585',
    hours: 'Mon–Fri 8am–8pm EST',
    faq: 'Machine wash cold. Tumble dry low. UV-resistant fabric.',
    warranty: '6-month performance fabric guarantee.'
  },
  'Striped top': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4586',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Machine wash cold inside out. Do not bleach stripes.',
    warranty: '60-day color fastness guarantee.'
  },
  'Striped Top': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4587',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Cold wash. Tumble dry low. Iron on medium if needed.',
    warranty: '60-day color guarantee.'
  },
  'Striped Top 2': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4588',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'New fabric blend. Machine wash gentle. Air dry recommended.',
    warranty: '30-day new arrival guarantee.'
  },
  'Summer Dress': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4589',
    hours: 'Mon–Sun 9am–7pm EST',
    faq: 'Hand wash or gentle machine wash. Hang to dry.',
    warranty: '30-day summer wear guarantee.'
  },
  'T-shirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4590',
    hours: 'Mon–Sun 9am–10pm EST',
    faq: 'Machine washable. Tumble dry. Our most durable fabric.',
    warranty: '1-year print and stitching guarantee.'
  },
  'T-Shirt SPANISH': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4591',
    hours: 'Mon–Fri 9am–7pm EST',
    faq: 'Limited edition. Wash inside out cold. Do not iron print.',
    warranty: '60-day limited edition quality guarantee.'
  },
  'Trench Coat': {
    contact_email: 'premium@fashionstore.com',
    phone: '+1 (800) 123-4592',
    hours: 'Mon–Fri 9am–6pm EST',
    faq: 'Dry clean only. Water-resistant coating maintained by professional cleaning.',
    warranty: '2-year water resistance and seam warranty.'
  },
  'White Shirt': {
    contact_email: 'support@fashionstore.com',
    phone: '+1 (800) 123-4593',
    hours: 'Mon–Fri 9am–5pm EST',
    faq: 'Machine wash at 40°C. Iron damp for crisp collar.',
    warranty: '6-month fabric whiteness guarantee.'
  },
};

// ─── Danh sách reviews theo category ──────────────────────────────────────
const reviewPool = [
  { name: 'Emma Thompson', avatar: 'E', color: '#EF9A9A', rating: 5, text: 'Absolutely love this! Perfect fit and great quality. Will definitely buy again in different colors.' },
  { name: 'Sophia Lee', avatar: 'S', color: '#90CAF9', rating: 5, text: 'Beautiful item, exactly as pictured. Shipping was fast and packaging was lovely.' },
  { name: 'Oliver Brown', avatar: 'O', color: '#A5D6A7', rating: 4, text: 'Great quality for the price. Runs slightly small so size up if between sizes.' },
  { name: 'Isabella Clark', avatar: 'I', color: '#CE93D8', rating: 4, text: 'Very happy with this purchase. Material feels premium and stitching is excellent.' },
  { name: 'Liam Wilson', avatar: 'L', color: '#FFE082', rating: 3, text: 'Good product overall but color was slightly different from the photos. Still wearable.' },
  { name: 'Ava Martinez', avatar: 'A', color: '#80CBC4', rating: 5, text: 'This exceeded my expectations! Bought as a gift and the recipient loved it.' },
  { name: 'Noah Davis', avatar: 'N', color: '#BCAAA4', rating: 4, text: 'Solid purchase. Comfortable and stylish. The fabric is breathable and soft.' },
  { name: 'Mia Anderson', avatar: 'M', color: '#F48FB1', rating: 5, text: 'Stunning! I wore this to a party and got so many compliments. Love the cut and fit.' },
  { name: 'James Taylor', avatar: 'J', color: '#80DEEA', rating: 3, text: 'Decent product. Took about 6 days to arrive but quality is good once it came.' },
  { name: 'Charlotte White', avatar: 'C', color: '#FFCC80', rating: 4, text: 'Nice product. The size guide was accurate and it fits perfectly as described.' },
  { name: 'Elijah Johnson', avatar: 'E', color: '#B0BEC5', rating: 5, text: 'Top-notch quality. Exactly what I was looking for. Very happy with this purchase.' },
  { name: 'Harper Lewis', avatar: 'H', color: '#EF9A9A', rating: 4, text: 'Great find! Stylish and well made. Would recommend to anyone looking for a similar item.' },
  { name: 'Amelia Scott', avatar: 'A', color: '#A5D6A7', rating: 2, text: 'Not quite what I expected. The material feels thinner than it looks in photos.' },
  { name: 'Benjamin Harris', avatar: 'B', color: '#81D4FA', rating: 5, text: 'Perfect in every way. Fast shipping, great packaging, excellent quality. 10/10!' },
  { name: 'Evelyn King', avatar: 'E', color: '#CE93D8', rating: 4, text: 'Really pleased with this. Washed well and kept its shape. Good investment.' },
];

const dates = [
  'March 12, 2025', 'April 5, 2025', 'May 20, 2025', 'June 1, 2025',
  'June 15, 2025', 'July 3, 2025', 'August 10, 2025', 'September 2, 2025',
  'October 18, 2025', 'November 5, 2025', 'December 12, 2025',
  'January 8, 2026', 'February 14, 2026', 'March 22, 2026', 'April 30, 2026'
];

async function main() {
  console.log('🔧 Tạo các bảng mới...');

  // ── Tạo bảng product_shipping ──────────────────────────────────────────
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_shipping (
      id               SERIAL PRIMARY KEY,
      product_id       UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      estimated_days   VARCHAR(20) DEFAULT '3-5',
      carrier          VARCHAR(100) DEFAULT 'Standard Shipping',
      free_threshold   NUMERIC DEFAULT 50,
      return_days      INTEGER DEFAULT 30,
      note             TEXT,
      created_at       TIMESTAMP DEFAULT NOW()
    );
  `);

  // ── Tạo bảng product_support ───────────────────────────────────────────
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_support (
      id               SERIAL PRIMARY KEY,
      product_id       UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      contact_email    VARCHAR(100) DEFAULT 'support@fashionstore.com',
      phone            VARCHAR(50)  DEFAULT '+1 (800) 123-4560',
      hours            VARCHAR(100) DEFAULT 'Mon–Fri 9am–6pm EST',
      faq              TEXT,
      warranty         TEXT,
      created_at       TIMESTAMP DEFAULT NOW()
    );
  `);

  // ── Tạo bảng product_reviews ───────────────────────────────────────────
  await pool.query(`
    CREATE TABLE IF NOT EXISTS product_reviews (
      id               SERIAL PRIMARY KEY,
      product_id       UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      reviewer_name    VARCHAR(100) NOT NULL,
      avatar_letter    CHAR(1),
      avatar_color     VARCHAR(10),
      rating           INTEGER CHECK (rating BETWEEN 1 AND 5),
      review_text      TEXT,
      review_date      VARCHAR(50),
      has_photo        BOOLEAN DEFAULT FALSE,
      helpful_count    INTEGER DEFAULT 0,
      created_at       TIMESTAMP DEFAULT NOW()
    );
  `);

  console.log('✅ Tạo bảng xong');

  // ── Xóa dữ liệu cũ ─────────────────────────────────────────────────────
  await pool.query('DELETE FROM product_shipping');
  await pool.query('DELETE FROM product_support');
  await pool.query('DELETE FROM product_reviews');
  console.log('🗑️  Đã xóa dữ liệu cũ');

  // ── Lấy danh sách sản phẩm ─────────────────────────────────────────────
  const { rows: products } = await pool.query(
    'SELECT id, product_name FROM products WHERE published = true ORDER BY product_name'
  );
  console.log(`📦 ${products.length} sản phẩm`);

  let inserted = 0;
  for (const prod of products) {
    const name = prod.product_name;
    const id = prod.id;

    // ── Shipping ─────────────────────────────────────────────────────────
    const ship = shippingData[name] || {
      estimated_days: '3-5', carrier: 'Standard Shipping',
      free_threshold: 50, return_days: 30, note: 'Standard shipping applies.'
    };
    await pool.query(
      `INSERT INTO product_shipping (product_id, estimated_days, carrier, free_threshold, return_days, note)
       VALUES ($1,$2,$3,$4,$5,$6)`,
      [id, ship.estimated_days, ship.carrier, ship.free_threshold, ship.return_days, ship.note]
    );

    // ── Support ──────────────────────────────────────────────────────────
    const sup = supportData[name] || {
      contact_email: 'support@fashionstore.com', phone: '+1 (800) 123-4560',
      hours: 'Mon–Fri 9am–6pm EST', faq: 'Machine washable. Standard care.', warranty: '30-day guarantee.'
    };
    await pool.query(
      `INSERT INTO product_support (product_id, contact_email, phone, hours, faq, warranty)
       VALUES ($1,$2,$3,$4,$5,$6)`,
      [id, sup.contact_email, sup.phone, sup.hours, sup.faq, sup.warranty]
    );

    // ── Reviews: 3–6 reviews ngẫu nhiên mỗi sản phẩm ────────────────────
    // Dùng hash tên sản phẩm để chọn reviews nhất quán (không random mỗi lần)
    const seed = name.split('').reduce((a, c) => a + c.charCodeAt(0), 0);
    const count = 3 + (seed % 4); // 3–6 reviews
    const usedIndexes = new Set();

    for (let i = 0; i < count; i++) {
      const rIdx = (seed + i * 7 + i * i) % reviewPool.length;
      const review = reviewPool[rIdx];
      const dateIdx = (seed + i * 3) % dates.length;
      const hasPhoto = (seed + i) % 4 === 0;

      await pool.query(
        `INSERT INTO product_reviews (product_id, reviewer_name, avatar_letter, avatar_color, rating, review_text, review_date, has_photo, helpful_count)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
        [id, review.name, review.avatar, review.color, review.rating, review.text, dates[dateIdx], hasPhoto, Math.floor((seed + i * 5) % 20)]
      );
    }

    console.log(`  ✓ ${name}: shipping + support + ${count} reviews`);
    inserted++;
  }

  console.log(`\n✅ Hoàn thành! ${inserted} sản phẩm đã có đầy đủ dữ liệu`);
  await pool.end();
}

main().catch(e => {
  console.error('❌ Lỗi:', e.message);
  pool.end();
  process.exit(1);
});
