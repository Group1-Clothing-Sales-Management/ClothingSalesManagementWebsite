USE [ClothesShopDB];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

/* =========================================================================
   SEEDED MASTER DATA AND PRODUCTS FROM THE CURRENT PROJECT
   ========================================================================= */

-- =========================================================================
-- 1. ROLES & USERS
-- =========================================================================
INSERT INTO Role (role_name) VALUES
('ADMIN'),
('STAFF'),
('CUSTOMER');

-- Shared bcrypt password for all demo accounts: 123456
INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) VALUES
('admin01',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Văn Admin',   'admin@clothesshop.com', '0911223344', 'ACTIVE', 1),
('admin02',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Nhật Quy',    'quy@gmail.com',         '0911223344', 'ACTIVE', 1),
('staff01',     '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Trần Thị Nhân Viên', 'staff@clothesshop.com', '0922334455', 'ACTIVE', 2),
('quy_nn',      '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Ngọc Quý',    'quynn@gmail.com',       '0933445566', 'ACTIVE', 3),
('khachhang02', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Lê Hoàng Nam',       'namlh@gmail.com',       '0944556677', 'ACTIVE', 3);

INSERT INTO User_Address (
    user_id, recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name, is_default
) VALUES
(4, N'Nguyễn Ngọc Quý',  '0933445566', N'123 3/2 Street',
 '92', N'Thành phố Cần Thơ', '31162', N'Phường Xuân Khánh', 1),
(4, N'Anh Quý (Office)', '0933445566', N'Bitexco Building, Floor 15',
 '79', N'Thành phố Hồ Chí Minh', '26734', N'Phường Bến Nghé', 0),
(5, N'Lê Hoàng Nam',     '0944556677', N'45 Truc Bach Street',
 '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch', 1);

-- =========================================================================
-- 2. BRANDS & CATEGORIES
-- =========================================================================
INSERT INTO Brand (brand_name, slug) VALUES
('Coolmate', 'coolmate'),
('Routine',  'routine'),
('Uniqlo',   'uniqlo');

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'Mens Tops',  'ao-nam',  NULL, N'Tops and shirts for men', 1),
(N'Mens Bottoms','quan-nam', NULL, N'Bottoms and trousers for men', 1);

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'T-Shirts', 'ao-thun-t-shirt', 1, N'Mens crew-neck and V-neck T-shirts', 1),
(N'Shirts',   'ao-so-mi',        1, N'Long-sleeve and short-sleeve shirts', 1),
(N'Mens Jeans','quan-jean-nam',  2, N'Full-length denim jeans for men', 1);

-- =========================================================================
-- 3. PRODUCTS (ID 1-22)
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
-- 4. PRODUCT VARIANTS (SKU) — ID 1-80
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
-- 5. VARIANT COLOR AND SIZE (variant_id 1-80)
-- =========================================================================
UPDATE pv
SET pv.color = variant_data.color,
    pv.size = variant_data.size,
    pv.list_price = COALESCE(pv.list_price, pv.sale_price)
FROM dbo.Product_Variant pv
INNER JOIN (VALUES
    (1, N'Black', N'M'),
    (2, N'Black', N'L'),
    (3, N'White', N'M'),
    (4, N'White', N'L'),
    (5, N'Smoke Gray', N'M'),
    (6, N'Smoke Gray', N'31'),
    (7, N'Black', N'M'),
    (8, N'Black', N'L'),
    (9, N'Navy', N'M'),
    (10, N'Navy', N'L'),
    (11, N'White', N'S'),
    (12, N'White', N'M'),
    (13, N'Gray', N'M'),
    (14, N'Gray', N'L'),
    (15, N'White', N'M'),
    (16, N'White', N'L'),
    (17, N'Navy', N'M'),
    (18, N'Navy', N'XL'),
    (19, N'Black', N'L'),
    (20, N'Black', N'XL'),
    (21, N'Beige', N'L'),
    (22, N'Beige', N'XL'),
    (23, N'Beige', N'M'),
    (24, N'Beige', N'L'),
    (25, N'Brown', N'M'),
    (26, N'Brown', N'L'),
    (27, N'White', N'M'),
    (28, N'White', N'L'),
    (29, N'White', N'XL'),
    (30, N'Blue Stripe', N'M'),
    (31, N'Blue Stripe', N'L'),
    (32, N'Gray Stripe', N'M'),
    (33, N'Gray Stripe', N'L'),
    (34, N'Denim Blue', N'M'),
    (35, N'Denim Blue', N'L'),
    (36, N'Denim Blue', N'XL'),
    (37, N'Black', N'S'),
    (38, N'Black', N'M'),
    (39, N'Black', N'L'),
    (40, N'Blue', N'S'),
    (41, N'Blue', N'M'),
    (42, N'Blue', N'L'),
    (43, N'Smoke Gray', N'S'),
    (44, N'Smoke Gray', N'M'),
    (45, N'Smoke Gray', N'L'),
    (46, N'Dark Blue', N'M'),
    (47, N'Dark Blue', N'L'),
    (48, N'Dark Blue', N'XL'),
    (49, N'Black', N'M'),
    (50, N'Black', N'L'),
    (51, N'Olive', N'M'),
    (52, N'Olive', N'L'),
    (53, N'Gray', N'M'),
    (54, N'Gray', N'L'),
    (55, N'Black', N'M'),
    (56, N'Black', N'XL'),
    (57, N'Beige', N'M'),
    (58, N'Beige', N'L'),
    (59, N'Olive', N'M'),
    (60, N'Olive', N'L'),
    (61, N'Black', N'M'),
    (62, N'Black', N'L'),
    (63, N'White', N'M'),
    (64, N'White', N'L'),
    (65, N'Black', N'M'),
    (66, N'Black', N'L'),
    (67, N'Navy', N'M'),
    (68, N'Navy', N'L'),
    (69, N'Black', N'M'),
    (70, N'Black', N'L'),
    (71, N'Gray', N'M'),
    (72, N'Gray', N'L'),
    (73, N'Cream', N'M'),
    (74, N'Cream', N'L'),
    (75, N'Black', N'M'),
    (76, N'Black', N'L'),
    (77, N'Black', N'M'),
    (78, N'Black', N'L'),
    (79, N'Gray', N'M'),
    (80, N'Gray', N'XL')
) AS variant_data(variant_id, color, size)
    ON variant_data.variant_id = pv.id;
GO

-- =========================================================================
-- 6. PRODUCT IMAGES
-- =========================================================================
INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES
(1, 'p1_main_00.webp', 1, 0),
(2, 'p2_main_00.webp', 1, 0),
(3, 'prod3-main.jpg',  1, 0),
(4, 'prod4-main.jpg',  1, 0),
(5, 'prod5-main.jpg',  1, 0),
(6, 'prod6-main.jpg',  1, 0),
(7, 'p7_main_00.jpg',  1, 0),
(8, 'prod8-main.jpg',  1, 0),
(9, 'prod9-main.jpg',  1, 0),
(10,'prod10-main.jpg', 1, 0),
(11,'p11_main_00.webp', 1, 0),
(12,'prod12-main.jpg', 1, 0),
(13,'prod13-main.jpg', 1, 0),
(14,'prod14-main.jpg', 1, 0),
(15,'p15_main_00.webp', 1, 0),
(16,'prod16-main.jpg', 1, 0),
(17,'prod17-main.jpg', 1, 0),
(18,'prod18-main.jpg', 1, 0),
(19,'prod19-main.jpg', 1, 0),
(20,'prod20-main.jpg', 1, 0),
(21,'prod21-main.jpg', 1, 0),
(22,'prod22-main.jpg', 1, 0);

/* =========================================================================
   VII. PRICE HISTORY SAMPLE
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
   VIII. INVENTORY: SUPPLIERS, RECEIPTS AND BATCHES
   ========================================================================= */

INSERT INTO dbo.Supplier
    (supplier_name, phone, address, status)
VALUES
(N'Việt Tín Textile', '0901000001', N'Ho Chi Minh City', 1),
(N'Minh Anh Garment', '0901000002', N'Bình Dương', 1),
(N'Global Fashion Supply', '0901000003', N'Đồng Nai', 1);

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
-- confirmed receipt below.
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
        ELSE pv.stock_quantity
    END,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
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
        ELSE pv.stock_quantity
    END,
    CASE
        WHEN pv.id = 1 THEN 30
        WHEN pv.id = 5 THEN 10
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
GO

/* =========================================================================
   IX. VOUCHERS
   ========================================================================= */

INSERT INTO dbo.Voucher (
    code, title, discount_type, discount_value,
    max_discount_amount, min_order_value,
    start_date, end_date, usage_limit, used_count,
    limit_per_user, terminate_reason, category_id
)
VALUES
('WELCOME50', N'50.000 ₫ welcome discount', 'FIXED_AMOUNT',
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

/* Build explicit multi-category scope for vouchers inserted above.
   A voucher that used to target a root category keeps all CURRENT active
   children. A voucher that targeted one child keeps only that child. */
INSERT INTO dbo.Voucher_Category_Scope (voucher_id, category_id)
SELECT DISTINCT
       v.id,
       CASE
           WHEN selectedCategory.parent_id IS NULL AND child.id IS NOT NULL
               THEN child.id
           ELSE selectedCategory.id
       END
FROM dbo.Voucher v
INNER JOIN dbo.Category selectedCategory
        ON selectedCategory.id = v.category_id
LEFT JOIN dbo.Category child
       ON selectedCategory.parent_id IS NULL
      AND child.parent_id = selectedCategory.id
      AND child.status = 1
WHERE v.category_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Voucher_Category_Scope existingScope
      WHERE existingScope.voucher_id = v.id
  );

UPDATE v
SET v.category_id = selectedCategory.parent_id
FROM dbo.Voucher v
INNER JOIN dbo.Category selectedCategory
        ON selectedCategory.id = v.category_id
WHERE selectedCategory.parent_id IS NOT NULL;
GO

/* =========================================================================
   X. CART AND WISHLIST
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
   XI. SHIPMENTS, ORDERS, DETAILS AND PAYMENTS
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
    recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name,
    total_items_price, discount_amount, shipping_fee, total_payment,
    order_status, note, created_at, updated_at
)
VALUES
('ORD-20260115-001', 4, 1, 1,
 N'Nguyễn Ngọc Quý', '0933445566', N'123 3/2 Street', '92', N'Thành phố Cần Thơ', '31162', N'Phường Xuân Khánh',
 378000, 50000, 30000, 358000,
 'DELIVERED', N'Completed January order',
 '2026-01-15 10:30:00', '2026-01-17 15:00:00'),

('ORD-20260220-002', 5, NULL, 2,
 N'Lê Hoàng Nam', '0944556677', N'45 Truc Bach Street', '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch',
 450000, 0, 30000, 480000,
 'DELIVERED', N'Completed February order',
 '2026-02-20 14:15:00', '2026-02-22 16:30:00'),

('ORD-20260312-003', 4, 2, 3,
 N'Nguyễn Ngọc Quý', '0933445566', N'123 3/2 Street', '92', N'Thành phố Cần Thơ', '31162', N'Phường Xuân Khánh',
 518000, 30000, 30000, 518000,
 'DELIVERED', N'Completed March order with summer voucher',
 '2026-03-12 09:00:00', '2026-03-14 11:00:00'),

('ORD-20260405-004', 5, NULL, 4,
 N'Lê Hoàng Nam', '0944556677', N'45 Truc Bach Street', '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch',
 680000, 0, 30000, 710000,
 'DELIVERED', N'Completed blazer order',
 '2026-04-05 18:20:00', '2026-04-07 20:00:00'),

('ORD-20260518-005', 4, 3, 5,
 N'Nguyễn Ngọc Quý', '0933445566', N'123 3/2 Street', '92', N'Thành phố Cần Thơ', '31162', N'Phường Xuân Khánh',
 398000, 50000, 30000, 378000,
 'DELIVERED', N'Completed category voucher order',
 '2026-05-18 11:10:00', '2026-05-20 14:00:00'),

('ORD-20260620-006', 5, NULL, 6,
 N'Lê Hoàng Nam', '0944556677', N'45 Truc Bach Street', '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch',
 379000, 0, 30000, 409000,
 'CANCELLED', N'Cancelled before warehouse release',
 '2026-06-20 14:05:00', '2026-06-20 14:40:00'),

('ORD-20260712-007', 4, NULL, 7,
 N'Nguyễn Ngọc Quý', '0933445566', N'Bitexco Building, Floor 15', '79', N'Thành phố Hồ Chí Minh', '26734', N'Phường Bến Nghé',
 560000, 0, 30000, 590000,
 'SHIPPING', N'Currently in transit',
 '2026-07-12 11:45:00', '2026-07-16 13:00:00'),

('ORD-20260714-008', 5, NULL, 8,
 N'Lê Hoàng Nam', '0944556677', N'45 Truc Bach Street', '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch',
 229000, 0, 30000, 259000,
 'CONFIRMED', N'Confirmed and waiting for pickup',
 '2026-07-14 08:30:00', '2026-07-15 09:00:00'),

('ORD-20260716-009', 4, NULL, 9,
 N'Nguyễn Ngọc Quý', '0933445566', N'123 3/2 Street', '92', N'Thành phố Cần Thơ', '31162', N'Phường Xuân Khánh',
 179000, 0, 30000, 209000,
 'PENDING', N'New order waiting for approval',
 '2026-07-16 15:20:00', '2026-07-16 15:20:00'),

('ORD-20260705-010', 5, NULL, 10,
 N'Lê Hoàng Nam', '0944556677', N'45 Truc Bach Street', '01', N'Thành phố Hà Nội', '00010', N'Phường Trúc Bạch',
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
 'COD', 'PAID', 358000, NULL, '2026-01-15 10:35:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260220-002'),
 'COD', 'PAID', 480000, NULL, '2026-02-20 14:20:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260312-003'),
 'COD', 'PAID', 518000, NULL, '2026-03-14 11:00:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260405-004'),
 'COD', 'PAID', 710000, NULL, '2026-04-05 18:25:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260518-005'),
 'COD', 'PAID', 378000, NULL, '2026-05-18 11:15:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260620-006'),
 'COD', 'UNPAID', 409000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260712-007'),
 'COD', 'UNPAID', 590000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260714-008'),
 'COD', 'PAID', 259000, NULL, '2026-07-14 08:35:00'),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260716-009'),
 'COD', 'UNPAID', 209000, NULL, NULL),

((SELECT id FROM dbo.[Order] WHERE order_code = 'ORD-20260705-010'),
 'COD', 'REFUNDED', 370000, NULL, '2026-07-12 10:30:00');

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
   XII. FEEDBACK
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
GO

/* =========================================================================
   XIII. EXTENDED DEMO DATA
   This section intentionally adds a broader dataset for search, filtering,
   inventory, promotion, order and return screens.
   ========================================================================= */

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

INSERT INTO dbo.User_Address (
    user_id, recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name, is_default
)
SELECT
    u.id,
    u.full_name,
    u.phone,
    v.address_detail,
    v.province_code,
    v.province_name,
    v.ward_code,
    v.ward_name,
    1
FROM dbo.[User] u
INNER JOIN (VALUES
    ('customer03', N'12 Trần Phú', '48', N'Thành phố Đà Nẵng', '20194', N'Phường Thạch Thang'),
    ('customer04', N'88 Võ Văn Kiệt', '48', N'Thành phố Đà Nẵng', '20305', N'Phường An Hải Bắc'),
    ('customer05', N'25 Nguyễn Thiện Thuật', '56', N'Tỉnh Khánh Hòa', '22366', N'Phường Lộc Thọ'),
    ('customer06', N'09 Hùng Vương', '56', N'Tỉnh Khánh Hòa', '22420', N'Thị trấn Cam Đức'),
    ('customer07', N'41 Bạch Đằng', '48', N'Thành phố Đà Nẵng', '20200', N'Phường Hải Châu'),
    ('customer08', N'66 Ngô Quyền', '48', N'Thành phố Đà Nẵng', '20314', N'Phường Mân Thái')
) v(username, address_detail, province_code, province_name, ward_code, ward_name)
    ON v.username = u.username;

INSERT INTO dbo.User_Address (
    user_id, recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name, is_default
)
SELECT
    u.id,
    u.full_name,
    u.phone,
    v.address_detail,
    v.province_code,
    v.province_name,
    v.ward_code,
    v.ward_name,
    0
FROM dbo.[User] u
INNER JOIN (VALUES
    ('customer03', N'Apartment A12, Hải Châu', '48', N'Thành phố Đà Nẵng', '20200', N'Phường Hải Châu'),
    ('customer04', N'15 Lê Thánh Tôn', '56', N'Tỉnh Khánh Hòa', '22369', N'Phường Vạn Thạnh'),
    ('customer05', N'Office 3F, Trần Phú', '48', N'Thành phố Đà Nẵng', '20194', N'Phường Thạch Thang'),
    ('customer06', N'20 Phạm Văn Đồng', '48', N'Thành phố Đà Nẵng', '20305', N'Phường An Hải Bắc'),
    ('customer07', N'Khu dân cư Cam Hải Tây', '56', N'Tỉnh Khánh Hòa', '22423', N'Xã Cam Hải Tây'),
    ('customer08', N'10 Tô Hiến Thành', '56', N'Tỉnh Khánh Hòa', '22366', N'Phường Lộc Thọ')
) v(username, address_detail, province_code, province_name, ward_code, ward_name)
    ON v.username = u.username;

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

-- More brands and categories
INSERT INTO dbo.Brand (brand_name, slug) VALUES
(N'Lacoste', 'lacoste'),
(N'Nike', 'nike'),
(N'Adidas', 'adidas'),
(N'Zara', 'zara');

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

-- Forty-eight additional variants with direct color and size values.
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
INSERT INTO dbo.Product_Image (
    product_id, image_url, is_main, sort_order
)
SELECT p.id, image_asset.image_url, 1, 0
FROM (VALUES
    ('ao-thun-nu-cotton-co-ban', 'p23_main_00.webp'),
    ('ao-so-mi-nu-co-pleat',     'p24_main_00.webp'),
    ('chan-vay-midi-xep-ly',     'p25_main_00.webp'),
    ('quan-dai-nu-ong-rong',     'p26_main_00.webp'),
    ('quan-legging-the-thao-nu', 'p27_main_00.webp'),
    ('quan-short-chay-bo-nu',    'p28_main_00.webp'),
    ('ao-cardigan-len-gan',      'p29_main_00.webp'),
    ('ao-khoac-denim-nu-co-dien','p30_main_00.webp'),
    ('mu-luoi-trai-basic',       'p31_main_00.webp'),
    ('tui-vai-canvas-tu-nhien',  'p32_main_00.webp'),
    ('ao-polo-nu-pique',         'p33_main_00.webp'),
    ('ao-mua-nhe-gap-gon',       'p34_main_00.webp')
) AS image_asset(slug, image_url)
INNER JOIN dbo.Product p
    ON p.slug = image_asset.slug;
GO

/* =========================================================================
   VARIANT IMAGE SEED GENERATED FROM upload/product

   The application reads a Variant image by Product_Image.variant_id first.
   SKU is used here instead of hard-coded identity IDs, so the relationship
   remains correct when the database is recreated.
   ========================================================================= */
INSERT INTO dbo.Product_Image (
    product_id, variant_id, color, image_url,
    is_main, sort_order, updated_at
)
SELECT
    pv.product_id,
    pv.id,
    NULL,
    image_seed.image_url,
    1,
    0,
    SYSDATETIME()
FROM (VALUES
    ('CM-TSHIRT-BLK-M', 'p1_v1_m_black_03a189704185.jpg'),
    ('CM-TSHIRT-BLK-L', 'p1_v2_l_black_9cc866213501.jpg'),
    ('CM-TSHIRT-WHT-M', 'p1_v3_m_white_127331c779f4.jpg'),
    ('CM-TSHIRT-WHT-L', 'p1_v4_l_white_5ae3eb4f3ab7.jpg'),
    ('RT-JEAN-BLU-30', 'p2_v5_l_smoke_gray.jpg'),
    ('RT-JEAN-BLU-31', 'p2_v6_s_smoke_gray.jpg'),
    ('CM-SPORT-BLK-M', 'p3_v7_m_black_c5b737852bb7.webp'),
    ('CM-SPORT-BLK-L', 'p3_v8_l_black_cdb3bf868512.webp'),
    ('CM-SPORT-NVY-M', 'p3_v9_m_navy_f2a6b1bb3894.webp'),
    ('CM-SPORT-NVY-L', 'p3_v10_l_navy_f22e3bf198bc.webp'),
    ('CM-CTSHIRT-WHT-S', 'p4_v11_s_white_4876cf12467b.jpg'),
    ('CM-CTSHIRT-WHT-M', 'p4_v12_m_white_17f44282a0d8.jpg'),
    ('CM-CTSHIRT-GRY-M', 'p4_v13_m_gray_095c08936bf1.jpg'),
    ('CM-CTSHIRT-GRY-L', 'p4_v14_l_gray_ad41d7348f07.jpg'),
    ('CM-POLO-WHT-M', 'p5_v15_m_white_d7a3e21a2444.jpg'),
    ('CM-POLO-WHT-L', 'p5_v16_l_white_c4f208c2c7c7.jpg'),
    ('CM-POLO-NVY-M', 'p5_v17_m_navy_5588d83cda1e.jpg'),
    ('CM-POLO-NVY-XL', 'p5_v18_xl_navy_c8ef5e72c019.jpg'),
    ('CM-OVER-BLK-L', 'p6_v19_l_black_cb2041cddaff.jpg'),
    ('CM-OVER-BLK-XL', 'p6_v20_xl_black_3b3c26f24a2a.jpg'),
    ('CM-OVER-BEG-L', 'p6_v21_l_beige_54cdbac85098.jpg'),
    ('CM-OVER-BEG-XL', 'p6_v22_xl_beige_aea9ee7ada0a.jpg'),
    ('RT-LINEN-BEG-M', 'p7_v23_m_beige.jpg'),
    ('RT-LINEN-BEG-L', 'p7_v24_l_beige.jpg'),
    ('RT-LINEN-BRN-M', 'p7_v25_m_brown_172420e4433e.jpg'),
    ('RT-LINEN-BRN-L', 'p7_v26_l_brown_783c01798389.jpg'),
    ('RT-OXF-WHT-M', 'p8_v27_m_white.jpg'),
    ('RT-OXF-WHT-L', 'p8_v28_l_white.jpg'),
    ('RT-OXF-WHT-XL', 'p8_v29_xl_white.jpg'),
    ('UQ-STRIPE-BLU-M', 'p9_v30_m_blue_stripe_682ea4f9ee34.jpg'),
    ('UQ-STRIPE-BLU-L', 'p9_v31_l_blue_stripe_e91fcfb59c29.jpg'),
    ('UQ-STRIPE-GRY-M', 'p9_v32_m_gray_stripe_9e57cdcb9639.jpg'),
    ('UQ-STRIPE-GRY-L', 'p9_v33_l_gray_stripe_557e214ea23b.jpg'),
    ('RT-DENIM-BLU-M', 'p10_v34_m_denim_blue.jpg'),
    ('RT-DENIM-BLU-L', 'p10_v35_l_denim_blue.jpg'),
    ('RT-DENIM-BLU-XL', 'p10_v36_xl_denim_blue.jpg'),
    ('RT-BAGGY-BLK-28', 'p11_v37_xl_black.jpg'),
    ('RT-BAGGY-BLK-30', 'p11_v38_m_black.jpg'),
    ('RT-BAGGY-BLK-32', 'p11_v39_s_black.jpg'),
    ('RT-RIP-BLU-28', 'p12_v40_s_blue_8d30f655dc06.jpg'),
    ('RT-RIP-BLU-30', 'p12_v41_m_blue_8f1f1d637898.jpg'),
    ('RT-RIP-BLU-32', 'p12_v42_l_blue_1dbc7d04f55c.jpg'),
    ('UQ-REG-DBL-30', 'p14_v46_l_dark_blue.jpg'),
    ('UQ-REG-DBL-32', 'p14_v47_m_dark_blue.jpg'),
    ('UQ-REG-DBL-34', 'p14_v48_s_dark_blue.jpg'),
    ('UQ-WIND-BLK-M', 'p15_v49_m_black.jpg'),
    ('UQ-WIND-BLK-L', 'p15_v50_l_black.jpg'),
    ('UQ-WIND-OLV-M', 'p15_v51_m_olive_f4e2c867b4f5.jpg'),
    ('UQ-WIND-OLV-L', 'p15_v52_l_olive_cdac6efc5c81.jpg'),
    ('CM-HOOD-GRY-M', 'p16_v53_m_gray.jpg'),
    ('CM-HOOD-GRY-L', 'p16_v54_l_gray_22045f0e318c.jpg'),
    ('CM-HOOD-BLK-M', 'p16_v55_m_black_222da5c40fa1.jpg'),
    ('CM-HOOD-BLK-XL', 'p16_v56_xl_black_bc1b0921140f.jpg'),
    ('RT-SHORT-BEG-M', 'p17_v57_m_beige_4a20ca7f54d3.jpg'),
    ('RT-SHORT-BEG-L', 'p17_v58_l_beige_d2c0ee8db4a7.jpg'),
    ('RT-SHORT-OLV-M', 'p17_v59_m_olive_c7b0df5005a0.jpg'),
    ('RT-SHORT-OLV-L', 'p17_v60_l_olive_6c44a88702ed.jpg'),
    ('CM-TANK-BLK-M', 'p18_v61_m_black_82fcbc70950f.jpg'),
    ('CM-TANK-BLK-L', 'p18_v62_l_black_dc04104ebbd5.jpg'),
    ('CM-TANK-WHT-M', 'p18_v63_m_white_df7457933f94.jpg'),
    ('CM-TANK-WHT-L', 'p18_v64_l_white_426abbc69791.jpg'),
    ('RT-TROU-BLK-30', 'p19_v65_m_black_eb2d616b1746.jpg'),
    ('RT-TROU-BLK-32', 'p19_v66_l_black_e8dce44c2cc8.jpg'),
    ('RT-TROU-NVY-30', 'p19_v67_m_navy_bb1b7eb91358.jpg'),
    ('RT-TROU-NVY-32', 'p19_v68_l_navy_9fec18d033ad.jpg'),
    ('RT-BLZR-BLK-M', 'p20_v69_m_black_fe46cf31ee83.jpg'),
    ('RT-BLZR-BLK-L', 'p20_v70_l_black_a8371b618f87.jpg'),
    ('RT-BLZR-GRY-M', 'p20_v71_m_gray_d8b94bf5616c.jpg'),
    ('RT-BLZR-GRY-L', 'p20_v72_l_gray_79c70733c8a2.jpg'),
    ('UQ-KNIT-CRM-M', 'p21_v73_m_cream_a411400145df.webp'),
    ('UQ-KNIT-CRM-L', 'p21_v74_l_cream_cc755ebd8d1c.webp'),
    ('CM-JOG-BLK-M', 'p22_v77_m_black_307e0925ab42.jpg'),
    ('CM-JOG-BLK-L', 'p22_v78_l_black_99c7240961a9.jpg'),
    ('EXP-TEE-WOM-BLK-S', 'p23_v81_s_black.webp'),
    ('EXP-TEE-WOM-BLK-M', 'p23_v82_m_black.webp'),
    ('EXP-TEE-WOM-WHT-S', 'p23_v83_s_white_7c9686673deb.webp'),
    ('EXP-TEE-WOM-WHT-M', 'p23_v84_m_white_876eec032c21.webp'),
    ('EXP-BLOUSE-PNK-S', 'p24_v87_s_pink_488dbaef5ac3.webp'),
    ('EXP-BLOUSE-PNK-M', 'p24_v88_m_pink_0f84a9dc1a8a.webp'),
    ('EXP-SKIRT-BLK-S', 'p25_v89_s_black_b3ef0a960e05.webp'),
    ('EXP-SKIRT-BLK-M', 'p25_v90_m_black_94ddd432ed19.webp'),
    ('EXP-SKIRT-BEI-S', 'p25_v91_s_beige_f30fbc6fdf83.webp'),
    ('EXP-SKIRT-BEI-M', 'p25_v92_m_beige_e4cb9c24254e.webp'),
    ('EXP-PANTS-CRE-S', 'p26_v93_s_cream_4c975083b80a.webp'),
    ('EXP-PANTS-CRE-M', 'p26_v94_m_cream_b446462fc5f9.webp'),
    ('EXP-PANTS-BLK-S', 'p26_v95_s_black.webp'),
    ('EXP-PANTS-BLK-M', 'p26_v96_m_black.webp'),
    ('EXP-LEGGING-BLK-S', 'p27_v97_s_black.webp'),
    ('EXP-LEGGING-BLK-M', 'p27_v98_m_black.webp'),
    ('EXP-LEGGING-GRY-S', 'p27_v99_s_gray_80506c44b639.webp'),
    ('EXP-LEGGING-GRY-M', 'p27_v100_m_gray_119f69150013.webp'),
    ('EXP-RUNSHORT-BLU-M', 'p28_v101_m_blue_0f26956fa3ab.webp'),
    ('EXP-RUNSHORT-BLU-L', 'p28_v102_l_blue_e94bdb06e992.webp'),
    ('EXP-RUNSHORT-BLK-M', 'p28_v103_m_black_ebdb050a6445.webp'),
    ('EXP-RUNSHORT-BLK-L', 'p28_v104_l_black_b8840ccfbf9c.webp'),
    ('EXP-CARDI-CRE-M', 'p29_v105_m_cream_2f78f94a9239.webp'),
    ('EXP-CARDI-CRE-L', 'p29_v106_l_cream_dd57c77d91ea.webp'),
    ('EXP-CARDI-GRY-M', 'p29_v107_m_gray.webp'),
    ('EXP-CARDI-GRY-L', 'p29_v108_l_gray.jpg'),
    ('EXP-DENIM-BLU-M', 'p30_v109_m_denim_blue_fa295a069313.jpg'),
    ('EXP-DENIM-BLU-L', 'p30_v110_l_denim_blue_bcf888bcbd25.jpg'),
    ('EXP-DENIM-BLK-M', 'p30_v111_m_black_5d1f57556e0a.webp'),
    ('EXP-DENIM-BLK-L', 'p30_v112_l_black_419aeb5a0e93.webp'),
    ('EXP-CAP-BLK-FREE', 'p31_v113_free_size_black.webp'),
    ('EXP-CAP-WHT-FREE', 'p31_v114_free_size_white.webp'),
    ('EXP-CAP-BEI-FREE', 'p31_v115_free_size_beige.webp'),
    ('EXP-CAP-NVY-FREE', 'p31_v116_s_navy_484b2462809d.webp'),
    ('EXP-TOTE-BLK-FREE', 'p32_v118_s_black.webp'),
    ('EXP-TOTE-RED-FREE', 'p32_v119_free_size_red.webp'),
    ('EXP-TOTE-GRN-FREE', 'p32_v120_s_green.webp'),
    ('EXP-POLO-PNK-S', 'p33_v121_s_pink.webp'),
    ('EXP-POLO-PNK-M', 'p33_v122_m_pink.webp'),
    ('EXP-POLO-WHT-S', 'p33_v123_s_white.webp'),
    ('EXP-POLO-WHT-M', 'p33_v124_m_white.webp'),
    ('EXP-RAIN-BLU-S', 'p34_v125_s_blue_8e62ad82aead.webp'),
    ('EXP-RAIN-BLU-M', 'p34_v126_m_blue_63ec2c5638f1.webp'),
    ('EXP-RAIN-BLK-S', 'p34_v127_s_black_99d26d4d1833.webp'),
    ('EXP-RAIN-BLK-M', 'p34_v128_m_black_3a55be7e73c8.webp')
) AS image_seed(sku, image_url)
INNER JOIN dbo.Product_Variant pv
    ON pv.sku = image_seed.sku
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Product_Image existing_image
    WHERE existing_image.variant_id = pv.id
      AND existing_image.is_main = 1
);
/* END VARIANT IMAGE SEED */
GO

/* =========================================================================
   XIV. EXTENDED INVENTORY, PROMOTIONS AND SHOPPING DATA
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
    (supplier_name, phone, address, status)
VALUES
(N'Đông Á Fashion Materials', '0906000001', N'Đà Nẵng', 1),
(N'An Phú Sportswear', '0906000002', N'Bình Dương', 1),
(N'Green Bag Workshop', '0906000003', N'Hồ Chí Minh', 1),
(N'Khánh Hòa Textile', '0906000004', N'Khánh Hòa', 1);

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
       pv.stock_quantity,
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
GO

INSERT INTO dbo.Voucher (
    code, title, discount_type, discount_value, max_discount_amount,
    min_order_value, start_date, end_date, usage_limit, used_count,
    limit_per_user, terminate_reason, category_id
)
VALUES
('NEWCUSTOMER', N'New customer 70.000 ₫ off', 'FIXED_AMOUNT', 70000, 70000, 300000,
 '2026-07-01', '2026-12-31 23:59:59', 500, 1, 1, NULL, NULL),
('WOMEN20', N'20% womens collection', 'PERCENTAGE', 20, 100000, 400000,
 '2026-07-01', '2026-10-31 23:59:59', 300, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'ao-nu')),
('SPORT10', N'10% sportswear discount', 'PERCENTAGE', 10, 50000, 250000,
 '2026-07-01', '2026-09-30 23:59:59', 400, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'do-the-thao')),
('FLASH100', N'100.000 ₫ flash sale', 'FIXED_AMOUNT', 100000, 100000, 600000,
 '2026-07-15', '2026-07-31 23:59:59', 100, 1, 1, NULL, NULL),
('VIP15', N'15% VIP member discount', 'PERCENTAGE', 15, 150000, 700000,
 '2026-01-01', '2026-12-31 23:59:59', 1000, 1, 1, NULL, NULL),
('ACCESSORY50', N'50.000 ₫ accessory offer', 'FIXED_AMOUNT', 50000, 50000, 200000,
 '2026-06-01', '2026-12-31 23:59:59', 300, 1, 1, NULL,
 (SELECT id FROM dbo.Category WHERE slug = 'phu-kien'));
GO

/* Build explicit multi-category scope for vouchers inserted above.
   A voucher that used to target a root category keeps all CURRENT active
   children. A voucher that targeted one child keeps only that child. */
INSERT INTO dbo.Voucher_Category_Scope (voucher_id, category_id)
SELECT DISTINCT
       v.id,
       CASE
           WHEN selectedCategory.parent_id IS NULL AND child.id IS NOT NULL
               THEN child.id
           ELSE selectedCategory.id
       END
FROM dbo.Voucher v
INNER JOIN dbo.Category selectedCategory
        ON selectedCategory.id = v.category_id
LEFT JOIN dbo.Category child
       ON selectedCategory.parent_id IS NULL
      AND child.parent_id = selectedCategory.id
      AND child.status = 1
WHERE v.category_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Voucher_Category_Scope existingScope
      WHERE existingScope.voucher_id = v.id
  );

UPDATE v
SET v.category_id = selectedCategory.parent_id
FROM dbo.Voucher v
INNER JOIN dbo.Category selectedCategory
        ON selectedCategory.id = v.category_id
WHERE selectedCategory.parent_id IS NOT NULL;
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
   XV. EXTENDED ORDERS, PAYMENTS, RETURNS AND FEEDBACK
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
    recipient_phone, address_detail, province_code, province_name,
    ward_code, ward_name, total_items_price,
    discount_amount, shipping_fee, total_payment, order_status, note,
    created_at, updated_at
)
VALUES
('ORD-20260718-011', (SELECT id FROM dbo.[User] WHERE username = 'customer03'),
 (SELECT id FROM dbo.Voucher WHERE code = 'NEWCUSTOMER'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260718-011'),
 N'Nguyễn Minh Anh', '0905000003', N'12 Trần Phú', '48', N'Thành phố Đà Nẵng', '20194', N'Phường Thạch Thang',
 498000, 70000, 30000, 458000, 'DELIVERED', N'New customer first order',
 '2026-07-18 09:10:00', '2026-07-20 16:00:00'),
('ORD-20260718-012', (SELECT id FROM dbo.[User] WHERE username = 'customer04'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260718-012'),
 N'Trần Quốc Bảo', '0905000004', N'88 Võ Văn Kiệt', '48', N'Thành phố Đà Nẵng', '20305', N'Phường An Hải Bắc',
 329000, 0, 30000, 359000, 'DELIVERED', N'Blouse order',
 '2026-07-18 11:20:00', '2026-07-21 16:00:00'),
('ORD-20260719-013', (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.Voucher WHERE code = 'WOMEN20'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'VTP-20260719-013'),
 N'Lê Khánh Vy', '0905000005', N'25 Nguyễn Thiện Thuật', '56', N'Tỉnh Khánh Hòa', '22366', N'Phường Lộc Thọ',
 549000, 109800, 30000, 469200, 'SHIPPING', N'Womens collection campaign order',
 '2026-07-19 08:40:00', '2026-07-20 13:00:00'),
('ORD-20260719-014', (SELECT id FROM dbo.[User] WHERE username = 'customer06'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260719-014'),
 N'Phan Đức Huy', '0905000006', N'09 Hùng Vương', '56', N'Tỉnh Khánh Hòa', '22420', N'Thị trấn Cam Đức',
 549000, 0, 30000, 579000, 'CONFIRMED', N'Waiting for carrier pickup',
 '2026-07-19 09:30:00', '2026-07-19 10:00:00'),
('ORD-20260719-015', (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.Voucher WHERE code = 'SPORT10'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260719-015'),
 N'Vũ Ngọc Hà', '0905000007', N'41 Bạch Đằng', '48', N'Thành phố Đà Nẵng', '20200', N'Phường Hải Châu',
 798000, 50000, 30000, 778000, 'DELIVERED', N'Two training leggings',
 '2026-07-19 12:15:00', '2026-07-21 14:00:00'),
('ORD-20260719-016', (SELECT id FROM dbo.[User] WHERE username = 'customer08'),
 NULL, (SELECT id FROM dbo.Shipment WHERE id = 16),
 N'Bùi Gia Hân', '0905000008', N'66 Ngô Quyền', '48', N'Thành phố Đà Nẵng', '20314', N'Phường Mân Thái',
 259000, 0, 20000, 279000, 'PENDING', N'Awaiting order confirmation',
 '2026-07-19 14:00:00', '2026-07-19 14:00:00'),
('ORD-20260720-017', (SELECT id FROM dbo.[User] WHERE username = 'customer03'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260720-017'),
 N'Nguyễn Minh Anh', '0905000003', N'12 Trần Phú', '48', N'Thành phố Đà Nẵng', '20194', N'Phường Thạch Thang',
 459000, 0, 30000, 489000, 'DELIVERED', N'Cardigan for office layering',
 '2026-07-20 08:10:00', '2026-07-22 15:00:00'),
('ORD-20260720-018', (SELECT id FROM dbo.[User] WHERE username = 'customer04'),
 (SELECT id FROM dbo.Voucher WHERE code = 'VIP15'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260720-018'),
 N'Trần Quốc Bảo', '0905000004', N'88 Võ Văn Kiệt', '48', N'Thành phố Đà Nẵng', '20305', N'Phường An Hải Bắc',
 1298000, 150000, 30000, 1178000, 'SHIPPING', N'VIP denim jacket order',
 '2026-07-20 09:30:00', '2026-07-20 12:00:00'),
('ORD-20260720-019', (SELECT id FROM dbo.[User] WHERE username = 'customer05'),
 (SELECT id FROM dbo.Voucher WHERE code = 'ACCESSORY50'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'VTP-20260720-019'),
 N'Lê Khánh Vy', '0905000005', N'25 Nguyễn Thiện Thuật', '56', N'Tỉnh Khánh Hòa', '22366', N'Phường Lộc Thọ',
 358000, 50000, 30000, 338000, 'DELIVERED', N'Cap and tote set',
 '2026-07-20 10:10:00', '2026-07-22 12:00:00'),
('ORD-20260720-020', (SELECT id FROM dbo.[User] WHERE username = 'customer06'),
 NULL, (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHN-20260720-020'),
 N'Phan Đức Huy', '0905000006', N'09 Hùng Vương', '56', N'Tỉnh Khánh Hòa', '22420', N'Thị trấn Cam Đức',
 229000, 0, 30000, 259000, 'CONFIRMED', N'Canvas tote order',
 '2026-07-20 11:20:00', '2026-07-20 11:30:00'),
('ORD-20260720-021', (SELECT id FROM dbo.[User] WHERE username = 'customer07'),
 (SELECT id FROM dbo.Voucher WHERE code = 'FLASH100'),
 (SELECT id FROM dbo.Shipment WHERE tracking_code = 'GHTK-20260720-021'),
 N'Vũ Ngọc Hà', '0905000007', N'41 Bạch Đằng', '48', N'Thành phố Đà Nẵng', '20200', N'Phường Hải Châu',
 399000, 100000, 30000, 329000, 'DELIVERED', N'Pique polo order',
 '2026-07-20 12:00:00', '2026-07-23 15:00:00'),
('ORD-20260720-022', (SELECT id FROM dbo.[User] WHERE username = 'customer08'),
 NULL, (SELECT id FROM dbo.Shipment WHERE id = 22),
 N'Bùi Gia Hân', '0905000008', N'66 Ngô Quyền', '48', N'Thành phố Đà Nẵng', '20314', N'Phường Mân Thái',
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
    ('ORD-20260718-011', 'COD', 'PAID', NULL, '2026-07-18 09:15:00'),
    ('ORD-20260718-012', 'COD', 'PAID', NULL, '2026-07-21 16:00:00'),
    ('ORD-20260719-013', 'COD', 'PAID', NULL, '2026-07-19 08:45:00'),
    ('ORD-20260719-014', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260719-015', 'COD', 'PAID', NULL, '2026-07-19 12:20:00'),
    ('ORD-20260719-016', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260720-017', 'COD', 'PAID', NULL, '2026-07-20 08:15:00'),
    ('ORD-20260720-018', 'COD', 'PAID', NULL, '2026-07-20 09:35:00'),
    ('ORD-20260720-019', 'COD', 'PAID', NULL, '2026-07-22 12:00:00'),
    ('ORD-20260720-020', 'COD', 'UNPAID', NULL, NULL),
    ('ORD-20260720-021', 'COD', 'PAID', NULL, '2026-07-20 12:05:00'),
    ('ORD-20260720-022', 'COD', 'REFUNDED', NULL, '2026-07-20 14:05:00')
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

-- Four return/refund cases cover pending, approved, completed and rejected.
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
 'RETURN', 'DEFECTIVE', N'Button is loose on arrival.',
 N'Awaiting returned item from customer.', 680000, 'APPROVED',
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

UPDATE dbo.Return_Request
SET refund_bank_id = 'VCB',
    refund_bank_name = N'Vietcombank',
    refund_account_name = N'Nguyen Van A',
    refund_account_number = '0123456789',
    refund_transfer_description = N'REFUND ORD-20260405-004'
WHERE request_code = 'RET-20260718-002';

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

-- Dữ liệu mẫu đã hoàn tất thì xem như đã được kiểm tra trước khi nhập kho.
UPDATE ri
SET inspection_completed = 1, inspected_by = rr.received_by, inspected_at = rr.received_at
FROM dbo.Return_Request_Item ri
INNER JOIN dbo.Return_Request rr ON rr.id = ri.return_request_id
WHERE rr.status IN ('RECEIVED', 'COMPLETED');

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
 NULL, 'PENDING', N'Return request submitted', 5, '2026-07-18 13:00:00'),
((SELECT id FROM dbo.Return_Request WHERE request_code = 'RET-20260718-002'),
 'PENDING', 'APPROVED', N'Return approved by staff', 2, '2026-07-18 14:00:00'),
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
GO

/* =========================================================================
   XVI. HIGH-VOLUME ACCOUNT DEMO DATA
   Adds deterministic accounts for pagination, search, status filters,
   address selection and authentication screens.
   ========================================================================= */

-- 50 more customer accounts: customer09 ... customer58.
-- All generated accounts use the shared demo password: 123456.
;WITH CustomerNumbers AS (
    SELECT 9 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM CustomerNumbers
    WHERE account_no < 58
)
INSERT INTO dbo.[User]
    (username, password, full_name, email, phone, status, role_id)
SELECT
    CONCAT('customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
    CONCAT(N'Demo Customer ', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    CONCAT('demo.customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2), '@example.com'),
    CONCAT('0987', RIGHT('000000' + CONVERT(VARCHAR(6), n.account_no), 6)),
    CASE
        WHEN n.account_no % 17 = 0 THEN 'LOCKED'
        WHEN n.account_no % 11 = 0 THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END,
    r.id
FROM CustomerNumbers n
CROSS JOIN dbo.[Role] r
WHERE r.role_name = 'CUSTOMER'
OPTION (MAXRECURSION 0);

-- Additional staff accounts for inventory and order-management screens.
;WITH StaffNumbers AS (
    SELECT 4 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM StaffNumbers
    WHERE account_no < 10
)
INSERT INTO dbo.[User]
    (username, password, full_name, email, phone, status, role_id)
SELECT
    CONCAT('staff', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
    CONCAT(N'Demo Staff ', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    CONCAT('demo.staff', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2), '@clothesshop.com'),
    CONCAT('0978', RIGHT('000000' + CONVERT(VARCHAR(6), n.account_no), 6)),
    CASE WHEN n.account_no = 10 THEN 'INACTIVE' ELSE 'ACTIVE' END,
    r.id
FROM StaffNumbers n
CROSS JOIN dbo.[Role] r
WHERE r.role_name = 'STAFF'
OPTION (MAXRECURSION 0);

-- A few more administrators make role-based account listings more realistic.
;WITH AdminNumbers AS (
    SELECT 3 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM AdminNumbers
    WHERE account_no < 5
)
INSERT INTO dbo.[User]
    (username, password, full_name, email, phone, status, role_id)
SELECT
    CONCAT('admin', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO',
    CONCAT(N'Demo Administrator ', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    CONCAT('demo.admin', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2), '@clothesshop.com'),
    CONCAT('0966', RIGHT('000000' + CONVERT(VARCHAR(6), n.account_no), 6)),
    'ACTIVE',
    r.id
FROM AdminNumbers n
CROSS JOIN dbo.[Role] r
WHERE r.role_name = 'ADMIN'
OPTION (MAXRECURSION 0);

-- Two addresses per generated customer (one default and one secondary).
;WITH CustomerNumbers AS (
    SELECT 9 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM CustomerNumbers
    WHERE account_no < 58
)
INSERT INTO dbo.User_Address (
    user_id, recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name, is_default
)
SELECT
    u.id,
    u.full_name,
    u.phone,
    CONCAT(N'Demo customer apartment ', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    CASE n.account_no % 8
        WHEN 0 THEN '01'
        WHEN 1 THEN '01'
        WHEN 2 THEN '79'
        WHEN 3 THEN '79'
        WHEN 4 THEN '92'
        WHEN 5 THEN '92'
        WHEN 6 THEN '48'
        WHEN 7 THEN '48'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN N'Thành phố Hà Nội'
        WHEN 1 THEN N'Thành phố Hà Nội'
        WHEN 2 THEN N'Thành phố Hồ Chí Minh'
        WHEN 3 THEN N'Thành phố Hồ Chí Minh'
        WHEN 4 THEN N'Thành phố Cần Thơ'
        WHEN 5 THEN N'Thành phố Cần Thơ'
        WHEN 6 THEN N'Thành phố Đà Nẵng'
        WHEN 7 THEN N'Thành phố Đà Nẵng'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN '00001'
        WHEN 1 THEN '00010'
        WHEN 2 THEN '26734'
        WHEN 3 THEN '26743'
        WHEN 4 THEN '31147'
        WHEN 5 THEN '31162'
        WHEN 6 THEN '20194'
        WHEN 7 THEN '20200'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN N'Phường Phúc Xá'
        WHEN 1 THEN N'Phường Trúc Bạch'
        WHEN 2 THEN N'Phường Bến Nghé'
        WHEN 3 THEN N'Phường Cô Giang'
        WHEN 4 THEN N'Phường An Khánh'
        WHEN 5 THEN N'Phường Xuân Khánh'
        WHEN 6 THEN N'Phường Thạch Thang'
        WHEN 7 THEN N'Phường Hải Châu'
    END,
    1
FROM CustomerNumbers n
INNER JOIN dbo.[User] u
    ON u.username = CONCAT('customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2));

;WITH CustomerNumbers AS (
    SELECT 9 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM CustomerNumbers
    WHERE account_no < 58
)
INSERT INTO dbo.User_Address (
    user_id, recipient_name, recipient_phone, address_detail,
    province_code, province_name, ward_code, ward_name, is_default
)
SELECT
    u.id,
    u.full_name,
    u.phone,
    CONCAT(N'Demo customer office ', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    CASE n.account_no % 8
        WHEN 0 THEN '79'
        WHEN 1 THEN '79'
        WHEN 2 THEN '92'
        WHEN 3 THEN '92'
        WHEN 4 THEN '48'
        WHEN 5 THEN '48'
        WHEN 6 THEN '01'
        WHEN 7 THEN '01'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN N'Thành phố Hồ Chí Minh'
        WHEN 1 THEN N'Thành phố Hồ Chí Minh'
        WHEN 2 THEN N'Thành phố Cần Thơ'
        WHEN 3 THEN N'Thành phố Cần Thơ'
        WHEN 4 THEN N'Thành phố Đà Nẵng'
        WHEN 5 THEN N'Thành phố Đà Nẵng'
        WHEN 6 THEN N'Thành phố Hà Nội'
        WHEN 7 THEN N'Thành phố Hà Nội'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN '26734'
        WHEN 1 THEN '26743'
        WHEN 2 THEN '31147'
        WHEN 3 THEN '31162'
        WHEN 4 THEN '20194'
        WHEN 5 THEN '20200'
        WHEN 6 THEN '00001'
        WHEN 7 THEN '00010'
    END,
    CASE n.account_no % 8
        WHEN 0 THEN N'Phường Bến Nghé'
        WHEN 1 THEN N'Phường Cô Giang'
        WHEN 2 THEN N'Phường An Khánh'
        WHEN 3 THEN N'Phường Xuân Khánh'
        WHEN 4 THEN N'Phường Thạch Thang'
        WHEN 5 THEN N'Phường Hải Châu'
        WHEN 6 THEN N'Phường Phúc Xá'
        WHEN 7 THEN N'Phường Trúc Bạch'
    END,
    0
FROM CustomerNumbers n
INNER JOIN dbo.[User] u
    ON u.username = CONCAT('customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2));

-- Authentication samples: verified, unused verification and reset tokens.
;WITH CustomerNumbers AS (
    SELECT 9 AS account_no
    UNION ALL
    SELECT account_no + 1
    FROM CustomerNumbers
    WHERE account_no < 58
)
INSERT INTO dbo.Security_Token
    (user_id, token_type, token_value, expiry_date, is_used)
SELECT
    u.id,
    CASE WHEN n.account_no % 2 = 0 THEN 'EMAIL_VERIFY' ELSE 'PASSWORD_RESET' END,
    CONCAT('seed-token-demo-customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2)),
    DATEADD(DAY, n.account_no, CAST('2026-08-01T00:00:00' AS DATETIME)),
    CASE WHEN n.account_no % 3 = 0 THEN 1 ELSE 0 END
FROM CustomerNumbers n
INNER JOIN dbo.[User] u
    ON u.username = CONCAT('customer', RIGHT('00' + CONVERT(VARCHAR(2), n.account_no), 2));
GO

/* Preserve old variant-linked images while making them available by Color. */
UPDATE pi
SET pi.color = pv.color
FROM dbo.Product_Image pi
INNER JOIN dbo.Product_Variant pv
    ON pv.id = pi.variant_id
   AND pv.product_id = pi.product_id
WHERE pi.color IS NULL
  AND pi.variant_id IS NOT NULL
  AND pv.color IS NOT NULL;
GO

/* Normalize legacy numeric apparel sizes to the textual size system. */
UPDATE dbo.Product_Variant
SET size = CASE size
    WHEN N'28' THEN N'S'
    WHEN N'30' THEN N'M'
    WHEN N'32' THEN N'L'
    WHEN N'34' THEN N'XL'
    WHEN N'36' THEN N'XXL'
    ELSE size
END
WHERE size IN (N'28', N'30', N'32', N'34', N'36');
GO

/* =========================================================================
   XVII. VALIDATION
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

IF (SELECT COUNT(*) FROM dbo.[User] WHERE email LIKE 'demo.customer%@example.com') <> 50
BEGIN
    THROW 51005,
        'Seed validation failed: generated customer accounts are incomplete.',
        1;
END;

IF (SELECT COUNT(*) FROM dbo.User_Address WHERE address_detail LIKE N'Demo customer%') <> 100
BEGIN
    THROW 51006,
        'Seed validation failed: generated customer addresses are incomplete.',
        1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.Payment
    WHERE payment_method <> 'COD'
)
BEGIN
    THROW 51007,
        'Seed validation failed: Payment contains a method other than COD.',
        1;
END;

PRINT 'ClothesShopDB was created successfully.';
PRINT 'Demo password for all seeded accounts: 123456';
PRINT 'Admin account: admin01 / 123456';
PRINT 'Secondary admin: admin02 / 123456';
PRINT 'Staff account: staff01 / 123456';
GO

SELECT
    (SELECT COUNT(*) FROM dbo.[User]) AS user_count,
    (SELECT COUNT(*) FROM dbo.User_Address) AS user_address_count,
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