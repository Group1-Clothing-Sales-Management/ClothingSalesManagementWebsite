USE ClothesShopDB;
GO

-- Xóa dữ liệu cũ trong các bảng để đảm bảo không bị trùng lặp khóa chính/độc nhất (Unique/Slug Key)
DELETE FROM Feedback;
DELETE FROM Inventory_Log;
DELETE FROM Payment;
DELETE FROM Order_Detail;
DELETE FROM [Order];
DELETE FROM Cart;
DELETE FROM Voucher;
DELETE FROM Product_Image;
DELETE FROM Product;
DELETE FROM Variant_Attribute_Value;
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

-- =========================================================================
-- 1. PHÂN HỆ ĐỊA GIỚI HÀNH CHÍNH (Tỉnh, Huyện, Xã) - [Từ seed_account gốc]
-- =========================================================================
INSERT INTO Province (id, province_name, type) VALUES 
('01', N'Thành phố Hà Nội', N'Thành phố Trung ương'),
('79', N'Thành phố Hồ Chí Minh', N'Thành phố Trung ương'),
('92', N'Thành phố Cần Thơ', N'Thành phố Trung ương');

INSERT INTO District (id, district_name, type, province_id) VALUES 
('001', N'Quận Ba Đình', N'Quận', '01'),
('002', N'Quận Tây Hồ', N'Quận', '01'),
('760', N'Quận 1', N'Quận', '79'),
('769', N'Quận Thủ Đức', N'Quận', '79'),
('916', N'Quận Ninh Kiều', N'Quận', '92');

INSERT INTO Ward (id, ward_name, type, district_id) VALUES 
('00001', N'Phường Phúc Xá', N'Phường', '001'),
('00010', N'Phường Trúc Bạch', N'Phường', '001'),
('26734', N'Phường Bến Nghé', N'Phường', '760'),
('26743', N'Phường Cô Giang', N'Phường', '760'),
('31147', N'Phường An Khánh', N'Phường', '916'),
('31162', N'Phường Xuân Khánh', N'Phường', '916');


-- =========================================================================
-- 2. PHÂN HỆ TÀI KHOẢN & PHÂN QUYỀN - [Từ seed_account gốc]
-- =========================================================================
INSERT INTO Role (role_name, description) VALUES 
('ADMIN', N'Quản trị viên toàn quyền hệ thống'),
('STAFF', N'Nhân viên quản lý kho và đơn hàng'),
('CUSTOMER', N'Khách hàng mua sắm trực tuyến');

-- Demo internal accounts use a shared bcrypt-hashed password: 123456
INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) VALUES 
('admin01', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Văn Admin', 'admin@clothesshop.com', '0911223344', 'ACTIVE', 1),
('admin02', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Nhật Quy', 'quy@gmail.com', '0911223344', 'ACTIVE', 1),
('staff01', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Trần Thị Nhân Viên', 'staff@clothesshop.com', '0922334455', 'ACTIVE', 2),
('quy_nn', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Nguyễn Ngọc Quý', 'quynn@gmail.com', '0933445566', 'ACTIVE', 3),
('khachhang02', '$2a$12$qHDNzN1jRm4wFD4yk2jDLOx46nkQ2DFr4IJUPTEH97oBuvXK4dYlO', N'Lê Hoàng Nam', 'namlh@gmail.com', '0944556677', 'ACTIVE', 3);

INSERT INTO User_Address (user_id, recipient_name, recipient_phone, ward_id, address_detail, is_default) VALUES 
(3, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 1),
(3, N'Anh Quý (Văn phòng)', '0933445566', '26734', N'Tòa nhà Bitexco, Tầng 15', 0),
(4, N'Lê Hoàng Nam', '0944556677', '00010', N'Số 45 Phố Trúc Bạch', 1);


-- =========================================================================
-- 3. THƯƠNG HIỆU & DANH MỤC - [Từ seed_account gốc]
-- =========================================================================
INSERT INTO Brand (brand_name, slug, description, logo_url) VALUES 
('Coolmate', 'coolmate', N'Thương hiệu thời trang nam tối giản', 'coolmate_logo.png'),
('Routine', 'routine', N'Thời trang nam nữ phong cách hằng ngày', 'routine_logo.png'),
('Uniqlo', 'uniqlo', N'Thời trang bán lẻ quốc tế đến từ Nhật Bản', 'uniqlo_logo.png');

-- Thêm danh mục cha
INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES 
(N'Áo Nam', 'ao-nam', NULL, N'Các sản phẩm áo dành cho nam', 1),
(N'Quần Nam', 'quan-nam', NULL, N'Các sản phẩm quần dành cho nam', 1);

-- Thêm danh mục con (Giả định ID tự tăng của danh mục cha lần lượt là 1 và 2)
INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES 
(N'Áo Thun T-Shirt', 'ao-thun-t-shirt', 1, N'Áo thun cổ tròn, cổ tim nam', 1),
(N'Áo Sơ Mi', 'ao-so-mi', 1, N'Áo sơ mi dài tay, ngắn tay', 1),
(N'Quần Jean Nam', 'quan-jean-nam', 2, N'Quần bò, jean dáng dài', 1);


-- =========================================================================
-- 4. THUỘC TÍNH SẢN PHẨM (EAV MODEL) - [Từ seed_account gốc]
-- =========================================================================
INSERT INTO Attribute (attribute_name) VALUES 
(N'Color'),
(N'Size');


-- =========================================================================
-- 5. DANH SÁCH SẢN PHẨM GỐC + 20 SẢN PHẨM MỚI BỔ SUNG THỰC TẾ
-- =========================================================================
-- [Sản phẩm gốc từ seed_account: ID 1 và ID 2]
INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status, created_at, updated_at) VALUES 
(N'Áo Thun Nam Cotton Compact', 'ao-thun-nam-cotton-compact', 1, 3, N'Áo thun 100% cotton siêu mát', N'Chất liệu cotton compact bền bỉ gấp 2 lần cotton thường, thấm hút mồ hôi cực tốt thích hợp mặc hằng ngày.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Nam Dáng Slimfit', 'quan-jean-nam-dang-slimfit', 2, 5, N'Quần jean co giãn nhẹ lịch lãm', N'Thiết kế ôm nhẹ tôn dáng, chất liệu jean dày dặn có co giãn giúp thoải mái vận động cả ngày dài.', 'ACTIVE', GETDATE(), GETDATE());

-- [20 sản phẩm bổ sung phong phú: ID tự tăng từ 3 đến 22]
INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status, created_at, updated_at) VALUES 
-- Nhóm Áo thun (Category 3, Brand 1: Coolmate)
(N'Áo Thun Thể Thao Nam Pro', 'ao-thun-the-thao-nam-pro', 1, 3, N'Chất vải co giãn, thoáng khí tốt', N'Phù hợp cho các hoạt động thể thao, gym, chạy bộ với độ bền màu cao.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo T-Shirt Cotton Cổ Tròn', 'ao-t-shirt-cotton-co-tron', 1, 3, N'100% Cotton tự nhiên mềm mại', N'Form dáng basic dễ phối đồ, mặc mát mẻ quanh năm.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Polo Nam Gân Nổi', 'ao-polo-nam-gan-noi', 1, 3, N'Áo polo lịch sự, tôn dáng', N'Chất liệu cá sấu pha spandex giúp giữ form áo cực tốt sau nhiều lần giặt.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Thun Oversize Đường Phố', 'ao-thun-oversize-duong-pho', 1, 3, N'Phong cách streetstyle năng động', N'Thiết kế rộng rãi, họa tiết in kỹ thuật số sắc nét không bong tróc.', 'ACTIVE', GETDATE(), GETDATE()),

-- Nhóm Áo Sơ Mi (Category 4, Brand 2: Routine, Brand 3: Uniqlo)
(N'Áo Sơ Mi Cổ Tàu Vải Đũi', 'ao-so-mi-co-tau-vai-dui', 2, 4, N'Chất đũi nhẹ nhàng, thấm hút', N'Phong cách nhẹ nhàng vintage, thích hợp đi du lịch, đi cà phê.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Trắng Công Sở OxFord', 'ao-so-mi-trang-cong-so-oxford', 2, 4, N'Vải Oxford dày dặn, đứng form', N'Mẫu áo không thể thiếu của phái mạnh khi đi làm hoặc tham gia sự kiện.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Họa Tiết Sọc Kẻ', 'ao-so-mi-hoa-tiet-soc-ke', 3, 4, N'Sọc kẻ thanh lịch trẻ trung', N'Chất vải ít nhăn, dễ ủi, mang lại cảm giác dễ chịu cả ngày.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Sơ Mi Denim Bụi Bặm', 'ao-so-mi-denim-bui-bam', 2, 4, N'Phong cách bò nam tính', N'Vải denim mềm vừa phải, có thể mặc khoác ngoài hoặc mặc trơn.', 'ACTIVE', GETDATE(), GETDATE()),

-- Nhóm Quần Jean (Category 5, Brand 2: Routine)
(N'Quần Jean Đen Trơn Dáng Baggy', 'quan-jean-den-tron-dang-baggy', 2, 5, N'Dáng baggy thoải mái vận động', N'Phù hợp cho cả nam và nữ, chất bò dày dặn, không ra màu.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Rách Gối Cá Tính', 'quan-jean-rach-goi-ca-tinh', 2, 5, N'Điểm nhấn rách gối trẻ trung', N'Sản phẩm dành cho các bạn trẻ yêu thích sự phá cách, bụi bặm.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Co Giãn Màu Xám Khói', 'quan-jean-co-gian-mau-xam-khoi', 2, 5, N'Màu xám khói trendy dễ phối', N'Sự kết hợp hoàn hảo giữa cotton và spandex tạo độ co giãn tối đa.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jean Nam Dáng Đứng Regular', 'quan-jean-nam-dang-dung-regular', 3, 5, N'Ống đứng cổ điển, lịch sự', N'Thích hợp cho độ tuổi trưởng thành, mặc đi làm, đi chơi đều hợp.', 'ACTIVE', GETDATE(), GETDATE()),

-- Các trang phục thu đông / thể thao bổ sung (Category 3, 4, 5 làm mẫu)
(N'Áo Khoác Gió Chống Nước', 'ao-khoac-gio-chong-nuoc', 3, 3, N'Chống mưa nhẹ và cản gió tốt', N'Công nghệ vải dù cao cấp từ Nhật Bản, có túi trong tiện lợi.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Hoodie Nỉ Bông Mùa Đông', 'ao-hoodie-ni-bong-mua-dong', 1, 3, N'Nỉ bông dày dặn siêu ấm áp', N'Form áo local brand rộng rãi, bo chun tay chắc chắn.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Short Kaki Đi Biển', 'quan-short-kaki-di-bien', 2, 5, N'Chất kaki mềm, nhiều màu sắc', N'Chiều dài ngang đùi trẻ trung, cạp chun co giãn dễ chịu.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Tanktop Nam Sát Nách Gym', 'ao-tanktop-nam-sat-nach-gym', 1, 3, N'Thiết kế khoét sâu thể thao', N'Vải thun lạnh siêu mát, thoát mồ hôi chỉ trong vài giây.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Tây Âu Công Sở Nam', 'quan-tay-au-cong-so-nam', 2, 5, N'Chất vải tuyết mưa đứng dáng', N'Có tăng cạp thông minh, thích hợp phối cùng áo sơ mi.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Blazer Nam Hàn Quốc', 'ao-blazer-nam-han-quoc', 2, 4, N'Form rộng phong cách lãng tử', N'Vải có lót trong mịn màng, thích hợp mặc mùa thu đông.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Áo Len Cổ Lọ Giữ Nhiệt', 'ao-len-co-lo-giu-nhiet', 3, 3, N'Sợi len dệt tăm co giãn tốt', N'Giữ ấm cổ rất tốt, ôm sát cơ thể tôn đường nét nam tính.', 'ACTIVE', GETDATE(), GETDATE()),
(N'Quần Jogger Thể Thao Năng Động', 'quan-jogger-the-thao-nang-dong', 1, 5, N'Chất nỉ chân cua cao cấp', N'Thích hợp mặc ở nhà, đi tập hoặc dạo phố cuối tuần.', 'ACTIVE', GETDATE(), GETDATE());
GO


-- =========================================================================
-- 6. BIẾN THỂ SẢN PHẨM (PRODUCT VARIANT / SKU) - [Từ seed_account gốc]
-- =========================================================================
-- Biến thể của Sản phẩm 1
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES 
(1, 'CM-TSHIRT-BLK-M', 90000, 189000, 50, 'ACTIVE'),
(1, 'CM-TSHIRT-BLK-L', 90000, 189000, 45, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-M', 90000, 189000, 30, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-L', 90000, 189000, 0, 'ACTIVE');

-- Biến thể của Sản phẩm 2
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES 
(2, 'RT-JEAN-BLU-30', 250000, 450000, 20, 'ACTIVE'),
(2, 'RT-JEAN-BLU-31', 250000, 450000, 15, 'ACTIVE');

-- Ánh xạ giá trị thuộc tính cho biến thể của SP 1 và 2 (Giả định Variant ID từ 1 đến 6)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES 
(1, 1, N'Đen'), (1, 2, 'M'),
(2, 1, N'Đen'), (2, 2, 'L'),
(3, 1, N'Trắng'), (3, 2, 'M'),
(4, 1, N'Trắng'), (4, 2, 'L'),
(5, 1, N'Xanh Khói'), (5, 2, '30'),
(6, 1, N'Xanh Khói'), (6, 2, '31');


-- =========================================================================
-- 7. QUẢN LÝ HÌNH ẢNH SẢN PHẨM (PRODUCT IMAGE) - [Chuẩn hóa định dạng file .jpg]
-- =========================================================================
-- Ảnh của sản phẩm 1 và 2 (Ảnh cũ từ seed_account gốc giữ nguyên)
INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES 
(1, 'ao_thun_den_front.png', 1, 0),
(1, 'ao_thun_den_back.png', 0, 1),
(1, 'ao_thun_trang_front.png', 0, 2),
(2, 'quan_jean_xanh_front.png', 1, 0);

-- Ảnh của 20 sản phẩm mới bổ sung (Chuẩn hóa .jpg trùng khớp với tệp thực tế của bạn)
INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES 
(3, 'prod3-main.jpg', 1, 0), (3, 'prod3-detail1.jpg', 0, 1),
(4, 'prod4-main.jpg', 1, 0),
(5, 'prod5-main.jpg', 1, 0), (5, 'prod5-detail1.jpg', 0, 1),
(6, 'prod6-main.jpg', 1, 0),
(7, 'prod7-main.jpg', 1, 0), (7, 'prod7-detail1.jpg', 0, 1),
(8, 'prod8-main.jpg', 1, 0),
(9, 'prod9-main.jpg', 1, 0), (9, 'prod9-detail1.jpg', 0, 1),
(10, 'prod10-main.jpg', 1, 0),
(11, 'prod11-main.jpg', 1, 0), (11, 'prod11-detail1.jpg', 0, 1),
(12, 'prod12-main.jpg', 1, 0),
(13, 'prod13-main.jpg', 1, 0), (13, 'prod13-detail1.jpg', 0, 1),
(14, 'prod14-main.jpg', 1, 0),
(15, 'prod15-main.jpg', 1, 0), (15, 'prod15-detail1.jpg', 0, 1),
(16, 'prod16-main.jpg', 1, 0),
(17, 'prod17-main.jpg', 1, 0), (17, 'prod17-detail1.jpg', 0, 1),
(18, 'prod18-main.jpg', 1, 0),
(19, 'prod19-main.jpg', 1, 0), (19, 'prod19-detail1.jpg', 0, 1),
(20, 'prod20-main.jpg', 1, 0),
(21, 'prod21-main.jpg', 1, 0), (21, 'prod21-detail1.jpg', 0, 1),
(22, 'prod22-main.jpg', 1, 0);
GO


-- =========================================================================
-- 8. KHUYẾN MÃI, GIỎ HÀNG & ĐƠN HÀNG MẪU - [Từ seed_account gốc]
-- =========================================================================
INSERT INTO Voucher (code, title, discount_type, discount_value, max_discount_amount, min_order_value, start_date, end_date, usage_limit, used_count) VALUES 
('XINCHAO50', N'Voucher chào mừng thành viên mới', 'FIXED_AMOUNT', 50000, 50000, 150000, '2026-01-01', '2026-12-31', 1000, 5),
('HE2026', N'Khuyến mãi bộ sưu tập hè giảm 10%', 'PERCENTAGE', 10, 30000, 200000, '2026-05-01', '2026-08-31', 500, 12);

INSERT INTO Cart (user_id, variant_id, quantity) VALUES 
(3, 1, 2),  
(3, 5, 1);  

INSERT INTO Shipment (carrier_name, shipping_status, tracking_code, shipping_cost, estimated_delivery_time) VALUES 
(N'Giao Hàng Nhanh (GHN)', 'SHIPPING', 'GHN998877A', 30000, '2026-06-05');

INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note) VALUES 
('SHOP-20260601-001', 3, 1, 1, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 639000, 50000, 30000, 619000, 'SHIPPING', N'Giao giờ hành chính giúp em');

INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price) VALUES 
(1, 1, N'Áo Thun Nam Cotton Compact', N'Color: Đen, Size: M', 1, 189000),
(1, 5, N'Quần Jean Nam Dáng Slimfit', N'Color: Xanh Khói, Size: 30', 1, 450000);

INSERT INTO Payment (order_id, payment_method, payment_status, amount, transaction_reference, payment_date) VALUES 
(1, 'VNPAY', 'PAID', 619000, 'VNPAY123456789', '2026-06-01 08:30:00');

INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) VALUES 
(1, 2, 50, 'IMPORT', N'Nhập lô hàng áo thun đen M đầu mùa hè'),
(5, 2, 20, 'IMPORT', N'Nhập lô hàng quần jean dáng slimfit size 30');

INSERT INTO Feedback (user_id, product_id, order_id, rating, comment, status) VALUES 
(4, 1, NULL, 5, N'Áo mặc mát lắm, giặt không bị xù lông, sẽ ủng hộ shop tiếp!', 1);
GO


