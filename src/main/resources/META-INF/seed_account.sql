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
   XVI. EXTENDED DEMO DATA
   This section intentionally adds a broader dataset for search, filtering,
   inventory, promotion, order, return and permission screens.
   ========================================================================= */

-- Additional locations
INSERT INTO dbo.Province (id, province_name, type) VALUES
('48', N'Thành phố Đà Nẵng', N'Thành phố Trung ương'),
('56', N'Tỉnh Khánh Hòa', N'Tỉnh');

INSERT INTO dbo.District (id, district_name, type, province_id) VALUES
('490', N'Quận Hải Châu', N'Quận', '48'),
('491', N'Quận Sơn Trà', N'Quận', '48'),
('569', N'Thành phố Nha Trang', N'Thành phố', '56'),
('570', N'Huyện Cam Lâm', N'Huyện', '56');

INSERT INTO dbo.Ward (id, ward_name, type, district_id) VALUES
('20194', N'Phường Thạch Thang', N'Phường', '490'),
('20200', N'Phường Hải Châu', N'Phường', '490'),
('20305', N'Phường An Hải Bắc', N'Phường', '491'),
('20314', N'Phường Mân Thái', N'Phường', '491'),
('22366', N'Phường Lộc Thọ', N'Phường', '569'),
('22369', N'Phường Vạn Thạnh', N'Phường', '569'),
('22420', N'Thị trấn Cam Đức', N'Thị trấn', '570'),
('22423', N'Xã Cam Hải Tây', N'Xã', '570');

-- More staff and customers
INSERT INTO dbo.[User]
    (username, password, full_name, email, phone, status, role_id)
VALUES
('staff02', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Phạm Minh Khoa', 'khoa.pm@clothesshop.com', '0905000001', 'ACTIVE', 2),
('staff03', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Đỗ Thùy Linh', 'linh.dt@clothesshop.com', '0905000002', 'ACTIVE', 2),
('customer03', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Nguyễn Minh Anh', 'anh.nm@gmail.com', '0905000003', 'ACTIVE', 3),
('customer04', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Trần Quốc Bảo', 'bao.tq@gmail.com', '0905000004', 'ACTIVE', 3),
('customer05', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Lê Khánh Vy', 'vy.lk@gmail.com', '0905000005', 'ACTIVE', 3),
('customer06', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Phan Đức Huy', 'huy.pd@gmail.com', '0905000006', 'ACTIVE', 3),
('customer07', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Vũ Ngọc Hà', 'ha.vn@gmail.com', '0905000007', 'ACTIVE', 3),
('customer08', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
 N'Bùi Gia Hân', 'han.bg@gmail.com', '0905000008', 'ACTIVE', 3);

INSERT INTO dbo.User_Address
    (user_id, recipient_name, recipient_phone, ward_id, address_detail, is_default)
SELECT u.id, u.full_name, u.phone, v.ward_id, v.address_detail, 1
FROM dbo.[User] u
INNER JOIN (VALUES
    ('customer03', '20194', N'12 Trần Phú'),
    ('customer04', '20305', N'88 Võ Văn Kiệt'),
    ('customer05', '22366', N'25 Nguyễn Thiện Thuật'),
    ('customer06', '22420', N'09 Hùng Vương'),
    ('customer07', '20200', N'41 Bạch Đằng'),
    ('customer08', '20314', N'66 Ngô Quyền')
) v(username, ward_id, address_detail) ON v.username = u.username;

INSERT INTO dbo.User_Address
    (user_id, recipient_name, recipient_phone, ward_id, address_detail, is_default)
SELECT u.id, u.full_name, u.phone, v.ward_id, v.address_detail, 0
FROM dbo.[User] u
INNER JOIN (VALUES
    ('customer03', '20200', N'Apartment A12, Hải Châu'),
    ('customer04', '22369', N'15 Lê Thánh Tôn'),
    ('customer05', '20194', N'Office 3F, Trần Phú'),
    ('customer06', '20305', N'20 Phạm Văn Đồng'),
    ('customer07', '22423', N'Khu dân cư Cam Hải Tây'),
    ('customer08', '22366', N'10 Tô Hiến Thành')
) v(username, ward_id, address_detail) ON v.username = u.username;

INSERT INTO dbo.Security_Token
    (user_id, token_type, token_value, expiry_date, is_used)
SELECT u.id, v.token_type, v.token_value, v.expiry_date, v.is_used
FROM dbo.[User] u
INNER JOIN (VALUES
    ('customer03', 'EMAIL_VERIFY', 'seed-token-customer03-email', '2026-12-31 23:59:59', 1),
    ('customer04', 'PASSWORD_RESET', 'seed-token-customer04-reset', '2026-08-01 23:59:59', 0),
    ('customer05', 'EMAIL_VERIFY', 'seed-token-customer05-email', '2026-12-31 23:59:59', 0),
    ('customer06', 'PASSWORD_RESET', 'seed-token-customer06-reset', '2026-08-15 23:59:59', 1),
    ('customer07', 'EMAIL_VERIFY', 'seed-token-customer07-email', '2026-12-31 23:59:59', 0),
    ('customer08', 'PASSWORD_RESET', 'seed-token-customer08-reset', '2026-09-01 23:59:59', 0),
    ('staff02', 'SESSION', 'seed-token-staff02-session', '2026-08-31 23:59:59', 0),
    ('staff03', 'SESSION', 'seed-token-staff03-session', '2026-08-31 23:59:59', 0)
) v(username, token_type, token_value, expiry_date, is_used) ON v.username = u.username;

-- More brands, categories and attributes
INSERT INTO dbo.Brand (brand_name, slug, description, logo_url) VALUES
(N'Lacoste', 'lacoste', N'Classic premium casualwear', 'lacoste_logo.png'),
(N'Nike', 'nike', N'Sportswear and performance essentials', 'nike_logo.png'),
(N'Adidas', 'adidas', N'Active lifestyle apparel', 'adidas_logo.png'),
(N'Zara', 'zara', N'Modern seasonal fashion', 'zara_logo.png');

INSERT INTO dbo.Category
    (category_name, slug, parent_id, description, status)
VALUES
(N'Womens Wear', 'ao-nu', NULL, N'Tops and fashion for women', 1),
(N'Womens Bottoms', 'quan-nu', NULL, N'Skirts and trousers for women', 1),
(N'Accessories', 'phu-kien', NULL, N'Bags, hats and daily accessories', 1),
(N'Sportswear', 'do-the-thao', NULL, N'Clothing for training and outdoor activities', 1);

INSERT INTO dbo.Category
    (category_name, slug, parent_id, description, status)
SELECT v.category_name, v.slug, c.id, v.description, 1
FROM (VALUES
    (N'Womens T-Shirts', 'ao-thun-nu', 'ao-nu', N'Comfortable womens T-shirts'),
    (N'Blouses', 'ao-so-mi-nu', 'ao-nu', N'Office and casual womens blouses'),
    (N'Skirts', 'chan-vay', 'quan-nu', N'Midi and casual skirts'),
    (N'Womens Trousers', 'quan-dai-nu', 'quan-nu', N'Wide-leg and straight womens trousers'),
    (N'Hats', 'mu-thoi-trang', 'phu-kien', N'Caps and everyday hats'),
    (N'Bags', 'tui-xach', 'phu-kien', N'Canvas and casual bags'),
    (N'Gym Wear', 'do-gym', 'do-the-thao', N'Flexible clothing for gym sessions')
) v(category_name, slug, parent_slug, description)
INNER JOIN dbo.Category c ON c.slug = v.parent_slug;

INSERT INTO dbo.Attribute (attribute_name) VALUES
(N'Material'),
(N'Fit');

INSERT INTO dbo.Permission
    (permission_code, permission_name, description)
VALUES
('USER_MANAGE',      N'Manage users',       N'View and update customer accounts'),
('SUPPLIER_MANAGE',  N'Manage suppliers',   N'Maintain supplier information'),
('RETURN_MANAGE',    N'Manage returns',     N'Review returns and exchange requests'),
('REPORT_EXPORT',    N'Export reports',     N'Export operational and sales reports'),
('AUDIT_VIEW',       N'View audit log',    N'View security and activity history');

INSERT INTO dbo.Role_Permission (role_id, permission_id)
SELECT r.id, p.id
FROM dbo.[Role] r
INNER JOIN dbo.Permission p ON
    (r.role_name = 'ADMIN')
    OR (r.role_name = 'STAFF' AND p.permission_code IN
        ('USER_MANAGE', 'SUPPLIER_MANAGE', 'RETURN_MANAGE', 'REPORT_EXPORT', 'AUDIT_VIEW'))
    OR (r.role_name = 'CUSTOMER' AND p.permission_code IN ('PRODUCT_VIEW'))
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Role_Permission rp
    WHERE rp.role_id = r.id AND rp.permission_id = p.id
);
GO

-- Twelve more products
INSERT INTO dbo.Product
    (product_name, slug, brand_id, category_id, short_description,
     long_description, status, created_at, updated_at)
VALUES
(N'Essential Womens Cotton Tee', 'ao-thun-nu-cotton-co-ban',
 (SELECT id FROM dbo.Brand WHERE slug = 'lacoste'),
 (SELECT id FROM dbo.Category WHERE slug = 'ao-thun-nu'),
 N'Clean basic tee for daily outfits',
 N'Soft cotton jersey with a relaxed silhouette and easy-care finish.', 'ACTIVE',
 '2026-01-12', '2026-07-01'),
(N'Pleated Office Blouse', 'ao-so-mi-nu-co-pleat',
 (SELECT id FROM dbo.Brand WHERE slug = 'zara'),
 (SELECT id FROM dbo.Category WHERE slug = 'ao-so-mi-nu'),
 N'Light blouse with delicate pleats',
 N'An elegant lightweight blouse for office styling and weekend layering.', 'ACTIVE',
 '2026-01-18', '2026-07-02'),
(N'Flowy Midi Skirt', 'chan-vay-midi-xep-ly',
 (SELECT id FROM dbo.Brand WHERE slug = 'zara'),
 (SELECT id FROM dbo.Category WHERE slug = 'chan-vay'),
 N'Flowy skirt with a graceful drape',
 N'Comfortable midi length and a flexible waistband for day-to-night wear.', 'ACTIVE',
 '2026-02-02', '2026-07-03'),
(N'High-Waist Wide-Leg Pants', 'quan-dai-nu-ong-rong',
 (SELECT id FROM dbo.Brand WHERE slug = 'routine'),
 (SELECT id FROM dbo.Category WHERE slug = 'quan-dai-nu'),
 N'High-waist trousers with a wide leg',
 N'Easy-to-style trousers made from smooth fabric with a structured drape.', 'ACTIVE',
 '2026-02-10', '2026-07-04'),
(N'Everyday Training Leggings', 'quan-legging-the-thao-nu',
 (SELECT id FROM dbo.Brand WHERE slug = 'nike'),
 (SELECT id FROM dbo.Category WHERE slug = 'do-gym'),
 N'Stretch leggings for training',
 N'Breathable four-way stretch fabric supports gym sessions and active days.', 'ACTIVE',
 '2026-02-22', '2026-07-05'),
(N'Light Running Shorts', 'quan-short-chay-bo-nu',
 (SELECT id FROM dbo.Brand WHERE slug = 'adidas'),
 (SELECT id FROM dbo.Category WHERE slug = 'do-gym'),
 N'Lightweight running shorts',
 N'Quick-dry fabric and a secure inner pocket keep every run comfortable.', 'ACTIVE',
 '2026-03-04', '2026-07-06'),
(N'Soft Ribbed Cardigan', 'ao-cardigan-len-gan',
 (SELECT id FROM dbo.Brand WHERE slug = 'routine'),
 (SELECT id FROM dbo.Category WHERE slug = 'ao-nu'),
 N'Soft ribbed cardigan for layering',
 N'A versatile knit layer with a flattering shape for cool mornings.', 'ACTIVE',
 '2026-03-16', '2026-07-07'),
(N'Vintage Denim Jacket', 'ao-khoac-denim-nu-co-dien',
 (SELECT id FROM dbo.Brand WHERE slug = 'zara'),
 (SELECT id FROM dbo.Category WHERE slug = 'ao-nu'),
 N'Classic denim jacket',
 N'Medium-weight denim with timeless details and a slightly relaxed fit.', 'ACTIVE',
 '2026-04-01', '2026-07-08'),
(N'Classic Baseball Cap', 'mu-luoi-trai-basic',
 (SELECT id FROM dbo.Brand WHERE slug = 'adidas'),
 (SELECT id FROM dbo.Category WHERE slug = 'mu-thoi-trang'),
 N'Adjustable everyday baseball cap',
 N'Cotton twill construction with an adjustable back strap.', 'ACTIVE',
 '2026-04-14', '2026-07-09'),
(N'Natural Canvas Tote', 'tui-vai-canvas-tu-nhien',
 (SELECT id FROM dbo.Brand WHERE slug = 'routine'),
 (SELECT id FROM dbo.Category WHERE slug = 'tui-xach'),
 N'Reusable canvas tote bag',
 N'Strong canvas body with a roomy interior for work, school and shopping.', 'ACTIVE',
 '2026-05-01', '2026-07-10'),
(N'Fine Pique Womens Polo', 'ao-polo-nu-pique',
 (SELECT id FROM dbo.Brand WHERE slug = 'lacoste'),
 (SELECT id FROM dbo.Category WHERE slug = 'ao-thun-nu'),
 N'Polished pique polo',
 N'Breathable pique texture and a neat collar create a timeless smart-casual look.', 'ACTIVE',
 '2026-05-14', '2026-07-11'),
(N'Packable Rain Jacket', 'ao-mua-nhe-gap-gon',
 (SELECT id FROM dbo.Brand WHERE slug = 'nike'),
 (SELECT id FROM dbo.Category WHERE slug = 'do-the-thao'),
 N'Light packable rain jacket',
 N'Water-resistant shell folds into a compact pouch for travel and commuting.', 'ACTIVE',
 '2026-06-03', '2026-07-12');
GO

-- Forty-eight additional variants. Direct color/size values are supplied so
-- both the product listing projection and attribute-value screens have data.
INSERT INTO dbo.Product_Variant
    (product_id, sku, cost_price, list_price, sale_price, stock_quantity,
     status, color, size, price_updated_at, price_updated_by)
VALUES
((SELECT id FROM dbo.Product WHERE slug = 'ao-thun-nu-cotton-co-ban'), 'EXP-TEE-WOM-BLK-S', 120000, 249000, 229000, 48, 'ACTIVE', N'Black', N'S', '2026-07-01', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-thun-nu-cotton-co-ban'), 'EXP-TEE-WOM-BLK-M', 120000, 249000, 229000, 42, 'ACTIVE', N'Black', N'M', '2026-07-01', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-thun-nu-cotton-co-ban'), 'EXP-TEE-WOM-WHT-S', 120000, 249000, 229000, 36, 'ACTIVE', N'White', N'S', '2026-07-01', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-thun-nu-cotton-co-ban'), 'EXP-TEE-WOM-WHT-M', 120000, 249000, 229000, 30, 'ACTIVE', N'White', N'M', '2026-07-01', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-so-mi-nu-co-pleat'), 'EXP-BLOUSE-BLU-S', 180000, 369000, 329000, 35, 'ACTIVE', N'Blue', N'S', '2026-07-02', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-so-mi-nu-co-pleat'), 'EXP-BLOUSE-BLU-M', 180000, 369000, 329000, 31, 'ACTIVE', N'Blue', N'M', '2026-07-02', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-so-mi-nu-co-pleat'), 'EXP-BLOUSE-PNK-S', 180000, 369000, 329000, 22, 'ACTIVE', N'Pink', N'S', '2026-07-02', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-so-mi-nu-co-pleat'), 'EXP-BLOUSE-PNK-M', 180000, 369000, 329000, 19, 'ACTIVE', N'Pink', N'M', '2026-07-02', 2),
((SELECT id FROM dbo.Product WHERE slug = 'chan-vay-midi-xep-ly'), 'EXP-SKIRT-BLK-S', 210000, 599000, 549000, 28, 'ACTIVE', N'Black', N'S', '2026-07-03', 2),
((SELECT id FROM dbo.Product WHERE slug = 'chan-vay-midi-xep-ly'), 'EXP-SKIRT-BLK-M', 210000, 599000, 549000, 24, 'ACTIVE', N'Black', N'M', '2026-07-03', 2),
((SELECT id FROM dbo.Product WHERE slug = 'chan-vay-midi-xep-ly'), 'EXP-SKIRT-BEI-S', 210000, 599000, 549000, 21, 'ACTIVE', N'Beige', N'S', '2026-07-03', 2),
((SELECT id FROM dbo.Product WHERE slug = 'chan-vay-midi-xep-ly'), 'EXP-SKIRT-BEI-M', 210000, 599000, 549000, 17, 'ACTIVE', N'Beige', N'M', '2026-07-03', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-dai-nu-ong-rong'), 'EXP-PANTS-CRE-S', 230000, 599000, 549000, 26, 'ACTIVE', N'Cream', N'S', '2026-07-04', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-dai-nu-ong-rong'), 'EXP-PANTS-CRE-M', 230000, 599000, 549000, 23, 'ACTIVE', N'Cream', N'M', '2026-07-04', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-dai-nu-ong-rong'), 'EXP-PANTS-BLK-S', 230000, 599000, 549000, 18, 'ACTIVE', N'Black', N'S', '2026-07-04', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-dai-nu-ong-rong'), 'EXP-PANTS-BLK-M', 230000, 599000, 549000, 15, 'ACTIVE', N'Black', N'M', '2026-07-04', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-legging-the-thao-nu'), 'EXP-LEGGING-BLK-S', 170000, 449000, 399000, 32, 'ACTIVE', N'Black', N'S', '2026-07-05', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-legging-the-thao-nu'), 'EXP-LEGGING-BLK-M', 170000, 449000, 399000, 28, 'ACTIVE', N'Black', N'M', '2026-07-05', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-legging-the-thao-nu'), 'EXP-LEGGING-GRY-S', 170000, 449000, 399000, 24, 'ACTIVE', N'Gray', N'S', '2026-07-05', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-legging-the-thao-nu'), 'EXP-LEGGING-GRY-M', 170000, 449000, 399000, 20, 'ACTIVE', N'Gray', N'M', '2026-07-05', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-short-chay-bo-nu'), 'EXP-RUNSHORT-BLU-M', 120000, 299000, 259000, 29, 'ACTIVE', N'Blue', N'M', '2026-07-06', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-short-chay-bo-nu'), 'EXP-RUNSHORT-BLU-L', 120000, 299000, 259000, 25, 'ACTIVE', N'Blue', N'L', '2026-07-06', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-short-chay-bo-nu'), 'EXP-RUNSHORT-BLK-M', 120000, 299000, 259000, 22, 'ACTIVE', N'Black', N'M', '2026-07-06', 2),
((SELECT id FROM dbo.Product WHERE slug = 'quan-short-chay-bo-nu'), 'EXP-RUNSHORT-BLK-L', 120000, 299000, 259000, 18, 'ACTIVE', N'Black', N'L', '2026-07-06', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-cardigan-len-gan'), 'EXP-CARDI-CRE-M', 220000, 499000, 459000, 21, 'ACTIVE', N'Cream', N'M', '2026-07-07', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-cardigan-len-gan'), 'EXP-CARDI-CRE-L', 220000, 499000, 459000, 17, 'ACTIVE', N'Cream', N'L', '2026-07-07', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-cardigan-len-gan'), 'EXP-CARDI-GRY-M', 220000, 499000, 459000, 15, 'ACTIVE', N'Gray', N'M', '2026-07-07', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-cardigan-len-gan'), 'EXP-CARDI-GRY-L', 220000, 499000, 459000, 12, 'ACTIVE', N'Gray', N'L', '2026-07-07', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-khoac-denim-nu-co-dien'), 'EXP-DENIM-BLU-M', 300000, 699000, 649000, 18, 'ACTIVE', N'Denim Blue', N'M', '2026-07-08', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-khoac-denim-nu-co-dien'), 'EXP-DENIM-BLU-L', 300000, 699000, 649000, 15, 'ACTIVE', N'Denim Blue', N'L', '2026-07-08', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-khoac-denim-nu-co-dien'), 'EXP-DENIM-BLK-M', 300000, 699000, 649000, 12, 'ACTIVE', N'Black', N'M', '2026-07-08', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-khoac-denim-nu-co-dien'), 'EXP-DENIM-BLK-L', 300000, 699000, 649000, 9, 'ACTIVE', N'Black', N'L', '2026-07-08', 2),
((SELECT id FROM dbo.Product WHERE slug = 'mu-luoi-trai-basic'), 'EXP-CAP-BLK-FREE', 80000, 179000, 179000, 40, 'ACTIVE', N'Black', N'Free Size', '2026-07-09', 2),
((SELECT id FROM dbo.Product WHERE slug = 'mu-luoi-trai-basic'), 'EXP-CAP-WHT-FREE', 80000, 179000, 179000, 33, 'ACTIVE', N'White', N'Free Size', '2026-07-09', 2),
((SELECT id FROM dbo.Product WHERE slug = 'mu-luoi-trai-basic'), 'EXP-CAP-BEI-FREE', 80000, 179000, 179000, 27, 'ACTIVE', N'Beige', N'Free Size', '2026-07-09', 2),
((SELECT id FROM dbo.Product WHERE slug = 'mu-luoi-trai-basic'), 'EXP-CAP-NVY-FREE', 80000, 179000, 179000, 21, 'ACTIVE', N'Navy', N'Free Size', '2026-07-09', 2),
((SELECT id FROM dbo.Product WHERE slug = 'tui-vai-canvas-tu-nhien'), 'EXP-TOTE-NAT-FREE', 90000, 229000, 229000, 35, 'ACTIVE', N'Natural', N'Free Size', '2026-07-10', 2),
((SELECT id FROM dbo.Product WHERE slug = 'tui-vai-canvas-tu-nhien'), 'EXP-TOTE-BLK-FREE', 90000, 229000, 229000, 29, 'ACTIVE', N'Black', N'Free Size', '2026-07-10', 2),
((SELECT id FROM dbo.Product WHERE slug = 'tui-vai-canvas-tu-nhien'), 'EXP-TOTE-RED-FREE', 90000, 229000, 229000, 20, 'ACTIVE', N'Red', N'Free Size', '2026-07-10', 2),
((SELECT id FROM dbo.Product WHERE slug = 'tui-vai-canvas-tu-nhien'), 'EXP-TOTE-GRN-FREE', 90000, 229000, 229000, 16, 'ACTIVE', N'Green', N'Free Size', '2026-07-10', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-polo-nu-pique'), 'EXP-POLO-PNK-S', 160000, 399000, 399000, 25, 'ACTIVE', N'Pink', N'S', '2026-07-11', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-polo-nu-pique'), 'EXP-POLO-PNK-M', 160000, 399000, 399000, 21, 'ACTIVE', N'Pink', N'M', '2026-07-11', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-polo-nu-pique'), 'EXP-POLO-WHT-S', 160000, 399000, 399000, 18, 'ACTIVE', N'White', N'S', '2026-07-11', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-polo-nu-pique'), 'EXP-POLO-WHT-M', 160000, 399000, 399000, 14, 'ACTIVE', N'White', N'M', '2026-07-11', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-mua-nhe-gap-gon'), 'EXP-RAIN-BLU-S', 310000, 849000, 849000, 16, 'ACTIVE', N'Blue', N'S', '2026-07-12', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-mua-nhe-gap-gon'), 'EXP-RAIN-BLU-M', 310000, 849000, 849000, 14, 'ACTIVE', N'Blue', N'M', '2026-07-12', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-mua-nhe-gap-gon'), 'EXP-RAIN-BLK-S', 310000, 849000, 849000, 11, 'ACTIVE', N'Black', N'S', '2026-07-12', 2),
((SELECT id FROM dbo.Product WHERE slug = 'ao-mua-nhe-gap-gon'), 'EXP-RAIN-BLK-M', 310000, 849000, 849000, 8, 'ACTIVE', N'Black', N'M', '2026-07-12', 2);
GO

INSERT INTO dbo.Variant_Attribute_Value (variant_id, attribute_id, attribute_value)
SELECT pv.id, a.id,
       CASE a.attribute_name
           WHEN N'Color' THEN pv.color
           WHEN N'Size' THEN pv.size
           WHEN N'Material' THEN
               CASE
                   WHEN p.slug LIKE 'ao-thun%' OR p.slug LIKE 'ao-polo%' THEN N'Cotton'
                   WHEN p.slug LIKE 'ao-so-mi%' THEN N'Polyester Blend'
                   WHEN p.slug LIKE 'chan-vay%' OR p.slug LIKE 'quan-dai%' THEN N'Polyester'
                   WHEN p.slug LIKE 'quan-%' THEN N'Quick Dry'
                   WHEN p.slug LIKE 'ao-cardigan%' THEN N'Knit'
                   WHEN p.slug LIKE 'ao-khoac-denim%' THEN N'Denim'
                   WHEN p.slug LIKE 'mu-%' THEN N'Cotton Twill'
                   WHEN p.slug LIKE 'tui-%' THEN N'Canvas'
                   ELSE N'Nylon'
               END
           WHEN N'Fit' THEN
               CASE
                   WHEN p.slug LIKE 'quan-legging%' OR p.slug LIKE 'quan-short-chay%' THEN N'Slim Fit'
                   WHEN p.slug LIKE 'quan-dai%' OR p.slug LIKE 'chan-vay%' THEN N'Regular Fit'
                   ELSE N'Relaxed Fit'
               END
       END
FROM dbo.Product_Variant pv
INNER JOIN dbo.Product p ON p.id = pv.product_id
CROSS JOIN dbo.Attribute a
WHERE pv.sku LIKE 'EXP-%'
  AND a.attribute_name IN (N'Color', N'Size', N'Material', N'Fit')
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Variant_Attribute_Value existing
      WHERE existing.variant_id = pv.id
        AND existing.attribute_id = a.id
  );

INSERT INTO dbo.Product_Image (product_id, image_url, is_main, sort_order)
SELECT p.id, CONCAT(p.slug, '-main.jpg'), 1, 0
FROM dbo.Product p
WHERE p.brand_id >= (SELECT MIN(id) FROM dbo.Brand WHERE slug = 'lacoste')
UNION ALL
SELECT p.id, CONCAT(p.slug, '-detail.jpg'), 0, 1
FROM dbo.Product p
WHERE p.brand_id >= (SELECT MIN(id) FROM dbo.Brand WHERE slug = 'lacoste');

UPDATE pv
SET pv.color = color_value.attribute_value,
    pv.size = size_value.attribute_value,
    pv.list_price = COALESCE(pv.list_price, pv.sale_price)
FROM dbo.Product_Variant pv
OUTER APPLY (
    SELECT TOP 1 vav.attribute_value
    FROM dbo.Variant_Attribute_Value vav
    INNER JOIN dbo.Attribute a ON a.id = vav.attribute_id
    WHERE vav.variant_id = pv.id AND a.attribute_name = N'Color'
) color_value
OUTER APPLY (
    SELECT TOP 1 vav.attribute_value
    FROM dbo.Variant_Attribute_Value vav
    INNER JOIN dbo.Attribute a ON a.id = vav.attribute_id
    WHERE vav.variant_id = pv.id AND a.attribute_name = N'Size'
) size_value
WHERE pv.sku LIKE 'EXP-%';
GO

/* =========================================================================
   XVII. EXTENDED INVENTORY, PROMOTIONS AND SHOPPING DATA
   ========================================================================= */

INSERT INTO dbo.Product_Variant_Price_History (
    variant_id, product_name_snapshot, sku_snapshot, color_snapshot,
    size_snapshot, old_list_price, new_list_price, old_sale_price,
    new_sale_price, cost_price_snapshot, change_type, change_reason,
    changed_by, changed_by_name_snapshot, changed_at
)
SELECT pv.id, p.product_name, pv.sku, pv.color, pv.size,
       pv.list_price + 20000, pv.list_price, pv.sale_price + 20000,
       pv.sale_price, pv.cost_price, 'INITIAL_PRICE',
       N'Initial extended catalogue pricing', 2, N'Nguyễn Nhật Quy',
       DATEADD(DAY, -7, pv.price_updated_at)
FROM dbo.Product_Variant pv
INNER JOIN dbo.Product p ON p.id = pv.product_id
WHERE pv.sku LIKE 'EXP-%'
  AND pv.id % 4 = 0;

INSERT INTO dbo.Supplier
    (supplier_name, contact_name, phone, email, address, status)
VALUES
(N'Đông Á Fashion Materials', N'Nguyễn Hoàng Long', '0906000001', 'sales@donga.example', N'Đà Nẵng', 1),
(N'An Phú Sportswear', N'Phạm Quốc Việt', '0906000002', 'hello@anphu.example', N'Bình Dương', 1),
(N'Green Bag Workshop', N'Lê Thảo Nguyên', '0906000003', 'orders@greenbag.example', N'Hồ Chí Minh', 1),
(N'Khánh Hòa Textile', N'Trần Hải Nam', '0906000004', 'contact@khanhhoa.example', N'Khánh Hòa', 1);

INSERT INTO dbo.Import_Receipt
    (receipt_code, supplier_id, user_id, total_amount, created_at, status,
     note, vendor_reference, confirmed_by, confirmed_at)
VALUES
('IR-20260718-003', 4, (SELECT id FROM dbo.[User] WHERE username = 'staff02'),
 8400000, '2026-07-18 08:15:00', 'CONFIRMED',
 N'Women basic collection replenishment', N'DA-0718-003',
 1, '2026-07-18 09:00:00'),
('IR-20260719-004', 5, (SELECT id FROM dbo.[User] WHERE username = 'staff02'),
 9850000, '2026-07-19 10:20:00', 'CONFIRMED',
 N'Bottoms and seasonal stock', N'AP-0719-004',
 1, '2026-07-19 11:00:00'),
('IR-20260719-005', 6, (SELECT id FROM dbo.[User] WHERE username = 'staff03'),
 8100000, '2026-07-19 13:40:00', 'DRAFT',
 N'Sportswear delivery awaiting review', N'GB-DRAFT-005',
 NULL, NULL),
('IR-20260720-006', 7, (SELECT id FROM dbo.[User] WHERE username = 'staff03'),
 9800000, '2026-07-20 08:30:00', 'CONFIRMED',
 N'Outerwear and knitwear replenishment', N'KH-0720-006',
 2, '2026-07-20 09:10:00');

INSERT INTO dbo.Import_Receipt_Detail
    (import_receipt_id, variant_id, quantity, unit_cost, line_total)
VALUES
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260718-003'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TEE-WOM-BLK-S'), 40, 120000, 4800000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260718-003'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-BLOUSE-BLU-S'), 20, 180000, 3600000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260719-004'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-SKIRT-BLK-S'), 25, 210000, 5250000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260719-004'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-PANTS-CRE-S'), 20, 230000, 4600000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260719-005'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-LEGGING-BLK-S'), 30, 170000, 5100000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260719-005'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-RUNSHORT-BLU-M'), 25, 120000, 3000000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260720-006'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-CARDI-CRE-M'), 20, 220000, 4400000),
((SELECT id FROM dbo.Import_Receipt WHERE receipt_code = 'IR-20260720-006'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-DENIM-BLU-M'), 18, 300000, 5400000);

INSERT INTO dbo.Product_Batch (
    variant_id, batch_code, cost_price, initial_quantity, current_quantity,
    import_receipt_id, import_receipt_detail_id, status, created_at
)
SELECT pv.id, CONCAT('EXT-OPEN-', pv.sku), pv.cost_price,
       CASE pv.sku
           WHEN 'EXP-TEE-WOM-BLK-S' THEN pv.stock_quantity + 2
           WHEN 'EXP-BLOUSE-BLU-S' THEN pv.stock_quantity + 5
           ELSE pv.stock_quantity
       END,
       pv.stock_quantity, NULL, NULL,
       CASE WHEN pv.stock_quantity = 0 THEN 'CLOSED' ELSE 'AVAILABLE' END,
       '2026-07-01 08:00:00'
FROM dbo.Product_Variant pv
WHERE pv.sku LIKE 'EXP-%';

INSERT INTO dbo.Inventory_Log (
    variant_id, user_id, product_name_snapshot, sku_snapshot,
    quantity_before, change_quantity, quantity_after, transaction_type,
    reference_type, reference_id, note, created_at
)
SELECT pv.id, (SELECT id FROM dbo.[User] WHERE username = 'staff02'),
       p.product_name, pv.sku, 0, pv.stock_quantity, pv.stock_quantity,
       'OPENING_BALANCE', 'SYSTEM_SETUP', NULL,
       N'Opening stock for extended demo catalogue', '2026-07-01 08:00:00'
FROM dbo.Product_Variant pv
INNER JOIN dbo.Product p ON p.id = pv.product_id
WHERE pv.sku LIKE 'EXP-%';

INSERT INTO dbo.Stock_Adjustment (
    adjustment_code, adjustment_type, status, reason, created_by,
    approved_by, created_at, approved_at
)
VALUES
('ADJ-20260718-002', 'DAMAGED', 'APPROVED',
 N'Packaging damage found during receiving inspection',
 (SELECT id FROM dbo.[User] WHERE username = 'staff02'), 1,
 '2026-07-18 15:00:00', '2026-07-18 15:20:00'),
('ADJ-20260719-003', 'CORRECTION', 'APPROVED',
 N'Physical count found five additional units',
 (SELECT id FROM dbo.[User] WHERE username = 'staff03'), 1,
 '2026-07-19 16:00:00', '2026-07-19 16:30:00'),
('ADJ-20260720-004', 'DAMAGED', 'DRAFT',
 N'Pending review for stained garment samples',
 (SELECT id FROM dbo.[User] WHERE username = 'staff03'), NULL,
 '2026-07-20 10:00:00', NULL);

INSERT INTO dbo.Stock_Adjustment_Detail (
    adjustment_id, variant_id, quantity_before, change_quantity,
    quantity_after, note
)
VALUES
((SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260718-002'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TEE-WOM-BLK-S'),
 50, -2, 48, N'Two damaged units removed'),
((SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260719-003'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-BLOUSE-BLU-S'),
 30, 5, 35, N'Counted five units missed in the first count'),
((SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260720-004'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-CARDI-CRE-M'),
 21, -1, 20, N'One stained sample pending approval');

INSERT INTO dbo.Inventory_Log (
    variant_id, user_id, product_name_snapshot, sku_snapshot,
    quantity_before, change_quantity, quantity_after, transaction_type,
    reference_type, reference_id, note, created_at
)
VALUES
((SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TEE-WOM-BLK-S'), 1,
 N'Essential Womens Cotton Tee', 'EXP-TEE-WOM-BLK-S',
 50, -2, 48, 'ADJUST_DECREASE', 'STOCK_ADJUSTMENT',
 (SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260718-002'),
 N'Damaged units removed from stock', '2026-07-18 15:20:00'),
((SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-BLOUSE-BLU-S'), 1,
 N'Pleated Office Blouse', 'EXP-BLOUSE-BLU-S',
 30, 5, 35, 'ADJUST_INCREASE', 'STOCK_ADJUSTMENT',
 (SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260719-003'),
 N'Positive count correction', '2026-07-19 16:30:00'),
((SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-CARDI-CRE-M'), 2,
 N'Soft Ribbed Cardigan', 'EXP-CARDI-CRE-M',
 21, -1, 20, 'ADJUST_DECREASE', 'STOCK_ADJUSTMENT',
 (SELECT id FROM dbo.Stock_Adjustment WHERE adjustment_code = 'ADJ-20260720-004'),
 N'Draft adjustment awaiting approval', '2026-07-20 10:00:00');
GO

INSERT INTO dbo.Voucher (
    code, title, discount_type, discount_value, max_discount_amount,
    min_order_value, start_date, end_date, usage_limit, used_count,
    limit_per_user, terminate_reason, category_id
)
VALUES
('NEWCUSTOMER', N'New customer 70,000 VND off', 'FIXED_AMOUNT', 70000, 70000, 300000,
 '2026-07-01', '2026-12-31 23:59:59', 500, 1, 1, NULL, NULL),
('WOMEN20', N'20% womens collection', 'PERCENTAGE', 20, 100000, 400000,
 '2026-07-01', '2026-10-31 23:59:59', 300, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'ao-nu')),
('SPORT10', N'10% sportswear discount', 'PERCENTAGE', 10, 50000, 250000,
 '2026-07-01', '2026-09-30 23:59:59', 400, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'do-the-thao')),
('FLASH100', N'100,000 VND flash sale', 'FIXED_AMOUNT', 100000, 100000, 600000,
 '2026-07-15', '2026-07-31 23:59:59', 100, 1, 1, NULL, NULL),
('VIP15', N'15% VIP member discount', 'PERCENTAGE', 15, 150000, 700000,
 '2026-01-01', '2026-12-31 23:59:59', 1000, 1, 1, NULL, NULL),
('ACCESSORY50', N'50,000 VND accessory offer', 'FIXED_AMOUNT', 50000, 50000, 200000,
 '2026-06-01', '2026-12-31 23:59:59', 300, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'phu-kien'));
GO

INSERT INTO dbo.Cart (user_id, variant_id, quantity)
SELECT u.id, pv.id, v.quantity
FROM (VALUES
    ('customer03', 'EXP-TEE-WOM-WHT-M', 2),
    ('customer04', 'EXP-SKIRT-BEI-M', 1),
    ('customer05', 'EXP-PANTS-BLK-S', 1),
    ('customer06', 'EXP-LEGGING-GRY-M', 2),
    ('customer07', 'EXP-CARDI-GRY-L', 1),
    ('customer08', 'EXP-TOTE-NAT-FREE', 1)
) v(username, sku, quantity)
INNER JOIN dbo.[User] u ON u.username = v.username
INNER JOIN dbo.Product_Variant pv ON pv.sku = v.sku;

INSERT INTO dbo.Wishlist (user_id, product_id, variant_id)
SELECT u.id, p.id, pv.id
FROM (VALUES
    ('customer03', 'ao-so-mi-nu-co-pleat', 'EXP-BLOUSE-PNK-M'),
    ('customer04', 'ao-khoac-denim-nu-co-dien', 'EXP-DENIM-BLU-L'),
    ('customer05', 'ao-polo-nu-pique', 'EXP-POLO-WHT-S'),
    ('customer06', 'ao-mua-nhe-gap-gon', 'EXP-RAIN-BLK-M'),
    ('customer07', 'mu-luoi-trai-basic', 'EXP-CAP-BEI-FREE'),
    ('customer08', 'chan-vay-midi-xep-ly', 'EXP-SKIRT-BLK-S')
) v(username, slug, sku)
INNER JOIN dbo.[User] u ON u.username = v.username
INNER JOIN dbo.Product p ON p.slug = v.slug
INNER JOIN dbo.Product_Variant pv ON pv.sku = v.sku;
GO

/* =========================================================================
   XVIII. EXTENDED ORDERS, PAYMENTS, RETURNS AND FEEDBACK
   ========================================================================= */

INSERT INTO dbo.Shipment
    (carrier_name, shipping_status, tracking_code, shipping_cost,
     estimated_delivery_time)
VALUES
(N'GHN', 'DELIVERED', 'GHN-20260718-011', 30000, '2026-07-20 17:00:00'),
(N'GHTK', 'DELIVERED', 'GHTK-20260718-012', 30000, '2026-07-21 17:00:00'),
(N'Viettel Post', 'SHIPPING', 'VTP-20260719-013', 30000, '2026-07-22 17:00:00'),
(N'GHN', 'CONFIRMED', 'GHN-20260719-014', 30000, '2026-07-23 17:00:00'),
(N'GHTK', 'DELIVERED', 'GHTK-20260719-015', 30000, '2026-07-21 17:00:00'),
(N'Internal Delivery', 'PENDING_PICKUP', NULL, 20000, '2026-07-23 17:00:00'),
(N'GHN', 'DELIVERED', 'GHN-20260720-017', 30000, '2026-07-22 17:00:00'),
(N'GHTK', 'SHIPPING', 'GHTK-20260720-018', 30000, '2026-07-24 17:00:00'),
(N'Viettel Post', 'DELIVERED', 'VTP-20260720-019', 30000, '2026-07-22 17:00:00'),
(N'GHN', 'PENDING_PICKUP', 'GHN-20260720-020', 30000, '2026-07-24 17:00:00'),
(N'GHTK', 'DELIVERED', 'GHTK-20260720-021', 30000, '2026-07-23 17:00:00'),
(N'Internal Delivery', 'FAILED', NULL, 20000, NULL);

INSERT INTO dbo.[Order] (
    order_code, user_id, voucher_id, shipment_id, recipient_name,
    recipient_phone, ward_id, address_detail, total_items_price,
    discount_amount, shipping_fee, total_payment, order_status, note,
    created_at, updated_at
)
VALUES
('ORD-20260718-011', (SELECT id FROM dbo.[User] WHERE username = 'customer03'),
 (SELECT id FROM dbo.Voucher WHERE code = 'NEWCUSTOMER'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260718-011'),
 N'Nguyễn Minh Anh', '0905000003', '20194', N'12 Trần Phú',
 498000, 70000, 30000, 458000, 'DELIVERED', N'New customer first order',
 '2026-07-18 09:10:00', '2026-07-20 16:00:00'),
('ORD-20260718-012', (SELECT id FROM dbo.[User] WHERE username = 'customer04'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260718-012'),
 N'Trần Quốc Bảo', '0905000004', '20305', N'88 Võ Văn Kiệt',
 329000, 0, 30000, 359000, 'DELIVERED', N'Blouse order',
 '2026-07-18 11:20:00', '2026-07-21 16:00:00'),
('ORD-20260719-013', (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.Voucher WHERE code = 'WOMEN20'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'VTP-20260719-013'),
 N'Lê Khánh Vy', '0905000005', '22366', N'25 Nguyễn Thiện Thuật',
 549000, 109800, 30000, 469200, 'SHIPPING', N'Womens collection campaign order',
 '2026-07-19 08:40:00', '2026-07-20 13:00:00'),
('ORD-20260719-014', (SELECT id FROM dbo.[User] WHERE username = 'customer06'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260719-014'),
 N'Phan Đức Huy', '0905000006', '22420', N'09 Hùng Vương',
 549000, 0, 30000, 579000, 'CONFIRMED', N'Waiting for carrier pickup',
 '2026-07-19 09:30:00', '2026-07-19 10:00:00'),
('ORD-20260719-015', (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.Voucher WHERE code = 'SPORT10'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260719-015'),
 N'Vũ Ngọc Hà', '0905000007', '20200', N'41 Bạch Đằng',
 798000, 50000, 30000, 778000, 'DELIVERED', N'Two training leggings',
 '2026-07-19 12:15:00', '2026-07-21 14:00:00'),
('ORD-20260719-016', (SELECT id FROM dbo.[User] WHERE username = 'customer08'),
 NULL, (SELECT id FROM dbo.Shipment WHERE id = 16),
 N'Bùi Gia Hân', '0905000008', '20314', N'66 Ngô Quyền',
 259000, 0, 20000, 279000, 'PENDING', N'Awaiting order confirmation',
 '2026-07-19 14:00:00', '2026-07-19 14:00:00'),
('ORD-20260720-017', (SELECT id FROM dbo.[User] WHERE username = 'customer03'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260720-017'),
 N'Nguyễn Minh Anh', '0905000003', '20194', N'12 Trần Phú',
 459000, 0, 30000, 489000, 'DELIVERED', N'Cardigan for office layering',
 '2026-07-20 08:10:00', '2026-07-22 15:00:00'),
('ORD-20260720-018', (SELECT id FROM dbo.[User] WHERE username = 'customer04'),
 (SELECT id FROM dbo.Voucher WHERE code = 'VIP15'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260720-018'),
 N'Trần Quốc Bảo', '0905000004', '20305', N'88 Võ Văn Kiệt',
 1298000, 150000, 30000, 1178000, 'SHIPPING', N'VIP denim jacket order',
 '2026-07-20 09:30:00', '2026-07-20 12:00:00'),
('ORD-20260720-019', (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.Voucher WHERE code = 'ACCESSORY50'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'VTP-20260720-019'),
 N'Lê Khánh Vy', '0905000005', '22366', N'25 Nguyễn Thiện Thuật',
 358000, 50000, 30000, 338000, 'DELIVERED', N'Cap and tote set',
 '2026-07-20 10:10:00', '2026-07-22 12:00:00'),
('ORD-20260720-020', (SELECT id FROM dbo.[User] WHERE username = 'customer06'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260720-020'),
 N'Phan Đức Huy', '0905000006', '22420', N'09 Hùng Vương',
 229000, 0, 30000, 259000, 'CONFIRMED', N'Canvas tote order',
 '2026-07-20 11:20:00', '2026-07-20 11:30:00'),
('ORD-20260720-021', (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.Voucher WHERE code = 'FLASH100'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260720-021'),
 N'Vũ Ngọc Hà', '0905000007', '20200', N'41 Bạch Đằng',
 399000, 100000, 30000, 329000, 'DELIVERED', N'Pique polo order',
 '2026-07-20 12:00:00', '2026-07-23 15:00:00'),
('ORD-20260720-022', (SELECT id FROM dbo.[User] WHERE username = 'customer08'),
 NULL, (SELECT id FROM dbo.Shipment WHERE id = 22),
 N'Bùi Gia Hân', '0905000008', '20314', N'66 Ngô Quyền',
 849000, 0, 20000, 869000, 'CANCELLED', N'Cancelled after delivery estimate changed',
 '2026-07-20 13:30:00', '2026-07-20 14:00:00');

INSERT INTO dbo.Order_Detail (
    order_id, variant_id, product_name_snapshot, variant_attributes_snapshot,
    quantity, price
)
VALUES
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260718-011'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TEE-WOM-BLK-S'),
 N'Essential Womens Cotton Tee', N'Color: Black, Size: S', 2, 249000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260718-012'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-BLOUSE-BLU-S'),
 N'Pleated Office Blouse', N'Color: Blue, Size: S', 1, 329000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-013'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-SKIRT-BLK-S'),
 N'Flowy Midi Skirt', N'Color: Black, Size: S', 1, 549000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-014'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-PANTS-CRE-S'),
 N'High-Waist Wide-Leg Pants', N'Color: Cream, Size: S', 1, 549000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-015'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-LEGGING-BLK-S'),
 N'Everyday Training Leggings', N'Color: Black, Size: S', 2, 399000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-016'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-RUNSHORT-BLU-M'),
 N'Light Running Shorts', N'Color: Blue, Size: M', 1, 259000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-017'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-CARDI-CRE-M'),
 N'Soft Ribbed Cardigan', N'Color: Cream, Size: M', 1, 459000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-018'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-DENIM-BLU-M'),
 N'Vintage Denim Jacket', N'Color: Denim Blue, Size: M', 2, 649000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-019'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-CAP-BEI-FREE'),
 N'Classic Baseball Cap', N'Color: Beige, Size: Free Size', 1, 179000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-019'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TOTE-NAT-FREE'),
 N'Natural Canvas Tote', N'Color: Natural, Size: Free Size', 1, 229000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-020'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-TOTE-BLK-FREE'),
 N'Natural Canvas Tote', N'Color: Black, Size: Free Size', 1, 229000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-021'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-POLO-PNK-S'),
 N'Fine Pique Womens Polo', N'Color: Pink, Size: S', 1, 399000),
((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-022'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-RAIN-BLU-S'),
 N'Packable Rain Jacket', N'Color: Blue, Size: S', 1, 849000);

INSERT INTO dbo.Payment (
    order_id, payment_method, payment_status, amount,
    transaction_reference, payment_date
)
SELECT o.id, v.payment_method, v.payment_status, o.total_payment,
       v.transaction_reference, v.payment_date
FROM dbo.[Order] o
INNER JOIN (VALUES
    ('ORD-20260718-011', 'VNPAY', 'PAID', 'TXN-EXT-011', '2026-07-18 09:15:00'),
    ('ORD-20260718-012', 'COD', 'PAID', NULL, '2026-07-21 16:00:00'),
    ('ORD-20260719-013', 'BANK_TRANSFER', 'PAID', 'TXN-EXT-013', '2026-07-19 08:45:00'),
    ('ORD-20260719-014', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260719-015', 'VNPAY', 'PAID', 'TXN-EXT-015', '2026-07-19 12:20:00'),
    ('ORD-20260719-016', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260720-017', 'BANK_TRANSFER', 'PAID', 'TXN-EXT-017', '2026-07-20 08:15:00'),
    ('ORD-20260720-018', 'VNPAY', 'PAID', 'TXN-EXT-018', '2026-07-20 09:35:00'),
    ('ORD-20260720-019', 'COD', 'PAID', NULL, '2026-07-22 12:00:00'),
    ('ORD-20260720-020', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260720-021', 'BANK_TRANSFER', 'PAID', 'TXN-EXT-021', '2026-07-20 12:05:00'),
    ('ORD-20260720-022', 'VNPAY', 'REFUNDED', 'TXN-EXT-022', '2026-07-20 14:05:00')
) v(order_code, payment_method, payment_status, transaction_reference, payment_date)
ON o.order_code = v.order_code;

INSERT INTO dbo.Voucher_Usage
    (voucher_id, user_id, order_id, discount_amount, used_at)
VALUES
((SELECT id FROM dbo.Voucher WHERE code = 'NEWCUSTOMER'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer03'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260718-011'), 70000, '2026-07-18 09:10:00'),
((SELECT id FROM dbo.Voucher WHERE code = 'WOMEN20'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-013'), 109800, '2026-07-19 08:40:00'),
((SELECT id FROM dbo.Voucher WHERE code = 'SPORT10'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-015'), 50000, '2026-07-19 12:15:00'),
((SELECT id FROM dbo.Voucher WHERE code = 'VIP15'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer04'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-018'), 150000, '2026-07-20 09:30:00'),
((SELECT id FROM dbo.Voucher WHERE code = 'ACCESSORY50'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-019'), 50000, '2026-07-20 10:10:00'),
((SELECT id FROM dbo.Voucher WHERE code = 'FLASH100'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-021'), 100000, '2026-07-20 12:00:00');
GO

-- Four return/exchange cases cover pending, approved, completed and rejected.
INSERT INTO dbo.Return_Request (
    request_code, order_id, customer_id, request_type, reason,
    customer_note, staff_note, refund_amount, status, requested_at,
    reviewed_by, reviewed_at, received_by, received_at,
    refund_requested_by, refund_requested_at, refunded_by, refunded_at
)
VALUES
('RET-20260712-001',
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260705-010'),
 (SELECT id FROM dbo.[User] WHERE username = 'khachhang02'),
 'RETURN', 'WRONG_SIZE', N'Size is too small after trying it on.',
 N'Return accepted after inspection.', 340000, 'COMPLETED',
 '2026-07-08 09:00:00', 2, '2026-07-08 10:00:00', 2, '2026-07-10 14:00:00',
 2, '2026-07-11 09:00:00', 1, '2026-07-12 10:30:00'),
('RET-20260718-002',
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260405-004'),
 (SELECT id FROM dbo.[User] WHERE username = 'khachhang02'),
 'EXCHANGE', 'DEFECTIVE', N'Button is loose on arrival.',
 N'Awaiting returned item from customer.', 0, 'APPROVED',
 '2026-07-18 13:00:00', 2, '2026-07-18 14:00:00', NULL, NULL,
 NULL, NULL, NULL, NULL),
('RET-20260720-003',
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260719-015'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 'RETURN', 'CHANGE_OF_MIND', N'Customer requests a different color.',
 NULL, 798000, 'PENDING',
 '2026-07-20 17:00:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('RET-20260720-004',
 (SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260720-022'),
 (SELECT id FROM dbo.[User] WHERE username = 'customer08'),
 'RETURN', 'LATE_DELIVERY', N'Order was cancelled before dispatch.',
 N'Not eligible because the order was cancelled.', 0, 'REJECTED',
 '2026-07-20 15:00:00', 2, '2026-07-20 15:20:00', NULL, NULL,
 NULL, NULL, NULL, NULL);

INSERT INTO dbo.Return_Request_Item (
    return_request_id, order_detail_id, variant_id, product_name_snapshot,
    variant_attributes_snapshot, quantity, unit_price
)
VALUES
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260712-001'),
 (SELECT od.id FROM dbo.Order_Detail od INNER JOIN dbo.[Order] o ON o.id = od.order_id WHERE o.order_code = 'ORD-20260705-010'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'RT-DENIM-BLU-M'),
 N'Rugged Denim Shirt', N'Color: Denim Blue, Size: M', 1, 340000),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260718-002'),
 (SELECT od.id FROM dbo.Order_Detail od INNER JOIN dbo.[Order] o ON o.id = od.order_id WHERE o.order_code = 'ORD-20260405-004'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'RT-BLZR-BLK-M'),
 N'Korean-Style Mens Blazer', N'Color: Black, Size: M', 1, 680000),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260720-003'),
 (SELECT od.id FROM dbo.Order_Detail od INNER JOIN dbo.[Order] o ON o.id = od.order_id WHERE o.order_code = 'ORD-20260719-015'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-LEGGING-BLK-S'),
 N'Everyday Training Leggings', N'Color: Black, Size: S', 2, 399000),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260720-004'),
 (SELECT od.id FROM dbo.Order_Detail od INNER JOIN dbo.[Order] o ON o.id = od.order_id WHERE o.order_code = 'ORD-20260720-022'),
 (SELECT id FROM dbo.Product_Variant WHERE sku = 'EXP-RAIN-BLU-S'),
 N'Packable Rain Jacket', N'Color: Blue, Size: S', 1, 849000);

INSERT INTO dbo.Return_Request_History
    (return_request_id, old_status, new_status, note, changed_by, changed_at)
VALUES
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260712-001'),
 NULL, 'PENDING', N'Return request submitted by customer', 5, '2026-07-08 09:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260712-001'),
 'PENDING', 'APPROVED', N'Return approved after document review', 2, '2026-07-08 10:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260712-001'),
 'APPROVED', 'RECEIVED', N'Warehouse received the returned item', 2, '2026-07-10 14:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260712-001'),
 'RECEIVED', 'COMPLETED', N'Refund completed through bank transfer', 1, '2026-07-12 10:30:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260718-002'),
 NULL, 'PENDING', N'Exchange request submitted', 5, '2026-07-18 13:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260718-002'),
 'PENDING', 'APPROVED', N'Exchange approved by staff', 2, '2026-07-18 14:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260720-003'),
 NULL, 'PENDING', N'Return request is waiting for staff review', 10, '2026-07-20 17:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260720-004'),
 NULL, 'PENDING', N'Return request submitted for cancelled order', 11, '2026-07-20 15:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260720-004'),
 'PENDING', 'REJECTED', N'Cancelled orders cannot be returned', 2, '2026-07-20 15:20:00');
GO

INSERT INTO dbo.Feedback (
    user_id, product_id, order_id, rating, comment, status,
    admin_response, response_by, responded_at, created_at
)
SELECT u.id, p.id, o.id, v.rating, v.comment, v.status,
       v.admin_response, CASE WHEN v.admin_response IS NULL THEN NULL ELSE 2 END,
       v.responded_at, v.created_at
FROM (VALUES
    ('customer03', 'ao-thun-nu-cotton-co-ban', 'ORD-20260718-011', 5, N'Fabric is soft and the fit is flattering.', 1, N'Thank you for sharing your feedback.', '2026-07-20 09:00:00', '2026-07-20 08:30:00'),
    ('customer04', 'ao-so-mi-nu-co-pleat', 'ORD-20260718-012', 4, N'Beautiful pleats and good packaging.', 1, NULL, NULL, '2026-07-21 19:00:00'),
    ('customer07', 'quan-legging-the-thao-nu', 'ORD-20260719-015', 5, N'Comfortable for a long gym session.', 1, N'We are glad you enjoy the sportswear.', '2026-07-22 10:00:00', '2026-07-22 09:00:00'),
    ('customer03', 'ao-cardigan-len-gan', 'ORD-20260720-017', 4, N'Warm and easy to layer.', 1, NULL, NULL, '2026-07-22 18:00:00'),
    ('customer05', 'mu-luoi-trai-basic', 'ORD-20260720-019', 3, N'Color is slightly lighter than the photo.', 1, NULL, NULL, '2026-07-22 18:30:00'),
    ('customer07', 'ao-polo-nu-pique', 'ORD-20260720-021', 5, N'Excellent collar and breathable fabric.', 1, N'Thank you for the detailed review.', '2026-07-23 17:00:00', '2026-07-23 16:00:00')
) v(username, slug, order_code, rating, comment, status, admin_response, responded_at, created_at)
INNER JOIN dbo.[User] u ON u.username = v.username
INNER JOIN dbo.Product p ON p.slug = v.slug
INNER JOIN dbo.[Order] o ON o.order_code = v.order_code;
GO

INSERT INTO dbo.Activity_Log
    (user_id, action_type, description, ip_address, created_at)
VALUES
((SELECT id FROM dbo.[User] WHERE username = 'staff02'), 'LOGIN', N'Staff signed in to inventory workspace', '10.0.0.12', '2026-07-18 08:00:00'),
((SELECT id FROM dbo.[User] WHERE username = 'staff03'), 'LOGIN', N'Staff signed in to order workspace', '10.0.0.13', '2026-07-19 09:00:00'),
((SELECT id FROM dbo.[User] WHERE username = 'staff02'), 'IMPORT_RECEIPT_CONFIRM', N'Confirmed receipt IR-20260718-003', '10.0.0.12', '2026-07-18 09:00:00'),
((SELECT id FROM dbo.[User] WHERE username = 'staff03'), 'IMPORT_RECEIPT_CREATE', N'Created draft receipt IR-20260719-005', '10.0.0.13', '2026-07-19 13:40:00'),
((SELECT id FROM dbo.[User] WHERE username = 'staff02'), 'STOCK_ADJUSTMENT_APPROVE', N'Approved adjustment ADJ-20260718-002', '10.0.0.12', '2026-07-18 15:20:00'),
((SELECT id FROM dbo.[User] WHERE username = 'staff03'), 'ORDER_CONFIRM', N'Confirmed order ORD-20260719-014', '10.0.0.13', '2026-07-19 10:00:00'),
((SELECT id FROM dbo.[User] WHERE username = 'admin01'), 'RETURN_APPROVE', N'Approved exchange request RET-20260718-002', '127.0.0.1', '2026-07-18 14:00:00'),
((SELECT id FROM dbo.[User] WHERE username = 'admin01'), 'REPORT_EXPORT', N'Exported July sales report', '127.0.0.1', '2026-07-20 18:00:00');
GO

/* =========================================================================
   XIX. VALIDATION
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

IF (SELECT COUNT(*) FROM dbo.Product_Variant WHERE sku LIKE 'EXP-%') <> 48
BEGIN
    THROW 51004,
        'Seed validation failed: the extended product variants were not inserted completely.',
        1;
END;

IF (
    SELECT COUNT(*)
    FROM dbo.Variant_Attribute_Value vav
    INNER JOIN dbo.Product_Variant pv ON pv.id = vav.variant_id
    WHERE pv.sku LIKE 'EXP-%'
) <> 192
BEGIN
    THROW 51005,
        'Seed validation failed: extended variant attributes are incomplete.',
        1;
END;

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
    (SELECT COUNT(*) FROM dbo.[Order]) AS order_count,
    (SELECT COUNT(*) FROM dbo.Security_Token) AS security_token_count,
    (SELECT COUNT(*) FROM dbo.Return_Request) AS return_request_count,
    (SELECT COUNT(*) FROM dbo.Feedback) AS feedback_count;
GO
