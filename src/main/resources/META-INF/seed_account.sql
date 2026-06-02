
USE ClothesShopDB;
GO

-- =========================================================================
-- 1. CHÈN DỮ LIỆU ĐỊA GIỚI HÀNH CHÍNH (Tỉnh, Huyện, Xã mẫu)
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
-- 2. CHÈN DỮ LIỆU PHÂN QUYỀN & TÀI KHOẢN (Mật khẩu mẫu đang để text thô để bạn dễ test)
-- =========================================================================
INSERT INTO Role (role_name, description) VALUES 
('ADMIN', N'Quản trị viên toàn quyền hệ thống'),
('STAFF', N'Nhân viên quản lý kho và đơn hàng'),
('CUSTOMER', N'Khách hàng mua sắm trực tuyến');

INSERT INTO [User] (username, password, full_name, email, phone, status, role_id) VALUES 
('admin01', 'admin123', N'Nguyễn Văn Admin', 'admin@clothesshop.com', '0911223344', 'ACTIVE', 1),
('staff01', 'staff123', N'Trần Thị Nhân Viên', 'staff@clothesshop.com', '0922334455', 'ACTIVE', 2),
('quy_nn', 'customer123', N'Nguyễn Ngọc Quý', 'quynn@gmail.com', '0933445566', 'ACTIVE', 3),
('khachhang02', 'customer123', N'Lê Hoàng Nam', 'namlh@gmail.com', '0944556677', 'ACTIVE', 3);


-- =========================================================================
-- 3. CHÈN SỔ ĐỊA CHỈ NGƯỜI DÙNG
-- =========================================================================
INSERT INTO User_Address (user_id, recipient_name, recipient_phone, ward_id, address_detail, is_default) VALUES 
(3, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 1),
(3, N'Anh Quý (Văn phòng)', '0933445566', '26734', N'Tòa nhà Bitexco, Tầng 15', 0),
(4, N'Lê Hoàng Nam', '0944556677', '00010', N'Số 45 Phố Trúc Bạch', 1);


-- =========================================================================
-- 4. CHÈN DANH MỤC & THƯƠNG HIỆU (Hỗ trợ danh mục đa cấp)
-- =========================================================================
INSERT INTO Brand (brand_name, slug, description, logo_url) VALUES 
('Coolmate', 'coolmate', N'Thương hiệu thời trang nam tối giản', 'coolmate_logo.png'),
('Routine', 'routine', N'Thời trang nam nữ phong cách hằng ngày', 'routine_logo.png'),
('Uniqlo', 'uniqlo', N'Thời trang bán lẻ quốc tế đến từ Nhật Bản', 'uniqlo_logo.png');

-- Thêm danh mục cha trước
INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES 
(N'Áo Nam', 'ao-nam', NULL, N'Các sản phẩm áo dành cho nam', 1),
(N'Quần Nam', 'quan-nam', NULL, N'Các sản phẩm quần dành cho nam', 1);

-- Thêm danh mục con (Cần lấy chính xác ID của danh mục cha vừa tạo, ở đây giả định ID tự tăng là 1 và 2)
INSERT INTO Category (category_name, slug, parent_id, description, status) VALUES 
(N'Áo Thun T-Shirt', 'ao-thun-t-shirt', 1, N'Áo thun cổ tròn, cổ tim nam', 1),
(N'Áo Sơ Mi', 'ao-so-mi', 1, N'Áo sơ mi dài tay, ngắn tay', 1),
(N'Quần Jean Nam', 'quan-jean-nam', 2, N'Quần bò, jean dáng dài', 1);


-- =========================================================================
-- 5. CHÈN THUỘC TÍNH (Bảng lõi của mô hình EAV)
-- =========================================================================
INSERT INTO Attribute (attribute_name) VALUES 
(N'Color'),
(N'Size');


-- =========================================================================
-- 6. CHÈN SẢN PHẨM & CÁC BIẾN THỂ (SKU) CỦA SẢN PHẨM
-- =========================================================================
-- Sản phẩm 1: Áo thun Coolmate
INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status) VALUES 
(N'Áo Thun Nam Cotton Compact', 'ao-thun-nam-cotton-compact', 1, 3, N'Áo thun 100% cotton siêu mát', N'Chất liệu cotton compact bền bỉ gấp 2 lần cotton thường, thấm hút mồ hôi cực tốt thích hợp mặc hằng ngày.', 'ACTIVE');

-- Biến thể của Sản phẩm 1 (Giả định Product_id = 1)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES 
(1, 'CM-TSHIRT-BLK-M', 90000, 189000, 50, 'ACTIVE'),
(1, 'CM-TSHIRT-BLK-L', 90000, 189000, 45, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-M', 90000, 189000, 30, 'ACTIVE'),
(1, 'CM-TSHIRT-WHT-L', 90000, 189000, 0, 'ACTIVE'); -- Hết hàng công nghệ vẫn hiển thị

-- Ánh xạ Thuộc tính cho từng biến thể của Sản phẩm 1 (Giả định Variant_id từ 1 đến 4)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES 
(1, 1, N'Đen'), (1, 2, 'M'),
(2, 1, N'Đen'), (2, 2, 'L'),
(3, 1, N'Trắng'), (3, 2, 'M'),
(4, 1, N'Trắng'), (4, 2, 'L');

-- Sản phẩm 2: Quần Jean Routine
INSERT INTO Product (product_name, slug, brand_id, category_id, short_description, long_description, status) VALUES 
(N'Quần Jean Nam Dáng Slimfit', 'quan-jean-nam-dang-slimfit', 2, 5, N'Quần jean co giãn nhẹ lịch lãm', N'Thiết kế ôm nhẹ tôn dáng, chất liệu jean dày dặn có co giãn giúp thoải mái vận động cả ngày dài.', 'ACTIVE');

-- Biến thể của Sản phẩm 2 (Giả định Product_id = 2)
INSERT INTO Product_Variant (product_id, sku, cost_price, sale_price, stock_quantity, status) VALUES 
(2, 'RT-JEAN-BLU-30', 250000, 450000, 20, 'ACTIVE'),
(2, 'RT-JEAN-BLU-31', 250000, 450000, 15, 'ACTIVE');

-- Ánh xạ Thuộc tính cho biến thể Sản phẩm 2 (Giả định Variant_id là 5 và 6)
INSERT INTO Variant_Attribute_Value (variant_id, attribute_id, attribute_value) VALUES 
(5, 1, N'Xanh Khói'), (5, 2, '30'),
(6, 1, N'Xanh Khói'), (6, 2, '31');


-- =========================================================================
-- 7. CHÈN HÌNH ẢNH SẢN PHẨM
-- =========================================================================
INSERT INTO Product_Image (product_id, image_url, is_main, sort_order) VALUES 
(1, 'ao_thun_den_front.png', 1, 0),
(1, 'ao_thun_den_back.png', 0, 1),
(1, 'ao_thun_trang_front.png', 0, 2),
(2, 'quan_jean_xanh_front.png', 1, 0);


-- =========================================================================
-- 8. CHÈN MÃ GIẢM GIÁ (VOUCHER)
-- =========================================================================
INSERT INTO Voucher (code, title, discount_type, discount_value, max_discount_amount, min_order_value, start_date, end_date, usage_limit, used_count) VALUES 
('XINCHAO50', N'Voucher chào mừng thành viên mới', 'FIXED_AMOUNT', 50000, 50000, 150000, '2026-01-01', '2026-12-31', 1000, 5),
('HE2026', N'Khuyến mãi bộ sưu tập hè giảm 10%', 'PERCENTAGE', 10, 30000, 200000, '2026-05-01', '2026-08-31', 500, 12);


-- =========================================================================
-- 9. GIỎ HÀNG (Mẫu khách hàng QuyNN đang thêm đồ vào giỏ)
-- =========================================================================
INSERT INTO Cart (user_id, variant_id, quantity) VALUES 
(3, 1, 2),  -- Thêm 2 cái Áo thun đen size M
(3, 5, 1);  -- Thêm 1 cái Quần jean xanh size 30


-- =========================================================================
-- 10. PHÂN HỆ ĐƠN HÀNG MẪU (Quy trình mua thành công 1 đơn hàng)
-- =========================================================================

-- Bước A: Tạo thông tin vận chuyển trước
INSERT INTO Shipment (carrier_name, shipping_status, tracking_code, shipping_cost, estimated_delivery_time) VALUES 
(N'Giao Hàng Nhanh (GHN)', 'SHIPPING', 'GHN998877A', 30000, '2026-06-05');

-- Bước B: Tạo đơn hàng (Giả định lấy thông tin từ địa chỉ mặc định của User_id = 3 và Shipment_id = 1, Voucher_id = 1)
INSERT INTO [Order] (order_code, user_id, voucher_id, shipment_id, recipient_name, recipient_phone, ward_id, address_detail, total_items_price, discount_amount, shipping_fee, total_payment, order_status, note) VALUES 
('SHOP-20260601-001', 3, 1, 1, N'Nguyễn Ngọc Quý', '0933445566', '31162', N'Số 123 Đường 3/2', 639000, 50000, 30000, 619000, 'SHIPPING', N'Giao giờ hành chính giúp em');

-- Bước C: Tạo chi tiết đơn hàng (Mua 1 áo thun đen M [giá 189k] và 1 quần jean [giá 450k])
INSERT INTO Order_Detail (order_id, variant_id, product_name_snapshot, variant_attributes_snapshot, quantity, price) VALUES 
(1, 1, N'Áo Thun Nam Cotton Compact', N'Color: Đen, Size: M', 1, 189000),
(1, 5, N'Quần Jean Nam Dáng Slimfit', N'Color: Xanh Khói, Size: 30', 1, 450000);

-- Bước D: Tạo trạng thái thanh toán cho đơn hàng (Khách thanh toán qua VNPAY thành công)
INSERT INTO Payment (order_id, payment_method, payment_status, amount, transaction_reference, payment_date) VALUES 
(1, 'VNPAY', 'PAID', 619000, 'VNPAY123456789', '2026-06-01 08:30:00');


-- =========================================================================
-- 11. NHẬT KÝ KHO & ĐÁNH GIÁ (Bổ trợ kiểm thử tính năng)
-- =========================================================================
-- Log kho lúc nhân viên nhập hàng đầu tháng
INSERT INTO Inventory_Log (variant_id, user_id, change_quantity, transaction_type, note) VALUES 
(1, 2, 50, 'IMPORT', N'Nhập lô hàng áo thun đen M đầu mùa hè'),
(5, 2, 20, 'IMPORT', N'Nhập lô hàng quần jean dáng slimfit size 30');

-- Feedback mẫu từ khách hàng khác (User_id = 4)
INSERT INTO Feedback (user_id, product_id, order_id, rating, comment, status) VALUES 
(4, 1, NULL, 5, N'Áo mặc mát lắm, giặt không bị xù lông, sẽ ủng hộ shop tiếp!', 1);
GO