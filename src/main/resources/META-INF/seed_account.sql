USE ClothesShopDB;
GO

DELETE FROM Feedback;
DELETE FROM Inventory_Log;
DELETE FROM Payment;
DELETE FROM Order_Detail;
DELETE FROM [Order];
DELETE FROM Cart;
DELETE FROM Voucher;
DELETE FROM Shipment;
DELETE FROM Product_Image;
DELETE FROM Variant_Attribute_Value;
DELETE FROM Product_Variant;
DELETE FROM Product;
DELETE FROM Attribute;
DELETE FROM Category;
DELETE FROM Brand;
DELETE FROM User_Address;
DELETE FROM Security_Token;
DELETE FROM Activity_Log;
DELETE FROM [User];
DELETE FROM Role;
DELETE FROM Ward;
DELETE FROM District;
DELETE FROM Province;
GO

DBCC CHECKIDENT ('Role',              RESEED, 0);
DBCC CHECKIDENT ('[User]',            RESEED, 0);
DBCC CHECKIDENT ('User_Address',      RESEED, 0);
DBCC CHECKIDENT ('Security_Token',    RESEED, 0);
DBCC CHECKIDENT ('Activity_Log',      RESEED, 0);
DBCC CHECKIDENT ('Brand',             RESEED, 0);
DBCC CHECKIDENT ('Category',          RESEED, 0);
DBCC CHECKIDENT ('Product',           RESEED, 0);
DBCC CHECKIDENT ('Product_Image',     RESEED, 0);
DBCC CHECKIDENT ('Product_Variant',   RESEED, 0);
DBCC CHECKIDENT ('Attribute',         RESEED, 0);
DBCC CHECKIDENT ('Inventory_Log',     RESEED, 0);
DBCC CHECKIDENT ('Voucher',           RESEED, 0);
DBCC CHECKIDENT ('Shipment',          RESEED, 0);
DBCC CHECKIDENT ('[Order]',           RESEED, 0);
DBCC CHECKIDENT ('Order_Detail',      RESEED, 0);
DBCC CHECKIDENT ('Payment',           RESEED, 0);
DBCC CHECKIDENT ('Feedback',          RESEED, 0);
GO

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
(4, N'Nguyễn Ngọc Quý',        '0933445566', '31162', N'Số 123 Đường 3/2',             1),
(4, N'Anh Quý (Văn phòng)',    '0933445566', '26734', N'Tòa nhà Bitexco, Tầng 15',     0),
(5, N'Lê Hoàng Nam',           '0944556677', '00010', N'Số 45 Phố Trúc Bạch',          1);

-- =========================================================================
-- 3. BRANDS & CATEGORIES
-- =========================================================================
INSERT INTO Brand (brand_name, slug, description, logo_url) VALUES
('Coolmate', 'coolmate', N'Thương hiệu thời trang nam tối giản',            'coolmate_logo.png'),
('Routine',  'routine',  N'Thời trang nam nữ phong cách hằng ngày',         'routine_logo.png'),
('Uniqlo',   'uniqlo',   N'Thời trang bán lẻ quốc tế đến từ Nhật Bản',     'uniqlo_logo.png');

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'Áo Nam',  'ao-nam',  NULL, N'Các sản phẩm áo dành cho nam', 1),
(N'Quần Nam','quan-nam', NULL, N'Các sản phẩm quần dành cho nam', 1);

INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES
(N'Áo Thun T-Shirt', 'ao-thun-t-shirt', 1, N'Áo thun cổ tròn, cổ tim nam',   1),
(N'Áo Sơ Mi',        'ao-so-mi',        1, N'Áo sơ mi dài tay, ngắn tay',     1),
(N'Quần Jean Nam',   'quan-jean-nam',   2, N'Quần bò, jean dáng dài',          1);

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
(N'Áo Thun Nam Cotton Compact',    'ao-thun-nam-cotton-compact',    1, 3, N'Áo thun 100% cotton siêu mát',        N'Chất liệu cotton compact bền bỉ gấp 2 lần cotton thường, thấm hút mồ hôi cực tốt thích hợp mặc hằng ngày.',                    'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Nam Dáng Slimfit',    'quan-jean-nam-dang-slimfit',    2, 5, N'Quần jean co giãn nhẹ lịch lãm',      N'Thiết kế ôm nhẹ tôn dáng, chất liệu jean dày dặn có co giãn giúp thoải mái vận động cả ngày dài.',                          'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Thun Thể Thao Nam Pro',      'ao-thun-the-thao-nam-pro',      1, 3, N'Chất vải co giãn, thoáng khí tốt',    N'Phù hợp cho các hoạt động thể thao, gym, chạy bộ với độ bền màu cao.',                                                       'ACTIVE', GETDATE(), GETDATE()),
(N'Áo T-Shirt Cotton Cổ Tròn',     'ao-t-shirt-cotton-co-tron',     1, 3, N'100% Cotton tự nhiên mềm mại',        N'Form dáng basic dễ phối đồ, mặc mát mẻ quanh năm.',                                                                          'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Polo Nam Gân Nổi',           'ao-polo-nam-gan-noi',           1, 3, N'Áo polo lịch sự, tôn dáng',           N'Chất liệu cá sấu pha spandex giúp giữ form áo cực tốt sau nhiều lần giặt.',                                                   'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Thun Oversize Đường Phố',    'ao-thun-oversize-duong-pho',    1, 3, N'Phong cách streetstyle năng động',    N'Thiết kế rộng rãi, họa tiết in kỹ thuật số sắc nét không bong tróc.',                                                        'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Cổ Tàu Vải Đũi',      'ao-so-mi-co-tau-vai-dui',       2, 4, N'Chất đũi nhẹ nhàng, thấm hút',        N'Phong cách nhẹ nhàng vintage, thích hợp đi du lịch, đi cà phê.',                                                             'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Trắng Công Sở OxFord','ao-so-mi-trang-cong-so-oxford', 2, 4, N'Vải Oxford dày dặn, đứng form',        N'Mẫu áo không thể thiếu của phái mạnh khi đi làm hoặc tham gia sự kiện.',                                                     'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Họa Tiết Sọc Kẻ',     'ao-so-mi-hoa-tiet-soc-ke',      3, 4, N'Sọc kẻ thanh lịch trẻ trung',         N'Chất vải ít nhăn, dễ ủi, mang lại cảm giác dễ chịu cả ngày.',                                                               'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Denim Bụi Bặm',       'ao-so-mi-denim-bui-bam',        2, 4, N'Phong cách bò nam tính',               N'Vải denim mềm vừa phải, có thể mặc khoác ngoài hoặc mặc trơn.',                                                             'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Đen Trơn Dáng Baggy', 'quan-jean-den-tron-dang-baggy', 2, 5, N'Dáng baggy thoải mái vận động',       N'Phù hợp cho cả nam và nữ, chất bò dày dặn, không ra màu.',                                                                   'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Rách Gối Cá Tính',    'quan-jean-rach-goi-ca-tinh',    2, 5, N'Điểm nhấn rách gối trẻ trung',        N'Sản phẩm dành cho các bạn trẻ yêu thích sự phá cách, bụi bặm.',                                                             'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Co Giãn Màu Xám Khói','quan-jean-co-gian-mau-xam-khoi',2, 5, N'Màu xám khói trendy dễ phối',         N'Sự kết hợp hoàn hảo giữa cotton và spandex tạo độ co giãn tối đa.',                                                         'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Nam Dáng Đứng Regular','quan-jean-nam-dang-dung-regular',3,5, N'Ống đứng cổ điển, lịch sự',           N'Thích hợp cho độ tuổi trưởng thành, mặc đi làm, đi chơi đều hợp.',                                                          'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Khoác Gió Chống Nước',       'ao-khoac-gio-chong-nuoc',       3, 3, N'Chống mưa nhẹ và cản gió tốt',        N'Công nghệ vải dù cao cấp từ Nhật Bản, có túi trong tiện lợi.',                                                               'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Hoodie Nỉ Bông Mùa Đông',    'ao-hoodie-ni-bong-mua-dong',    1, 3, N'Nỉ bông dày dặn siêu ấm áp',          N'Form áo local brand rộng rãi, bo chun tay chắc chắn.',                                                                       'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Short Kaki Đi Biển',        'quan-short-kaki-di-bien',       2, 5, N'Chất kaki mềm, nhiều màu sắc',        N'Chiều dài ngang đùi trẻ trung, cạp chun co giãn dễ chịu.',                                                                   'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Tanktop Nam Sát Nách Gym',    'ao-tanktop-nam-sat-nach-gym',   1, 3, N'Thiết kế khoét sâu thể thao',         N'Vải thun lạnh siêu mát, thoát mồ hôi chỉ trong vài giây.',                                                                   'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Tây Âu Công Sở Nam',        'quan-tay-au-cong-so-nam',       2, 5, N'Chất vải tuyết mưa đứng dáng',        N'Có tăng cạp thông minh, thích hợp phối cùng áo sơ mi.',                                                                      'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Blazer Nam Hàn Quốc',         'ao-blazer-nam-han-quoc',        2, 4, N'Form rộng phong cách lãng tử',        N'Vải có lót trong mịn màng, thích hợp mặc mùa thu đông.',                                                                     'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Len Cổ Lọ Giữ Nhiệt',         'ao-len-co-lo-giu-nhiet',        3, 3, N'Sợi len dệt tăm co giãn tốt',         N'Giữ ấm cổ rất tốt, ôm sát cơ thể tôn đường nét nam tính.',                                                                   'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jogger Thể Thao Năng Động', 'quan-jogger-the-thao-nang-dong',1, 5, N'Chất nỉ chân cua cao cấp',            N'Thích hợp mặc ở nhà, đi tập hoặc dạo phố cuối tuần.',                                                                        'ACTIVE', GETDATE(), GETDATE());
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
(1, 1, N'Đen'),        (1, 2, 'M'),
(2, 1, N'Đen'),        (2, 2, 'L'),
(3, 1, N'Trắng'),      (3, 2, 'M'),
(4, 1, N'Trắng'),      (4, 2, 'L');

-- Product 2 (variant_id 5-6)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES
(5, 1, N'Xanh Khói'),  (5, 2, '30'),
(6, 1, N'Xanh Khói'),  (6, 2, '31');

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

-- =========================================================================
-- 9. VOUCHERS, CART, ORDERS & PAYMENTS
-- =========================================================================
INSERT INTO Voucher (code, title, discount_type, discount_value, max_discount_amount, min_order_value, start_date, end_date, usage_limit, used_count) VALUES
('XINCHAO50', N'Voucher chào mừng thành viên mới',       'FIXED_AMOUNT', 50000, 50000, 150000, '2026-01-01', '2026-12-31', 1000,  5),
('HE2026',    N'Khuyến mãi bộ sưu tập hè giảm 10%',      'PERCENTAGE',   10,    30000, 200000, '2026-05-01', '2026-08-31',  500, 12);

INSERT INTO Cart (user_id, variant_id, quantity) VALUES
(4, 1, 2),
(4, 5, 1);

INSERT INTO Shipment (carrier_name, shipping_status, tracking_code, shipping_cost, estimated_delivery_time) VALUES
(N'Giao Hàng Nhanh (GHN)', 'SHIPPING', 'GHN998877A', 30000, '2026-06-05');

INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note) VALUES
('SHOP-20260601-001', 4, 1, 1, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 639000, 50000, 30000, 619000, 'SHIPPING', N'Giao giờ hành chính giúp em');

INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price) VALUES
(1, 1, N'Áo Thun Nam Cotton Compact', N'Color: Đen, Size: M',        1, 189000),
(1, 5, N'Quần Jean Nam Dáng Slimfit', N'Color: Xanh Khói, Size: 30', 1, 450000);

INSERT INTO Payment (order_id, payment_method, payment_status, amount, transaction_reference, payment_date) VALUES
(1, 'VNPAY', 'PAID', 619000, 'VNPAY123456789', '2026-06-01 08:30:00');

-- =========================================================================
-- 10. INVENTORY LOG & FEEDBACK
-- =========================================================================
INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) VALUES
(1, 2, 50, 'IMPORT', N'Nhập lô hàng áo thun đen M đầu mùa hè'),
(5, 2, 20, 'IMPORT', N'Nhập lô hàng quần jean dáng slimfit size 30');

INSERT INTO Feedback (user_id, product_id, order_id, rating, comment, status) VALUES
(5, 1, NULL, 5, N'Áo mặc mát lắm, giặt không bị xù lông, sẽ ủng hộ shop tiếp!', 1);
GO

-- =========================================================================
-- BỔ SUNG DỮ LIỆU 
-- =========================================================================

USE ClothesShopDB;
GO

-- 1. Bổ sung một số Voucher mẫu đúng chuẩn 'PERCENT' hoặc 'FIXED_AMOUNT'
INSERT INTO Voucher (code, title, discount_type, discount_value, max_discount_amount, min_order_value, start_date, end_date, usage_limit, used_count)
VALUES 
('VOUCHER10', N'Giảm 10% cho đơn hàng từ 500k', 'PERCENT', 10.00, 50000.00, 500000.00, '2026-01-01', '2026-12-31', 100, 15),
('FIXED50', N'Giảm thẳng 50k cho thành viên mới', 'FIXED_AMOUNT', 50000.00, NULL, 200000.00, '2026-01-01', '2026-12-31', 200, 30);

-- 2. Bổ sung một số đơn vị vận chuyển (Shipment)
INSERT INTO Shipment (carrier_name, shipping_status, tracking_code, shipping_cost, estimated_delivery_time)
VALUES 
(N'Giao Hàng Nhanh (GHN)', 'DELIVERED', 'GHN123456789', 30000.00, '2026-02-15'),
(N'Giao Hàng Tiết Kiệm (GHTK)', 'DELIVERED', 'GHTK987654321', 30000.00, '2026-03-20'),
(N'Viettel Post', 'SHIPPING', 'VT777888999', 30000.00, '2026-06-25');

-- 3. Bổ sung đơn hàng mẫu (Mã ORD + chuỗi số, Phí ship cố định 30,000đ)
-- Giả định hệ thống của bạn đã có user_id = 1 (hoặc thay bằng id khách hàng hợp lệ trong DB của bạn)
-- Đơn hàng tháng 1/2026 (Thành công -> Tính vào doanh thu)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES ('ORD1768234100001', 1, NULL, 1, N'Nguyễn Văn A', '0912345678', NULL, N'123 Đường Lê Lợi', 450000.00, 0.00, 30000.00, 480000.00, 'DELIVERED', N'Đơn hàng tháng 1', '2026-01-15 10:30:00', '2026-01-17 15:00:00');

-- Đơn hàng tháng 2/2026 (Thành công)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES ('ORD1768234200002', 1, NULL, 1, N'Nguyễn Văn A', '0912345678', NULL, N'123 Đường Lê Lợi', 780000.00, 0.00, 30000.00, 810000.00, 'DELIVERED', N'Đơn hàng tháng 2', '2026-02-20 14:15:00', '2026-02-22 16:30:00');

-- Đơn hàng tháng 3/2026 (Thành công)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES ('ORD1768234300003', 1, 1, 2, N'Nguyễn Văn A', '0912345678', NULL, N'123 Đường Lê Lợi', 600000.00, 50000.00, 30000.00, 580000.00, 'DELIVERED', N'Đơn hàng tháng 3 áp dụng voucher', '2026-03-10 09:00:00', '2026-03-12 11:00:00');

-- Đơn hàng tháng 4/2026 (Thành công)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES ('ORD1768234400004', 1, NULL, 2, N'Trần Thị B', '0988888888', NULL, N'456 Trần Hưng Đạo', 1200000.00, 0.00, 30000.00, 1230000.00, 'DELIVERED', N'Đơn hàng lớn tháng 4', '2026-04-05 18:20:00', '2026-04-07 20:00:00');

-- Đơn hàng tháng 5/2026 (Thành công)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES ('ORD1768234500005', 1, 2, 2, N'Trần Thị B', '0988888888', NULL, N'456 Trần Hưng Đạo', 950000.00, 50000.00, 30000.00, 930000.00, 'DELIVERED', N'Đơn hàng tháng 5', '2026-05-18 11:10:00', '2026-05-20 14:00:00');

-- Các đơn hàng tháng 6/2026 (Tháng hiện tại - Gồm cả đơn đã xong và đơn PENDING mới nhận)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES 
('ORD1768234600006', 1, NULL, 1, N'Lê Hoàng C', '0901112222', NULL, N'789 Nguyễn Trãi', 350000.00, 0.00, 30000.00, 380000.00, 'DELIVERED', N'Đơn hoàn thành tháng 6', '2026-06-02 08:30:00', '2026-06-04 10:00:00'),
('ORD1768234600007', 1, NULL, 3, N'Phạm Minh D', '0933344455', NULL, N'321 Điện Biên Phủ', 500000.00, 0.00, 30000.00, 530000.00, 'PENDING', N'Đơn hàng MỚI CHỜ DUYỆT 1', '2026-06-21 15:45:00', '2026-06-21 15:45:00'),
('ORD1768234600008', 1, NULL, NULL, N'Hoàng Thúy E', '0944555666', NULL, N'15 Ba Tháng Hai', 280000.00, 0.00, 30000.00, 310000.00, 'PENDING', N'Đơn hàng MỚI CHỜ DUYỆT 2', '2026-06-22 10:00:00', '2026-06-22 10:00:00'),
('ORD1768234600009', 1, NULL, NULL, N'Đỗ Tiến F', '0955666777', NULL, N'99 Cộng Hòa', 620000.00, 0.00, 30000.00, 650000.00, 'CANCELLED', N'Đơn hàng khách hủy', '2026-06-10 13:00:00', '2026-06-10 13:30:00');

-- 4. Chi tiết đơn hàng mẫu (Liên kết đến các đơn hàng vừa tạo thông qua ID tự tăng)
-- Đơn 1
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234100001'), 1, N'Áo Sơ Mi Nam Hàn Quốc', N'Size: M, Color: Blue', 2, 225000.00);

-- Đơn 2
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234200002'), 2, N'Quần Jean Nam Cao Cấp', N'Size: L, Color: Black', 2, 390000.00);

-- Đơn 3
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234300003'), 1, N'Áo Sơ Mi Nam Hàn Quốc', N'Size: M, Color: Blue', 2, 200000.00),
       ((SELECT id FROM [Order] WHERE order_code='ORD1768234300003'), 2, N'Quần Jean Nam Cao Cấp', N'Size: L, Color: Black', 1, 200000.00);

-- Đơn 4
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234400004'), 3, N'Váy Nữ Dáng Xòe Elegant', N'Size: S, Color: Red', 3, 400000.00);

-- Đơn 5
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234500005'), 2, N'Quần Jean Nam Cao Cấp', N'Size: L, Color: Black', 1, 450000.00),
       ((SELECT id FROM [Order] WHERE order_code='ORD1768234500005'), 3, N'Váy Nữ Dáng Xòe Elegant', N'Size: S, Color: Red', 1, 500000.00);

-- Đơn 6 (Đơn hoàn thành trong tháng 6)
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234600006'), 1, N'Áo Sơ Mi Nam Hàn Quốc', N'Size: M, Color: Blue', 1, 350000.00);

-- Đơn 7, 8 (Các đơn hàng mới đang chờ xử lý)
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234600007'), 2, N'Quần Jean Nam Cao Cấp', N'Size: L, Color: Black', 1, 500000.00);

INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price)
VALUES ((SELECT id FROM [Order] WHERE order_code='ORD1768234600008'), 1, N'Áo Sơ Mi Nam Hàn Quốc', N'Size: M, Color: Blue', 1, 280000.00);

-- 5. Đồng bộ bảng thanh toán (Payment) tương ứng cho các đơn thành công
INSERT INTO Payment (order_id, payment_method, payment_status, amount, transaction_reference, payment_date)
VALUES 
((SELECT id FROM [Order] WHERE order_code='ORD1768234100001'), 'BANK_TRANSFER', 'PAID', 480000.00, 'TXN2026011501', '2026-01-15 10:35:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234200002'), 'VNPAY', 'PAID', 810000.00, 'TXN2026022002', '2026-02-20 14:20:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234300003'), 'COD', 'PAID', 580000.00, NULL, '2026-03-12 11:05:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234400004'), 'VNPAY', 'PAID', 1230000.00, 'TXN2026040504', '2026-04-05 18:22:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234500005'), 'BANK_TRANSFER', 'PAID', 930000.00, 'TXN2026051805', '2026-05-18 11:15:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234600006'), 'COD', 'PAID', 380000.00, NULL, '2026-06-04 10:05:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234600007'), 'COD', 'UNPAID', 530000.00, NULL, NULL),
((SELECT id FROM [Order] WHERE order_code='ORD1768234600008'), 'VNPAY', 'UNPAID', 310000.00, NULL, NULL);

-- =========================================================================
-- 11. DỮ LIỆU MỞ RỘNG CHO ORDER MANAGEMENT & FEEDBACK MANAGEMENT
-- =========================================================================

-- Thêm các đơn hàng với nhiều trạng thái để test danh sách, filter và chi tiết xử lý
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note, created_at, updated_at)
VALUES
('ORD1768234700010', 4, 1, 1, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 438000.00, 50000.00, 30000.00, 418000.00, 'DELIVERED', N'Đơn đã giao xong, dùng để test lịch sử đơn', '2026-06-23 09:15:00', '2026-06-25 18:20:00'),
('ORD1768234700011', 5, 2, 2, N'Lê Hoàng Nam', '0944556677', '00010', N'Số 45 Phố Trúc Bạch', 879000.00, 30000.00, 30000.00, 879000.00, 'SHIPPING', N'Đơn đang giao để test trạng thái vận chuyển', '2026-06-24 10:00:00', '2026-06-26 12:10:00'),
('ORD1768234700012', 4, NULL, 3, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Tòa nhà Bitexco, Tầng 15', 560000.00, 0.00, 30000.00, 590000.00, 'CONFIRMED', N'Đơn đã xác nhận chờ xuất kho', '2026-06-25 11:45:00', '2026-06-25 13:00:00'),
('ORD1768234700013', 5, NULL, NULL, N'Lê Hoàng Nam', '0944556677', '00010', N'Số 45 Phố Trúc Bạch', 379000.00, 0.00, 30000.00, 409000.00, 'PENDING', N'Đơn mới tạo chờ duyệt thanh toán', '2026-06-26 08:30:00', '2026-06-26 08:30:00'),
('ORD1768234700014', 4, NULL, 2, N'Nguyễn Ngọc Quý', '0933445566', '26734', N'Văn phòng Bitexco, tầng 15', 839000.00, 0.00, 30000.00, 869000.00, 'CANCELLED', N'Đơn bị hủy để test luồng hoàn tất/hủy', '2026-06-20 14:05:00', '2026-06-20 14:40:00'),
('ORD1768234700015', 5, 1, 1, N'Lê Hoàng Nam', '0944556677', '00010', N'Số 45 Phố Trúc Bạch', 588000.00, 50000.00, 30000.00, 568000.00, 'RETURNED', N'Đơn đã giao nhưng khách trả hàng', '2026-06-18 09:00:00', '2026-06-28 10:15:00');

-- Chi tiết cho các đơn bổ sung
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price) VALUES
((SELECT id FROM [Order] WHERE order_code='ORD1768234700010'), 12, N'Áo T-Shirt Cotton Cổ Tròn', N'Color: White, Size: M', 1, 179000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700010'), 15, N'Áo Polo Nam Gân Nổi', N'Color: White, Size: M', 1, 259000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700011'), 69, N'Áo Blazer Nam Hàn Quốc', N'Color: Black, Size: M', 1, 680000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700011'), 57, N'Quần Short Kaki Đi Biển', N'Color: Beige, Size: M', 1, 199000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700012'), 28, N'Áo Sơ Mi Trắng Công Sở Oxford', N'Color: White, Size: L', 2, 280000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700013'), 53, N'Áo Hoodie Nỉ Bông Mùa Đông', N'Color: Gray, Size: M', 1, 379000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700014'), 34, N'Áo Sơ Mi Denim Bụi Bặm', N'Color: Denim Blue, Size: M', 1, 340000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700014'), 46, N'Quần Jean Nam Dáng Đứng Regular', N'Color: Dark Blue, Size: 30', 1, 499000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700015'), 73, N'Áo Len Cổ Lọ Giữ Nhiệt', N'Color: Cream, Size: M', 1, 359000.00),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700015'), 77, N'Quần Jogger Thể Thao Năng Động', N'Color: Black, Size: M', 1, 229000.00);

-- Thanh toán cho các đơn mới để test nhiều trạng thái
INSERT INTO Payment (order_id, payment_method, payment_status, amount, transaction_reference, payment_date)
VALUES
((SELECT id FROM [Order] WHERE order_code='ORD1768234700010'), 'BANK_TRANSFER', 'PAID', 418000.00, 'TXN2026062301', '2026-06-23 09:20:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700011'), 'VNPAY', 'PAID', 879000.00, 'TXN2026062402', '2026-06-24 10:05:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700012'), 'COD', 'PAID', 590000.00, NULL, '2026-06-25 11:50:00'),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700013'), 'COD', 'UNPAID', 409000.00, NULL, NULL),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700014'), 'VNPAY', 'FAILED', 869000.00, NULL, NULL),
((SELECT id FROM [Order] WHERE order_code='ORD1768234700015'), 'BANK_TRANSFER', 'REFUNDED', 568000.00, 'TXN2026061803', '2026-06-28 10:30:00');

-- Feedback đa dạng để test hiển thị, ẩn/hiện và trả lời của admin/staff
INSERT INTO Feedback (user_id, product_id, order_id, rating, comment, status, admin_response, response_by, responded_at) VALUES
(4, 1, (SELECT id FROM [Order] WHERE order_code='ORD1768234100001'), 5, N'Áo mặc rất mát, form đẹp, giao nhanh.', 1, N'Cảm ơn anh đã đánh giá. Shop sẽ tiếp tục cải thiện dịch vụ.', 2, '2026-06-02 09:00:00'),
(4, 4, (SELECT id FROM [Order] WHERE order_code='ORD1768234700010'), 4, N'Chất vải ổn, màu dễ phối, size chuẩn.', 1, NULL, NULL, NULL),
(5, 20, (SELECT id FROM [Order] WHERE order_code='ORD1768234700011'), 2, N'Áo đẹp nhưng giao hơi chậm so với dự kiến.', 0, N'Shop đã ghi nhận phản hồi và sẽ theo dõi đơn vị vận chuyển.', 1, '2026-06-26 16:20:00'),
(5, 8, (SELECT id FROM [Order] WHERE order_code='ORD1768234700012'), 5, N'Sơ mi rất lịch sự, mặc đi làm rất hợp.', 1, NULL, NULL, NULL),
(4, 16, (SELECT id FROM [Order] WHERE order_code='ORD1768234700015'), 1, N'Khách trả hàng vì size không vừa, cần hỗ trợ đổi size.', 0, N'Shop đã tiếp nhận yêu cầu đổi trả và liên hệ lại khách.', 2, '2026-06-28 10:40:00'),
(5, 12, (SELECT id FROM [Order] WHERE order_code='ORD1768234500005'), 3, N'Mẫu quần ổn nhưng đóng gói cần chắc chắn hơn.', 1, N'Cảm ơn anh góp ý, shop sẽ cải thiện bao bì.', 2, '2026-05-20 15:10:00'),
(4, 22, (SELECT id FROM [Order] WHERE order_code='ORD1768234700013'), 4, N'Quần jogger mặc thoải mái, phù hợp đi tập.', 1, NULL, NULL, NULL),
(5, 10, (SELECT id FROM [Order] WHERE order_code='ORD1768234700014'), 2, N'Áo denim ổn nhưng form hơi rộng với mình.', 0, N'Shop xin lỗi về trải nghiệm chưa tốt, đã ẩn phản hồi để kiểm tra nội dung.', 1, '2026-06-20 18:00:00');
GO
