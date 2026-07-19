/* =========================================================================
   SEEDED MASTER DATA AND PRODUCTS FROM THE CURRENT PROJECT
   ========================================================================= */

-- =========================================================================
-- 1. ADMINISTRATIVE DIVISIONS
-- =========================================================================
INSERT INTO Province (id, province_name, type) VALUES
('01', N'Thành phố Hà Nội',       N'Thành phố Trung ương'),
('79', N'Thành phố Hồ Chí Minh',  N'Thành phố Trung ương'),
('92', N'Thành phố Cần Thơ',      N'Thành phố Trung ương');

INSERT INTO District (id, district_name, type, province_id) VALUES
('001', N'Quận Ba Đình',   N'Quận', '01'),
('002', N'Quận Tây Hồ',   N'Quận', '01'),
('760', N'Quận 1',         N'Quận', '79'),
('769', N'Quận Thủ Đức',  N'Quận', '79'),
('916', N'Quận Ninh Kiều', N'Quận', '92');

INSERT INTO Ward (id, ward_name, type, district_id) VALUES
('00001', N'Phường Phúc Xá',    N'Phường', '001'),
('00010', N'Phường Trúc Bạch',  N'Phường', '001'),
('26734', N'Phường Bến Nghé',   N'Phường', '760'),
('26743', N'Phường Cô Giang',   N'Phường', '760'),
('31147', N'Phường An Khánh',   N'Phường', '916'),
('31162', N'Phường Xuân Khánh', N'Phường', '916');

-- =========================================================================
-- 2. ROLES & USERS
-- =========================================================================
INSERT INTO Role (role_name, description) VALUES
('ADMIN',    N'Quản trị viên toàn quyền hệ thống'),
('STAFF',    N'Nhân viên quản lý kho và đơn hàng'),
('CUSTOMER', N'Khách hàng mua sắm trực tuyến');

-- Shared bcrypt password for all demo accounts: 123456
INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) VALUES
('admin01',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Văn Admin',   'admin@clothesshop.com', '0911223344', 'ACTIVE', 1),
('admin02',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Nhật Quy',    'quy@gmail.com',         '0911223344', 'ACTIVE', 1),
('staff01',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Trần Thị Nhân Viên', 'staff@clothesshop.com', '0922334455', 'ACTIVE', 2),
('quy_nn',      '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Ngọc Quý',    'quynn@gmail.com',       '0933445566', 'ACTIVE', 3),
('khachhang02', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Lê Hoàng Nam',       'namlh@gmail.com',       '0944556677', 'ACTIVE', 3);

INSERT INTO User_Address (user_id, recipient_name, recipient_phone, ward_id, address_detail, is_default) VALUES
(4, N'Nguyễn Ngọc Quý',        '0933445566', '31162', N'123 3/2 Street',                1),
(4, N'Anh Quý (Office)',       '0933445566', '26734', N'Bitexco Building, Floor 15',    0),
(5, N'Lê Hoàng Nam',           '0944556677', '00010', N'45 Truc Bach Street',            1);

-- =========================================================================
-- 3. BRANDS & CATEGORIES
-- =========================================================================
INSERT INTO Brand (brand_name, slug, description, logo_url) VALUES
('Coolmate', 'coolmate', N'Minimalist menswear brand',                       'coolmate_logo.png'),
('Routine',  'routine',  N'Everyday fashion for men and women',              'routine_logo.png'),
('Uniqlo',   'uniqlo',   N'International retail fashion from Japan',         'uniqlo_logo.png');

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'Mens Tops',  'ao-nam',  NULL, N'Tops and shirts for men', 1),
(N'Mens Bottoms','quan-nam', NULL, N'Bottoms and trousers for men', 1);

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'T-Shirts', 'ao-thun-t-shirt', 1, N'Mens crew-neck and V-neck T-shirts', 1),
(N'Shirts',   'ao-so-mi',        1, N'Long-sleeve and short-sleeve shirts', 1),
(N'Mens Jeans','quan-jean-nam',  2, N'Full-length denim jeans for men', 1);

-- =========================================================================
-- 4. ATTRIBUTES
-- =========================================================================
INSERT INTO Attribute (attribute_name) VALUES
(N'Color'),
(N'Size');

-- =========================================================================
-- 5. PRODUCTS (ID 1-22)
-- =========================================================================
INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status, created_at, updated_at) VALUES
(N'Compact Cotton Mens T-Shirt',    'ao-thun-nam-cotton-compact',    1, 3, N'Cool 100% cotton T-shirt',             N'Durable compact cotton is twice as strong as regular cotton and offers excellent moisture absorption for everyday wear.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Slim-Fit Mens Jeans',            'quan-jean-nam-dang-slimfit',    2, 5, N'Polished jeans with light stretch',    N'A lightly fitted cut and flexible denim keep you comfortable throughout the day.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Pro Mens Performance T-Shirt',   'ao-thun-the-thao-nam-pro',      1, 3, N'Stretchy, breathable fabric',          N'Ideal for sports, gym sessions, and running with excellent colorfastness.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Classic Cotton Crew-Neck T-Shirt','ao-t-shirt-cotton-co-tron',     1, 3, N'Soft 100% natural cotton',             N'A versatile basic fit that stays cool and easy to style all year round.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Textured Mens Polo Shirt',        'ao-polo-nam-gan-noi',           1, 3, N'Polished polo with a flattering fit',   N'Pique fabric blended with spandex helps the shirt retain its shape after repeated washing.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Oversized Street T-Shirt',        'ao-thun-oversize-duong-pho',    1, 3, N'Dynamic streetwear style',             N'A relaxed cut with sharp digital-print graphics that will not peel.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Lightweight Linen Mandarin Shirt', 'ao-so-mi-co-tau-vai-dui',      2, 4, N'Light, breathable linen',              N'A gentle vintage style for travel, coffee dates, and relaxed days.', 'ACTIVE', GETDATE(), GETDATE()),
(N'White Oxford Business Shirt',     'ao-so-mi-trang-cong-so-oxford', 2, 4, N'Heavyweight Oxford fabric',             N'An essential shirt for work and special occasions.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Classic Striped Shirt',            'ao-so-mi-hoa-tiet-soc-ke',      3, 4, N'Young, elegant stripes',               N'Wrinkle-resistant fabric provides comfortable wear throughout the day.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Rugged Denim Shirt',               'ao-so-mi-denim-bui-bam',        2, 4, N'Confident denim style',                N'Soft medium-weight denim works as an overshirt or a standalone piece.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Black Baggy Jeans',                'quan-jean-den-tron-dang-baggy', 2, 5, N'Comfortable baggy fit',                N'Suitable for all genders, with durable denim that does not fade easily.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Distressed Knee Jeans',             'quan-jean-rach-goi-ca-tinh',    2, 5, N'Youthful distressed-knee detail',       N'Made for anyone who enjoys an edgy, rugged look.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Smoke Gray Stretch Jeans',           'quan-jean-co-gian-mau-xam-khoi',2, 5, N'Trendy, easy-to-style smoke gray',      N'A balanced cotton and spandex blend delivers maximum stretch.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Regular Straight-Leg Mens Jeans',   'quan-jean-nam-dang-dung-regular',3,5, N'Classic, polished straight leg',       N'An easy choice for work or weekends.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Water-Resistant Windbreaker',       'ao-khoac-gio-chong-nuoc',       3, 3, N'Light rain and wind protection',       N'Premium Japanese technical fabric with a convenient inner pocket.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Warm Winter Fleece Hoodie',         'ao-hoodie-ni-bong-mua-dong',    1, 3, N'Thick, cozy fleece',                   N'A relaxed local-brand fit with secure ribbed cuffs.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Beach Kaki Shorts',                  'quan-short-kaki-di-bien',       2, 5, N'Soft kaki in multiple colors',         N'A youthful mid-thigh length with a comfortable elastic waistband.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Gym Mens Tank Top',                  'ao-tanktop-nam-sat-nach-gym',   1, 3, N'Athletic deep-armhole design',         N'Cool quick-dry jersey wicks away sweat in seconds.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Classic Mens Dress Trousers',        'quan-tay-au-cong-so-nam',       2, 5, N'Structured premium fabric',            N'Features an adjustable waistband and pairs well with dress shirts.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Korean-Style Mens Blazer',           'ao-blazer-nam-han-quoc',        2, 4, N'Relaxed romantic fit',                 N'Smoothly lined fabric is ideal for fall and winter.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Warm Turtleneck Sweater',             'ao-len-co-lo-giu-nhiet',        3, 3, N'Flexible rib-knit yarn',              N'Keeps the neck warm while following the body for a confident silhouette.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Dynamic Sport Joggers',               'quan-jogger-the-thao-nang-dong',1, 5, N'Premium loopback fleece',              N'Comfortable for lounging, workouts, or weekend walks.', 'ACTIVE', GETDATE(), GETDATE());
GO

-- =========================================================================
-- 6. PRODUCT VARIANTS (SKU) — ID 1-80
-- =========================================================================

-- Product 1: Áo Thun Nam Cotton Compact (variant_id 1-4)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(1, 'CM-TSHIRT-BLK-M',  90000, 189000, 50, 'ACTIVE'),
(1, 'CM-TSHIRT-BLK-L',  90000, 189000, 45, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-M',  90000, 189000, 30, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-L',  90000, 189000,  0, 'ACTIVE');

-- Product 2: Quần Jean Nam Dáng Slimfit (variant_id 5-6)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(2, 'RT-JEAN-BLU-30', 250000, 450000, 20, 'ACTIVE'),
(2, 'RT-JEAN-BLU-31', 250000, 450000, 15, 'ACTIVE');

-- Product 3: Áo Thun Thể Thao Nam Pro (variant_id 7-10)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(3, 'CM-SPORT-BLK-M',  95000, 199000, 40, 'ACTIVE'),
(3, 'CM-SPORT-BLK-L',  95000, 199000, 35, 'ACTIVE'),
(3, 'CM-SPORT-NVY-M',  95000, 199000, 25, 'ACTIVE'),
(3, 'CM-SPORT-NVY-L',  95000, 199000, 20, 'ACTIVE');

-- Product 4: Áo T-Shirt Cotton Cổ Tròn (variant_id 11-14)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(4, 'CM-CTSHIRT-WHT-S', 85000, 179000, 30, 'ACTIVE'),
(4, 'CM-CTSHIRT-WHT-M', 85000, 179000, 45, 'ACTIVE'),
(4, 'CM-CTSHIRT-GRY-M', 85000, 179000, 30, 'ACTIVE'),
(4, 'CM-CTSHIRT-GRY-L', 85000, 179000, 25, 'ACTIVE');

-- Product 5: Áo Polo Nam Gân Nổi (variant_id 15-18)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(5, 'CM-POLO-WHT-M',  120000, 259000, 30, 'ACTIVE'),
(5, 'CM-POLO-WHT-L',  120000, 259000, 25, 'ACTIVE'),
(5, 'CM-POLO-NVY-M',  120000, 259000, 20, 'ACTIVE'),
(5, 'CM-POLO-NVY-XL', 120000, 259000, 15, 'ACTIVE');

-- Product 6: Áo Thun Oversize Đường Phố (variant_id 19-22)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(6, 'CM-OVER-BLK-L',  100000, 219000, 35, 'ACTIVE'),
(6, 'CM-OVER-BLK-XL', 100000, 219000, 30, 'ACTIVE'),
(6, 'CM-OVER-BEG-L',  100000, 219000, 20, 'ACTIVE'),
(6, 'CM-OVER-BEG-XL', 100000, 219000, 15, 'ACTIVE');

-- Product 7: Áo Sơ Mi Cổ Tàu Vải Đũi (variant_id 23-26)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(7, 'RT-LINEN-BEG-M', 150000, 320000, 25, 'ACTIVE'),
(7, 'RT-LINEN-BEG-L', 150000, 320000, 20, 'ACTIVE'),
(7, 'RT-LINEN-BRN-M', 150000, 320000, 15, 'ACTIVE'),
(7, 'RT-LINEN-BRN-L', 150000, 320000, 10, 'ACTIVE');

-- Product 8: Áo Sơ Mi Trắng Công Sở Oxford (variant_id 27-29)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(8, 'RT-OXF-WHT-M',  130000, 280000, 40, 'ACTIVE'),
(8, 'RT-OXF-WHT-L',  130000, 280000, 35, 'ACTIVE'),
(8, 'RT-OXF-WHT-XL', 130000, 280000, 20, 'ACTIVE');

-- Product 9: Áo Sơ Mi Họa Tiết Sọc Kẻ (variant_id 30-33)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(9, 'UQ-STRIPE-BLU-M', 140000, 299000, 25, 'ACTIVE'),
(9, 'UQ-STRIPE-BLU-L', 140000, 299000, 20, 'ACTIVE'),
(9, 'UQ-STRIPE-GRY-M', 140000, 299000, 15, 'ACTIVE'),
(9, 'UQ-STRIPE-GRY-L', 140000, 299000, 10, 'ACTIVE');

-- Product 10: Áo Sơ Mi Denim Bụi Bặm (variant_id 34-36)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(10, 'RT-DENIM-BLU-M',  160000, 340000, 20, 'ACTIVE'),
(10, 'RT-DENIM-BLU-L',  160000, 340000, 18, 'ACTIVE'),
(10, 'RT-DENIM-BLU-XL', 160000, 340000, 12, 'ACTIVE');

-- Product 11: Quần Jean Đen Trơn Dáng Baggy (variant_id 37-39)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(11, 'RT-BAGGY-BLK-28', 220000, 480000, 20, 'ACTIVE'),
(11, 'RT-BAGGY-BLK-30', 220000, 480000, 25, 'ACTIVE'),
(11, 'RT-BAGGY-BLK-32', 220000, 480000, 15, 'ACTIVE');

-- Product 12: Quần Jean Rách Gối Cá Tính (variant_id 40-42)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(12, 'RT-RIP-BLU-28', 200000, 420000, 18, 'ACTIVE'),
(12, 'RT-RIP-BLU-30', 200000, 420000, 22, 'ACTIVE'),
(12, 'RT-RIP-BLU-32', 200000, 420000, 12, 'ACTIVE');

-- Product 13: Quần Jean Co Giãn Màu Xám Khói (variant_id 43-45)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(13, 'RT-STRETCH-GRY-28', 230000, 490000, 15, 'ACTIVE'),
(13, 'RT-STRETCH-GRY-30', 230000, 490000, 20, 'ACTIVE'),
(13, 'RT-STRETCH-GRY-32', 230000, 490000, 10, 'ACTIVE');

-- Product 14: Quần Jean Nam Dáng Đứng Regular (variant_id 46-48)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(14, 'UQ-REG-DBL-30', 240000, 499000, 20, 'ACTIVE'),
(14, 'UQ-REG-DBL-32', 240000, 499000, 18, 'ACTIVE'),
(14, 'UQ-REG-DBL-34', 240000, 499000, 10, 'ACTIVE');

-- Product 15: Áo Khoác Gió Chống Nước (variant_id 49-52)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(15, 'UQ-WIND-BLK-M', 280000, 590000, 20, 'ACTIVE'),
(15, 'UQ-WIND-BLK-L', 280000, 590000, 18, 'ACTIVE'),
(15, 'UQ-WIND-OLV-M', 280000, 590000, 12, 'ACTIVE'),
(15, 'UQ-WIND-OLV-L', 280000, 590000, 10, 'ACTIVE');

-- Product 16: Áo Hoodie Nỉ Bông Mùa Đông (variant_id 53-56)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(16, 'CM-HOOD-GRY-M',  180000, 379000, 25, 'ACTIVE'),
(16, 'CM-HOOD-GRY-L',  180000, 379000, 20, 'ACTIVE'),
(16, 'CM-HOOD-BLK-M',  180000, 379000, 18, 'ACTIVE'),
(16, 'CM-HOOD-BLK-XL', 180000, 379000, 12, 'ACTIVE');

-- Product 17: Quần Short Kaki Đi Biển (variant_id 57-60)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(17, 'RT-SHORT-BEG-M', 90000, 199000, 30, 'ACTIVE'),
(17, 'RT-SHORT-BEG-L', 90000, 199000, 25, 'ACTIVE'),
(17, 'RT-SHORT-OLV-M', 90000, 199000, 20, 'ACTIVE'),
(17, 'RT-SHORT-OLV-L', 90000, 199000, 15, 'ACTIVE');

-- Product 18: Áo Tanktop Nam Sát Nách Gym (variant_id 61-64)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(18, 'CM-TANK-BLK-M', 70000, 149000, 40, 'ACTIVE'),
(18, 'CM-TANK-BLK-L', 70000, 149000, 35, 'ACTIVE'),
(18, 'CM-TANK-WHT-M', 70000, 149000, 30, 'ACTIVE'),
(18, 'CM-TANK-WHT-L', 70000, 149000, 25, 'ACTIVE');

-- Product 19: Quần Tây Âu Công Sở Nam (variant_id 65-68)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(19, 'RT-TROU-BLK-30', 200000, 420000, 20, 'ACTIVE'),
(19, 'RT-TROU-BLK-32', 200000, 420000, 18, 'ACTIVE'),
(19, 'RT-TROU-NVY-30', 200000, 420000, 15, 'ACTIVE'),
(19, 'RT-TROU-NVY-32', 200000, 420000, 12, 'ACTIVE');

-- Product 20: Áo Blazer Nam Hàn Quốc (variant_id 69-72)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(20, 'RT-BLZR-BLK-M', 320000, 680000, 15, 'ACTIVE'),
(20, 'RT-BLZR-BLK-L', 320000, 680000, 12, 'ACTIVE'),
(20, 'RT-BLZR-GRY-M', 320000, 680000, 10, 'ACTIVE'),
(20, 'RT-BLZR-GRY-L', 320000, 680000,  8, 'ACTIVE');

-- Product 21: Áo Len Cổ Lọ Giữ Nhiệt (variant_id 73-76)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(21, 'UQ-KNIT-CRM-M', 170000, 359000, 20, 'ACTIVE'),
(21, 'UQ-KNIT-CRM-L', 170000, 359000, 15, 'ACTIVE'),
(21, 'UQ-KNIT-BLK-M', 170000, 359000, 18, 'ACTIVE'),
(21, 'UQ-KNIT-BLK-L', 170000, 359000, 12, 'ACTIVE');

-- Product 22: Quần Jogger Thể Thao Năng Động (variant_id 77-80)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES
(22, 'CM-JOG-BLK-M',  110000, 229000, 30, 'ACTIVE'),
(22, 'CM-JOG-BLK-L',  110000, 229000, 25, 'ACTIVE'),
(22, 'CM-JOG-GRY-M',  110000, 229000, 20, 'ACTIVE'),
(22, 'CM-JOG-GRY-XL', 110000, 229000, 15, 'ACTIVE');
GO

-- =========================================================================
-- 7. VARIANT ATTRIBUTE VALUES (variant_id 1-80)
-- =========================================================================

-- Product 1 (variant_id 1-4)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(1, 1, N'Black'),      (1, 2, 'M'),
(2, 1, N'Black'),      (2, 2, 'L'),
(3, 1, N'White'),      (3, 2, 'M'),
(4, 1, N'White'),      (4, 2, 'L');

-- Product 2 (variant_id 5-6)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(5, 1, N'Smoke Gray'),  (5, 2, '30'),
(6, 1, N'Smoke Gray'),  (6, 2, '31');

-- Product 3 (variant_id 7-10)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(7,  1, 'Black'), (7,  2, 'M'),
(8,  1, 'Black'), (8,  2, 'L'),
(9,  1, 'Navy'),  (9,  2, 'M'),
(10, 1, 'Navy'),  (10, 2, 'L');

-- Product 4 (variant_id 11-14)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(11, 1, 'White'), (11, 2, 'S'),
(12, 1, 'White'), (12, 2, 'M'),
(13, 1, 'Gray'),  (13, 2, 'M'),
(14, 1, 'Gray'),  (14, 2, 'L');

-- Product 5 (variant_id 15-18)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(15, 1, 'White'), (15, 2, 'M'),
(16, 1, 'White'), (16, 2, 'L'),
(17, 1, 'Navy'),  (17, 2, 'M'),
(18, 1, 'Navy'),  (18, 2, 'XL');

-- Product 6 (variant_id 19-22)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(19, 1, 'Black'), (19, 2, 'L'),
(20, 1, 'Black'), (20, 2, 'XL'),
(21, 1, 'Beige'), (21, 2, 'L'),
(22, 1, 'Beige'), (22, 2, 'XL');

-- Product 7 (variant_id 23-26)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(23, 1, 'Beige'), (23, 2, 'M'),
(24, 1, 'Beige'), (24, 2, 'L'),
(25, 1, 'Brown'), (25, 2, 'M'),
(26, 1, 'Brown'), (26, 2, 'L');

-- Product 8 (variant_id 27-29)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(27, 1, 'White'), (27, 2, 'M'),
(28, 1, 'White'), (28, 2, 'L'),
(29, 1, 'White'), (29, 2, 'XL');

-- Product 9 (variant_id 30-33)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(30, 1, 'Blue Stripe'), (30, 2, 'M'),
(31, 1, 'Blue Stripe'), (31, 2, 'L'),
(32, 1, 'Gray Stripe'), (32, 2, 'M'),
(33, 1, 'Gray Stripe'), (33, 2, 'L');

-- Product 10 (variant_id 34-36)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(34, 1, 'Denim Blue'), (34, 2, 'M'),
(35, 1, 'Denim Blue'), (35, 2, 'L'),
(36, 1, 'Denim Blue'), (36, 2, 'XL');

-- Product 11 (variant_id 37-39)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(37, 1, 'Black'), (37, 2, '28'),
(38, 1, 'Black'), (38, 2, '30'),
(39, 1, 'Black'), (39, 2, '32');

-- Product 12 (variant_id 40-42)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(40, 1, 'Blue'), (40, 2, '28'),
(41, 1, 'Blue'), (41, 2, '30'),
(42, 1, 'Blue'), (42, 2, '32');

-- Product 13 (variant_id 43-45)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(43, 1, 'Smoke Gray'), (43, 2, '28'),
(44, 1, 'Smoke Gray'), (44, 2, '30'),
(45, 1, 'Smoke Gray'), (45, 2, '32');

-- Product 14 (variant_id 46-48)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(46, 1, 'Dark Blue'), (46, 2, '30'),
(47, 1, 'Dark Blue'), (47, 2, '32'),
(48, 1, 'Dark Blue'), (48, 2, '34');

-- Product 15 (variant_id 49-52)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(49, 1, 'Black'), (49, 2, 'M'),
(50, 1, 'Black'), (50, 2, 'L'),
(51, 1, 'Olive'), (51, 2, 'M'),
(52, 1, 'Olive'), (52, 2, 'L');

-- Product 16 (variant_id 53-56)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(53, 1, 'Gray'),  (53, 2, 'M'),
(54, 1, 'Gray'),  (54, 2, 'L'),
(55, 1, 'Black'), (55, 2, 'M'),
(56, 1, 'Black'), (56, 2, 'XL');

-- Product 17 (variant_id 57-60)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(57, 1, 'Beige'), (57, 2, 'M'),
(58, 1, 'Beige'), (58, 2, 'L'),
(59, 1, 'Olive'), (59, 2, 'M'),
(60, 1, 'Olive'), (60, 2, 'L');

-- Product 18 (variant_id 61-64)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(61, 1, 'Black'), (61, 2, 'M'),
(62, 1, 'Black'), (62, 2, 'L'),
(63, 1, 'White'), (63, 2, 'M'),
(64, 1, 'White'), (64, 2, 'L');

-- Product 19 (variant_id 65-68)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(65, 1, 'Black'), (65, 2, '30'),
(66, 1, 'Black'), (66, 2, '32'),
(67, 1, 'Navy'),  (67, 2, '30'),
(68, 1, 'Navy'),  (68, 2, '32');

-- Product 20 (variant_id 69-72)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(69, 1, 'Black'), (69, 2, 'M'),
(70, 1, 'Black'), (70, 2, 'L'),
(71, 1, 'Gray'),  (71, 2, 'M'),
(72, 1, 'Gray'),  (72, 2, 'L');

-- Product 21 (variant_id 73-76)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(73, 1, 'Cream'), (73, 2, 'M'),
(74, 1, 'Cream'), (74, 2, 'L'),
(75, 1, 'Black'), (75, 2, 'M'),
(76, 1, 'Black'), (76, 2, 'L');

-- Product 22 (variant_id 77-80)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(77, 1, 'Black'), (77, 2, 'M'),
(78, 1, 'Black'), (78, 2, 'L'),
(79, 1, 'Gray'),  (79, 2, 'M'),
(80, 1, 'Gray'),  (80, 2, 'XL');
GO

-- =========================================================================
-- 8. PRODUCT IMAGES
-- =========================================================================
INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES
(1, 'ao_thun_den_front.png',  1, 0),
(1, 'ao_thun_den_back.png',   0, 1),
(1, 'ao_thun_trang_front.png',0, 2),
(2, 'quan_jean_xanh_front.png',1, 0),
(3, 'prod3-main.jpg',  1, 0), (3, 'prod3-detail1.jpg',  0, 1),
(4, 'prod4-main.jpg',  1, 0),
(5, 'prod5-main.jpg',  1, 0), (5, 'prod5-detail1.jpg',  0, 1),
(6, 'prod6-main.jpg',  1, 0),
(7, 'prod7-main.jpg',  1, 0), (7, 'prod7-detail1.jpg',  0, 1),
(8, 'prod8-main.jpg',  1, 0),
(9, 'prod9-main.jpg',  1, 0), (9, 'prod9-detail1.jpg',  0, 1),
(10,'prod10-main.jpg', 1, 0),
(11,'prod11-main.jpg', 1, 0), (11,'prod11-detail1.jpg', 0, 1),
(12,'prod12-main.jpg', 1, 0),
(13,'prod13-main.jpg', 1, 0), (13,'prod13-detail1.jpg', 0, 1),
(14,'prod14-main.jpg', 1, 0),
(15,'prod15-main.jpg', 1, 0), (15,'prod15-detail1.jpg', 0, 1),
(16,'prod16-main.jpg', 1, 0),
(17,'prod17-main.jpg', 1, 0), (17,'prod17-detail1.jpg', 0, 1),
(18,'prod18-main.jpg', 1, 0),
(19,'prod19-main.jpg', 1, 0), (19,'prod19-detail1.jpg', 0, 1),
(20,'prod20-main.jpg', 1, 0),
(21,'prod21-main.jpg', 1, 0), (21,'prod21-detail1.jpg', 0, 1),
(22,'prod22-main.jpg', 1, 0);

/* =========================================================================
   VIII. SYNCHRONIZE DIRECT SIZE/COLOR FIELDS
   ========================================================================= */

UPDATE pv
SET
    pv.color = color_value.attribute_value,
    pv.size = size_value.attribute_value,
    pv.list_price = COALESCE(pv.list_price, pv.sale_price)
FROM dbo.Product_Variant pv
OUTER APPLY (
    SELECT TOP 1 vav.attribute_value
    FROM dbo.Variant_Attribute_Value vav
    INNER JOIN dbo.Attribute a ON a.id = vav.attribute_id
    WHERE vav.variant_id = pv.id
      AND a.attribute_name = N'Color'
) color_value
OUTER APPLY (
    SELECT TOP 1 vav.attribute_value
    FROM dbo.Variant_Attribute_Value vav
    INNER JOIN dbo.Attribute a ON a.id = vav.attribute_id
    WHERE vav.variant_id = pv.id
      AND a.attribute_name = N'Size'
) size_value;
GO

/* =========================================================================
   IX. PERMISSIONS
   These rows define the intended access matrix. Current controllers/filters
   still need to enforce these permissions at application level.
   ========================================================================= */

INSERT INTO dbo.Permission
    (permission_code, permission_name, description)
VALUES
('DASHBOARD_VIEW',   N'View dashboard',           N'View administrative statistics and reports'),
('PRODUCT_VIEW',     N'View products',            N'View the administrative product list and details'),
('PRODUCT_MANAGE',   N'Manage products',          N'Create, update and change product status'),
('CATEGORY_MANAGE',  N'Manage categories',        N'Create, update and change category status'),
('PRICE_MANAGE',     N'Manage prices',            N'Update list price, sale price and price history'),
('VOUCHER_MANAGE',   N'Manage vouchers',          N'Create, update and terminate vouchers'),
('INVENTORY_VIEW',   N'View inventory',           N'View stock balances and inventory history'),
('INVENTORY_IMPORT', N'Import stock',              N'Create and confirm import receipts'),
('INVENTORY_ADJUST', N'Adjust stock',              N'Create and approve stock adjustments'),
('ORDER_MANAGE',     N'Manage orders',             N'Approve, cancel and update order workflow'),
('FEEDBACK_MANAGE',  N'Manage feedback',           N'Hide, show and respond to feedback');

INSERT INTO dbo.Role_Permission (role_id, permission_id)
SELECT 1, id
FROM dbo.Permission;

INSERT INTO dbo.Role_Permission (role_id, permission_id)
SELECT 2, id
FROM dbo.Permission
WHERE permission_code IN (
    'DASHBOARD_VIEW',
    'PRODUCT_VIEW',
    'INVENTORY_VIEW',
    'INVENTORY_IMPORT',
    'ORDER_MANAGE',
    'FEEDBACK_MANAGE'
);
GO

/* =========================================================================
   X. PRICE HISTORY SAMPLE
   ========================================================================= */

UPDATE dbo.Product_Variant
SET price_updated_at = '2026-07-02 09:00:00',
    price_updated_by = 2
WHERE id IN (1, 5);

INSERT INTO dbo.Product_Variant_Price_History (
    variant_id,
    product_name_snapshot,
    sku_snapshot,
    color_snapshot,
    size_snapshot,
    old_list_price,
    new_list_price,
    old_sale_price,
    new_sale_price,
    cost_price_snapshot,
    change_type,
    change_reason,
    changed_by,
    changed_by_name_snapshot,
    changed_at
)
VALUES
(1, N'Compact Cotton Mens T-Shirt', 'CM-TSHIRT-BLK-M',
 N'Black', N'M', 199000, 189000, 199000, 189000, 90000,
 'PRICE_UPDATE', N'Adjusted selling price for the summer campaign',
 2, N'Nguyễn Nhật Quy', '2026-07-02 09:00:00'),
(5, N'Slim-Fit Mens Jeans', 'RT-JEAN-BLU-30',
 N'Smoke Gray', N'30', 480000, 450000, 480000, 450000, 250000,
 'PRICE_UPDATE', N'Updated price to match current sales policy',
 2, N'Nguyễn Nhật Quy', '2026-07-02 09:10:00');
GO

/* =========================================================================
   XI. INVENTORY: SUPPLIERS, RECEIPTS, BATCHES AND ADJUSTMENT
   ========================================================================= */

INSERT INTO dbo.Supplier
    (supplier_name, contact_name, phone, email, address, status)
VALUES
(N'Việt Tín Textile', N'Nguyễn Thành Tín', '0901000001',
 'sales@viettin.example', N'Ho Chi Minh City', 1),
(N'Minh Anh Garment', N'Trần Minh Anh', '0901000002',
 'contact@minhanh.example', N'Bình Dương', 1),
(N'Global Fashion Supply', N'Lê Gia Huy', '0901000003',
 'support@globalfashion.example', N'Đồng Nai', 1);

INSERT INTO dbo.Import_Receipt (
    receipt_code, supplier_id, user_id, total_amount, created_at,
    status, note, vendor_reference, confirmed_by, confirmed_at
)
VALUES
('IR-20260701-001', 1, 2, 4300000,
 '2026-07-01 08:30:00', 'CONFIRMED',
 N'Confirmed receipt used to test inventory history',
 N'VT-INV-0701', 1, '2026-07-01 09:00:00'),
('IR-20260715-002', 2, 2, 1550000,
 '2026-07-15 14:20:00', 'DRAFT',
 N'Draft receipt used to test edit and confirm flow',
 N'MA-DRAFT-0715', NULL, NULL);

INSERT INTO dbo.Import_Receipt_Detail
    (import_receipt_id, variant_id, quantity, unit_cost, line_total)
VALUES
(1, 1, 20,  90000, 1800000),
(1, 5, 10, 250000, 2500000),
(2, 7, 10,  95000,  950000),
(2, 15, 5, 120000,  600000);

-- Opening batches. Variants 1 and 5 receive the remaining quantity from the
-- confirmed receipt below. Variant 12 started at 47 and lost 2 damaged units.
INSERT INTO dbo.Product_Batch (
    variant_id, batch_code, cost_price,
    initial_quantity, current_quantity,
    import_receipt_id, import_receipt_detail_id,
    status, created_at
)
SELECT
    pv.id,
    CONCAT('OPEN-', pv.sku),
    pv.cost_price,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 47
        ELSE pv.stock_quantity
    END,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 45
        ELSE pv.stock_quantity
    END,
    NULL,
    NULL,
    CASE WHEN pv.stock_quantity = 0 THEN 'CLOSED' ELSE 'AVAILABLE' END,
    '2026-01-01 08:00:00'
FROM dbo.Product_Variant pv
WHERE
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 47
        ELSE pv.stock_quantity
    END > 0;

INSERT INTO dbo.Product_Batch (
    variant_id, batch_code, cost_price,
    initial_quantity, current_quantity,
    import_receipt_id, import_receipt_detail_id,
    status, created_at
)
VALUES
(1, 'IR-20260701-001-01',  90000, 20, 20, 1, 1, 'AVAILABLE', '2026-07-01 09:00:00'),
(5, 'IR-20260701-001-02', 250000, 10, 10, 1, 2, 'AVAILABLE', '2026-07-01 09:00:00');

INSERT INTO dbo.Inventory_Log (
    variant_id, user_id, product_name_snapshot, sku_snapshot,
    quantity_before, change_quantity, quantity_after,
    transaction_type, reference_type, reference_id, note, created_at
)
SELECT
    pv.id,
    1,
    p.product_name,
    pv.sku,
    0,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 47
        ELSE pv.stock_quantity
    END,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 47
        ELSE pv.stock_quantity
    END,
    'OPENING_BALANCE',
    'SYSTEM_SETUP',
    NULL,
    N'Opening stock created by the database seed',
    '2026-01-01 08:00:00'
FROM dbo.Product_Variant pv
INNER JOIN dbo.Product p ON p.id = pv.product_id
WHERE
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
        WHEN pv.id = 12 THEN 47
        ELSE pv.stock_quantity
    END > 0;

INSERT INTO dbo.Inventory_Log (
    variant_id, user_id, product_name_snapshot, sku_snapshot,
    quantity_before, change_quantity, quantity_after,
    transaction_type, reference_type, reference_id, note, created_at
)
VALUES
(1, 1, N'Compact Cotton Mens T-Shirt', 'CM-TSHIRT-BLK-M',
 30, 20, 50, 'IMPORT', 'IMPORT_RECEIPT', 1,
 N'Posted from receipt IR-20260701-001', '2026-07-01 09:00:00'),
(5, 1, N'Slim-Fit Mens Jeans', 'RT-JEAN-BLU-30',
 10, 10, 20, 'IMPORT', 'IMPORT_RECEIPT', 1,
 N'Posted from receipt IR-20260701-001', '2026-07-01 09:00:00');

INSERT INTO dbo.Stock_Adjustment (
    adjustment_code, adjustment_type, status, reason,
    created_by, approved_by, created_at, approved_at
)
VALUES
('ADJ-20260710-001', 'DAMAGED', 'APPROVED',
 N'Two units were damaged during physical stock inspection',
 2, 1, '2026-07-10 10:00:00', '2026-07-10 10:20:00');

INSERT INTO dbo.Stock_Adjustment_Detail (
    adjustment_id, variant_id, quantity_before,
    change_quantity, quantity_after, note
)
VALUES
(1, 12, 47, -2, 45, N'Damaged units removed from available stock');

INSERT INTO dbo.Inventory_Log (
    variant_id, user_id, product_name_snapshot, sku_snapshot,
    quantity_before, change_quantity, quantity_after,
    transaction_type, reference_type, reference_id, note, created_at
)
VALUES
(12, 1, N'Classic Cotton Crew-Neck T-Shirt', 'CM-CTSHIRT-WHT-M',
 47, -2, 45, 'ADJUST_DECREASE', 'STOCK_ADJUSTMENT', 1,
 N'Two damaged units removed after stock inspection',
 '2026-07-10 10:20:00');
GO

/* =========================================================================
   XII. VOUCHERS
   ========================================================================= */

INSERT INTO dbo.Voucher (
    code, title, discount_type, discount_value,
    max_discount_amount, min_order_value,
    start_date, end_date, usage_limit, used_count,
    limit_per_user, terminate_reason, category_id
)
VALUES
('WELCOME50', N'50,000 VND welcome discount', 'FIXED_AMOUNT',
 50000, 50000, 150000,
 '2026-01-01', '2026-12-31 23:59:59', 1000, 1, 1, NULL, NULL),

('SUMMER10', N'10% summer discount', 'PERCENTAGE',
 10, 30000, 200000,
 '2026-03-01', '2026-08-31 23:59:59', 500, 1, 1, NULL, NULL),

('TOPS15', N'15% discount for T-Shirts', 'PERCENTAGE',
 15, 50000, 300000,
 '2026-06-01', '2026-09-30 23:59:59', 300, 1, 1, NULL, 3),

('OLD20', N'Expired 20% campaign', 'PERCENTAGE',
 20, 100000, 500000,
 '2026-01-01', '2026-06-30 23:59:59', 100, 0, 1, NULL, NULL);
GO

/* =========================================================================
   XIII. CART AND WISHLIST
   ========================================================================= */

INSERT INTO dbo.Cart (user_id, variant_id, quantity)
VALUES
(4, 3, 1),
(4, 7, 2),
(5, 69, 1);

INSERT INTO dbo.Wishlist (user_id, product_id, variant_id)
VALUES
(4, 20, 69),
(5, 1, 1);
GO

/* =========================================================================
   XIV. SHIPMENTS, ORDERS, DETAILS AND PAYMENTS
   ========================================================================= */

INSERT INTO dbo.Shipment (
    carrier_name, shipping_status, tracking_code,
    shipping_cost, estimated_delivery_time
)
VALUES
(N'GHN', 'DELIVERED', 'GHN-20260115-001', 30000, '2026-01-17 17:00:00'),
(N'GHTK', 'DELIVERED', 'GHTK-20260220-002', 30000, '2026-02-22 17:00:00'),
(N'Viettel Post', 'DELIVERED', 'VTP-20260312-003', 30000, '2026-03-14 17:00:00'),
(N'GHN', 'DELIVERED', 'GHN-20260405-004', 30000, '2026-04-07 17:00:00'),
(N'GHTK', 'DELIVERED', 'GHTK-20260518-005', 30000, '2026-05-20 17:00:00'),
(N'Internal Delivery', 'FAILED', NULL, 30000, NULL),
(N'GHN', 'SHIPPING', 'GHN-20260712-007', 30000, '2026-07-18 17:00:00'),
(N'GHTK', 'PENDING_PICKUP', 'GHTK-20260714-008', 30000, '2026-07-20 17:00:00'),
(N'Internal Delivery', 'PENDING_PICKUP', NULL, 30000, NULL),
(N'Viettel Post', 'DELIVERED', 'VTP-20260705-010', 30000, '2026-07-07 17:00:00');

INSERT INTO dbo.[Order] (
    order_code, user_id, voucher_id, shipment_id,
    recipient_name, recipient_phone, ward_id, address_detail,
    total_items_price, discount_amount, shipping_fee, total_payment,
    order_status, note, created_at, updated_at
)
VALUES
('ORD-20260115-001', 4, 1, 1,
 N'Nguyễn Ngọc Quý', '0933445566', '31162', N'123 3/2 Street',
 378000, 50000, 30000, 358000,
 'DELIVERED', N'Completed January order',
 '2026-01-15 10:30:00', '2026-01-17 15:00:00'),

('ORD-20260220-002', 5, NULL, 2,
 N'Lê Hoàng Nam', '0944556677', '00010', N'45 Truc Bach Street',
 450000, 0, 30000, 480000,
 'DELIVERED', N'Completed February order',
 '2026-02-20 14:15:00', '2026-02-22 16:30:00'),

('ORD-20260312-003', 4, 2, 3,
 N'Nguyễn Ngọc Quý', '0933445566', '31162', N'123 3/2 Street',
 518000, 30000, 30000, 518000,
 'DELIVERED', N'Completed March order with summer voucher',
 '2026-03-12 09:00:00', '2026-03-14 11:00:00'),

('ORD-20260405-004', 5, NULL, 4,
 N'Lê Hoàng Nam', '0944556677', '00010', N'45 Truc Bach Street',
 680000, 0, 30000, 710000,
 'DELIVERED', N'Completed blazer order',
 '2026-04-05 18:20:00', '2026-04-07 20:00:00'),

('ORD-20260518-005', 4, 3, 5,
 N'Nguyễn Ngọc Quý', '0933445566', '31162', N'123 3/2 Street',
 398000, 50000, 30000, 378000,
 'DELIVERED', N'Completed category voucher order',
 '2026-05-18 11:10:00', '2026-05-20 14:00:00'),

('ORD-20260620-006', 5, NULL, 6,
 N'Lê Hoàng Nam', '0944556677', '00010', N'45 Truc Bach Street',
 379000, 0, 30000, 409000,
 'CANCELLED', N'Cancelled before warehouse release',
 '2026-06-20 14:05:00', '2026-06-20 14:40:00'),

('ORD-20260712-007', 4, NULL, 7,
 N'Nguyễn Ngọc Quý', '0933445566', '26734', N'Bitexco Building, Floor 15',
 560000, 0, 30000, 590000,
 'SHIPPING', N'Currently in transit',
 '2026-07-12 11:45:00', '2026-07-16 13:00:00'),

('ORD-20260714-008', 5, NULL, 8,
 N'Lê Hoàng Nam', '0944556677', '00010', N'45 Truc Bach Street',
 229000, 0, 30000, 259000,
 'CONFIRMED', N'Confirmed and waiting for pickup',
 '2026-07-14 08:30:00', '2026-07-15 09:00:00'),

('ORD-20260716-009', 4, NULL, 9,
 N'Nguyễn Ngọc Quý', '0933445566', '31162', N'123 3/2 Street',
 179000, 0, 30000, 209000,
 'PENDING', N'New order waiting for approval',
 '2026-07-16 15:20:00', '2026-07-16 15:20:00'),

('ORD-20260705-010', 5, NULL, 10,
 N'Lê Hoàng Nam', '0944556677', '00010', N'45 Truc Bach Street',
 340000, 0, 30000, 370000,
 'RETURNED', N'Returned after delivery because the size did not fit',
 '2026-07-05 09:00:00', '2026-07-12 10:15:00');

INSERT INTO dbo.Order_Detail (
    order_id, variant_id, product_name_snapshot,
    variant_attributes_snapshot, quantity, price
)
VALUES
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260115-001'),
 1, N'Compact Cotton Mens T-Shirt', N'Color: Black, Size: M', 2, 189000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260220-002'),
 5, N'Slim-Fit Mens Jeans', N'Color: Smoke Gray, Size: 30', 1, 450000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260312-003'),
 15, N'Textured Mens Polo Shirt', N'Color: White, Size: M', 2, 259000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260405-004'),
 69, N'Korean-Style Mens Blazer', N'Color: Black, Size: M', 1, 680000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260518-005'),
 7, N'Pro Mens Performance T-Shirt', N'Color: Black, Size: M', 2, 199000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260620-006'),
 53, N'Warm Winter Fleece Hoodie', N'Color: Gray, Size: M', 1, 379000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260712-007'),
 28, N'White Oxford Business Shirt', N'Color: White, Size: L', 2, 280000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260714-008'),
 77, N'Dynamic Sport Joggers', N'Color: Black, Size: M', 1, 229000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260716-009'),
 12, N'Classic Cotton Crew-Neck T-Shirt', N'Color: White, Size: M', 1, 179000),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260705-010'),
 34, N'Rugged Denim Shirt', N'Color: Denim Blue, Size: M', 1, 340000);

INSERT INTO dbo.Payment (
    order_id, payment_method, payment_status,
    amount, transaction_reference, payment_date
)
VALUES
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260115-001'),
 'VNPAY', 'PAID', 358000, 'TXN-20260115-001', '2026-01-15 10:35:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260220-002'),
 'BANK_TRANSFER', 'PAID', 480000, 'TXN-20260220-002', '2026-02-20 14:20:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260312-003'),
 'COD', 'PAID', 518000, NULL, '2026-03-14 11:00:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260405-004'),
 'VNPAY', 'PAID', 710000, 'TXN-20260405-004', '2026-04-05 18:25:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260518-005'),
 'BANK_TRANSFER', 'PAID', 378000, 'TXN-20260518-005', '2026-05-18 11:15:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260620-006'),
 'COD', 'UNPAID', 409000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260712-007'),
 'COD', 'UNPAID', 590000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260714-008'),
 'VNPAY', 'PAID', 259000, 'TXN-20260714-008', '2026-07-14 08:35:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260716-009'),
 'COD', 'UNPAID', 209000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260705-010'),
 'BANK_TRANSFER', 'REFUNDED', 370000, 'TXN-20260705-010', '2026-07-12 10:30:00');

INSERT INTO dbo.Voucher_Usage (
    voucher_id, user_id, order_id, discount_amount, used_at
)
VALUES
(1, 4, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260115-001'),
 50000, '2026-01-15 10:30:00'),
(2, 4, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260312-003'),
 30000, '2026-03-12 09:00:00'),
(3, 4, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260518-005'),
 50000, '2026-05-18 11:10:00');
GO

/* =========================================================================
   XV. FEEDBACK AND ACTIVITY LOG
   ========================================================================= */

INSERT INTO dbo.Feedback (
    user_id, product_id, order_id, rating, comment, status,
    admin_response, response_by, responded_at, created_at
)
VALUES
(4, 1, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260115-001'),
 5, N'Comfortable fabric and accurate sizing.', 1,
 N'Thank you for your review.', 2,
 '2026-01-18 09:00:00', '2026-01-17 20:00:00'),

(5, 2, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260220-002'),
 4, N'Good fit and durable denim.', 1,
 NULL, NULL, NULL, '2026-02-23 09:00:00'),

(4, 5, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260312-003'),
 4, N'The polo keeps its shape after washing.', 1,
 NULL, NULL, NULL, '2026-03-15 10:00:00'),

(5, 20, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260405-004'),
 3, N'Good blazer, but delivery was slightly late.', 1,
 N'We recorded the carrier issue and will improve delivery coordination.',
 1, '2026-04-09 08:30:00', '2026-04-08 18:00:00'),

(5, 10, (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260705-010'),
 2, N'The material was good, but the size did not fit.', 0,
 N'The return was accepted and the payment was refunded.',
 2, '2026-07-12 11:00:00', '2026-07-12 10:45:00');

INSERT INTO dbo.Activity_Log (
    user_id, action_type, description, ip_address, created_at
)
VALUES
(1, 'LOGIN', N'Administrator signed in', '127.0.0.1', '2026-07-16 08:00:00'),
(2, 'IMPORT_RECEIPT_CREATE', N'Created import receipt IR-20260715-002',
 '127.0.0.1', '2026-07-15 14:20:00'),
(2, 'PRICE_UPDATE', N'Updated prices for variants 1 and 5',
 '127.0.0.1', '2026-07-02 09:10:00');
GO

/* =========================================================================
   XVI. VALIDATION
   ========================================================================= */

IF EXISTS (
    SELECT 1
    FROM dbo.Product_Variant
    WHERE list_price IS NULL OR color IS NULL OR size IS NULL
)
BEGIN
    THROW 51001,
        'Seed validation failed: a product variant is missing list_price, color or size.',
        1;
END;

IF EXISTS (
    SELECT pv.id
    FROM dbo.Product_Variant pv
    OUTER APPLY (
        SELECT SUM(pb.current_quantity) AS batch_quantity
        FROM dbo.Product_Batch pb
        WHERE pb.variant_id = pv.id
    ) batch_total
    WHERE pv.stock_quantity <> ISNULL(batch_total.batch_quantity, 0)
)
BEGIN
    THROW 51002,
        'Seed validation failed: Product_Variant stock does not match Product_Batch balances.',
        1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.Import_Receipt ir
    OUTER APPLY (
        SELECT SUM(ird.line_total) AS detail_total
        FROM dbo.Import_Receipt_Detail ird
        WHERE ird.import_receipt_id = ir.id
    ) detail_sum
    WHERE ir.total_amount <> ISNULL(detail_sum.detail_total, 0)
)
BEGIN
    THROW 51003,
        'Seed validation failed: an import receipt total does not match its details.',
        1;
END;
GO

PRINT 'ClothesShopDB was created successfully.';
PRINT 'Demo password for all seeded accounts: 123456';
PRINT 'Admin account: admin01 / 123456';
PRINT 'Secondary admin: admin02 / 123456';
PRINT 'Staff account: staff01 / 123456';
GO

SELECT
    (SELECT COUNT(*) FROM dbo.Product) AS product_count,
    (SELECT COUNT(*) FROM dbo.Product_Variant) AS variant_count,
    (SELECT COUNT(*) FROM dbo.Supplier) AS supplier_count,
    (SELECT COUNT(*) FROM dbo.Import_Receipt) AS import_receipt_count,
    (SELECT COUNT(*) FROM dbo.Product_Batch) AS batch_count,
    (SELECT COUNT(*) FROM dbo.Inventory_Log) AS inventory_log_count,
    (SELECT COUNT(*) FROM dbo.Voucher) AS voucher_count,
    (SELECT COUNT(*) FROM dbo.[Order]) AS order_count;
GO
