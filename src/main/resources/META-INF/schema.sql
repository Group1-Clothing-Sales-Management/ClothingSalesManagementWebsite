CREATE DATABASE ClothesShopDB;
GO
USE ClothesShopDB;
GO

-- =========================================================================
-- I. PHÂN HỆ ĐỊA GIỚI HÀNH CHÍNH (Sẵn sàng tích hợp API Giao hàng GHN/GHTK)
-- =========================================================================

-- 1. Bảng Tỉnh / Thành phố
CREATE TABLE Province (
    id VARCHAR(20) PRIMARY KEY, -- Có thể dùng mã Code của Tổng cục Thống kê hoặc API (VD: '01' cho Hà Nội)
    province_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30) -- Thành phố TW, Tỉnh
);

-- 2. Bảng Quận / Huyện
CREATE TABLE District (
    id VARCHAR(20) PRIMARY KEY,
    district_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30),
    province_id VARCHAR(20) FOREIGN KEY REFERENCES Province(id)
);

-- 3. Bảng Phường / Xã / Thị trấn
CREATE TABLE Ward (
    id VARCHAR(20) PRIMARY KEY,
    ward_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30),
    district_id VARCHAR(20) FOREIGN KEY REFERENCES District(id)
);


-- =========================================================================
-- II. PHÂN HỆ TÀI KHOẢN & PHÂN QUYỀN
-- =========================================================================

-- 4. Bảng Role
CREATE TABLE Role (
    id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE, -- ADMIN, CUSTOMER, STAFF, MANAGER
    description NVARCHAR(255)
);

-- 5. Bảng User
CREATE TABLE [User] (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Lưu hash password (BCrypt/SCrypt)
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NULL,
    avatar_url VARCHAR(255) NULL,
    status VARCHAR(30) DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE, LOCKED
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    role_id INT FOREIGN KEY REFERENCES Role(id)
);

-- 6. Bảng Sổ địa chỉ người dùng (Một user có nhiều địa chỉ)
CREATE TABLE User_Address (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    recipient_name NVARCHAR(100) NOT NULL, -- Tên người nhận (có thể mua hộ người khác)
    recipient_phone VARCHAR(15) NOT NULL,   -- Số điện thoại người nhận
    ward_id VARCHAR(20) FOREIGN KEY REFERENCES Ward(id), -- Từ đây JOIN ra District và Province
    address_detail NVARCHAR(255) NOT NULL,  -- Số nhà, tên đường, thôn/xóm
    is_default BIT DEFAULT 0 -- 1: Địa chỉ mặc định
);

-- 7. Bảng Token bảo mật (Dùng chung cho cả Reset Pass và Verify Email)
CREATE TABLE Security_Token (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    token_type VARCHAR(30) NOT NULL, -- RESET_PASSWORD, EMAIL_VERIFICATION
    token_value VARCHAR(255) NOT NULL UNIQUE,
    expiry_date DATETIME NOT NULL,
    is_used BIT DEFAULT 0
);

-- 8. Bảng Nhật ký hệ thống
CREATE TABLE Activity_Log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL, -- LOGIN, UPDATE_PROFILE, PLACE_ORDER...
    description NVARCHAR(MAX),
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT GETDATE()
);


-- =========================================================================
-- III. PHÂN HỆ SẢN PHẨM & KHO HÀNG (Mô hình EAV linh hoạt, không sợ đổi ngành hàng)
-- =========================================================================

-- 9. Bảng Thương hiệu
CREATE TABLE Brand (
    id INT IDENTITY(1,1) PRIMARY KEY,
    brand_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE, -- Phục vụ SEO URL đẹp (VD: 'nike-store')
    description NVARCHAR(MAX),
    logo_url VARCHAR(255)
);

-- 10. Bảng Danh mục (Hỗ trợ danh mục đa cấp - Đệ quy)
CREATE TABLE Category (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    parent_id INT FOREIGN KEY REFERENCES Category(id), -- Thư mục cha (VD: Áo -> Áo Sơ Mi -> Áo Sơ Mi Hàn Quốc)
    description NVARCHAR(MAX),
    status BIT DEFAULT 1
);

-- 11. Bảng Sản phẩm (Thông tin cốt lõi)
CREATE TABLE Product (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_name NVARCHAR(200) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    brand_id INT FOREIGN KEY REFERENCES Brand(id),
    category_id INT FOREIGN KEY REFERENCES Category(id),
    short_description NVARCHAR(500),
    long_description NVARCHAR(MAX),
    status VARCHAR(30) DEFAULT 'DRAFT', -- DRAFT, ACTIVE, OUT_OF_STOCK, HIDDEN
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 12. Bảng Hình ảnh sản phẩm
CREATE TABLE Product_Image (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES Product(id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    is_main BIT DEFAULT 0, -- 1: Ảnh đại diện hiển thị ở danh sách
    sort_order INT DEFAULT 0 -- Thứ tự sắp xếp ảnh khi slide
);

-- 13. Bảng Biến thể sản phẩm (Mỗi bản ghi là một SKU thực tế trong kho)
CREATE TABLE Product_Variant (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES Product(id) ON DELETE CASCADE,
    sku VARCHAR(50) NOT NULL UNIQUE, -- Mã quản lý kho (VD: PREMIUM-JEAN-M-BLUE)
    cost_price DECIMAL(18,2) NOT NULL, -- Giá vốn nhập vào (để tính lợi nhuận gộp sau này)
    sale_price DECIMAL(18,2) NOT NULL, -- Giá bán niêm yết
    stock_quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(30) DEFAULT 'ACTIVE' -- ACTIVE, INACTIVE
);

-- 14. Bảng Thuộc tính (Size, Color, Material...)
CREATE TABLE Attribute (
    id INT IDENTITY(1,1) PRIMARY KEY,
    attribute_name NVARCHAR(100) NOT NULL UNIQUE
);

-- 15. Bảng Giá trị thuộc tính của từng Biến thể (Cầu nối m-n)
CREATE TABLE Variant_Attribute_Value (
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    attribute_id INT FOREIGN KEY REFERENCES Attribute(id),
    attribute_value NVARCHAR(100) NOT NULL, -- VD: 'L', 'XL' hoặc 'Đỏ', 'Đen'
    PRIMARY KEY (variant_id, attribute_id)
);

-- 16. Bảng Nhật ký kho hàng (Theo dõi chặt chẽ dòng chảy của hàng hóa)
CREATE TABLE Inventory_Log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    user_id INT FOREIGN KEY REFERENCES [User](id), -- Nhân viên thực hiện
    change_quantity INT NOT NULL, -- Số lượng biến động (Nhập kho: +50, Bán hàng: -2)
    transaction_type VARCHAR(50) NOT NULL, -- IMPORT (Nhập kho), EXPORT_SALE (Bán hàng), EXPORT_CANCEL (Hàng lỗi/hủy)
    note NVARCHAR(500), -- Ghi chú lý do hoặc mã đơn hàng liên quan
    created_at DATETIME DEFAULT GETDATE()
);


-- =========================================================================
-- IV. PHÂN HỆ GIỎ HÀNG, KHUYẾN MÃI & ĐƠN HÀNG
-- =========================================================================

-- 17. Bảng Giỏ hàng (Lưu trực tiếp DB để đồng bộ trên mọi thiết bị khi User đăng nhập)
CREATE TABLE Cart (
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, variant_id)
);

-- 18. Bảng Mã giảm giá
CREATE TABLE Voucher (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    title NVARCHAR(200) NOT NULL,
    discount_type VARCHAR(20) NOT NULL, -- PERCENTAGE (giảm %), FIXED_AMOUNT (giảm tiền thẳng)
    discount_value DECIMAL(18,2) NOT NULL,
    max_discount_amount DECIMAL(18,2) NULL, -- Giảm tối đa bao nhiêu tiền (áp dụng cho giảm %)
    min_order_value DECIMAL(18,2) DEFAULT 0, -- Đơn hàng tối thiểu bao nhiêu thì được áp dụng
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    usage_limit INT NOT NULL, -- Tổng lượt sử dụng tối đa của voucher này
    used_count INT DEFAULT 0 -- Số lượt đã dùng
);

-- 19. Bảng Đơn vị & Thông tin vận chuyển
CREATE TABLE Shipment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    carrier_name NVARCHAR(100) NOT NULL, -- GHN, GHTK, Tự giao hàng...
    shipping_status VARCHAR(50) NOT NULL, -- PENDING_PICKUP, SHIPPING, DELIVERED, FAILED
    tracking_code VARCHAR(100) NULL, -- Mã vận đơn của bên vận chuyển để khách tra cứu
    shipping_cost DECIMAL(18,2) DEFAULT 0,
    estimated_delivery_time DATETIME NULL
);

-- 20. Bảng Đơn hàng (Đóng băng toàn bộ thông tin tại thời điểm mua)
CREATE TABLE [Order] (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_code VARCHAR(50) NOT NULL UNIQUE, -- Mã đơn hàng hiển thị trực quan (VD: SHOP-20260601-001)
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE SET NULL, -- User xóa thì đơn hàng vẫn giữ lại để làm báo cáo
    voucher_id INT FOREIGN KEY REFERENCES Voucher(id),
    shipment_id INT FOREIGN KEY REFERENCES Shipment(id),
    
    -- Đóng băng thông tin nhận hàng phòng trường hợp User đổi địa chỉ trong tương lai
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    ward_id VARCHAR(20) FOREIGN KEY REFERENCES Ward(id),
    address_detail NVARCHAR(255) NOT NULL,
    
    -- Tính toán số tiền
    total_items_price DECIMAL(18,2) NOT NULL, -- Tổng tiền hàng trước giảm giá
    discount_amount DECIMAL(18,2) DEFAULT 0,   -- Tiền được giảm từ Voucher
    shipping_fee DECIMAL(18,2) DEFAULT 0,      -- Phí vận chuyển thực tế
    total_payment DECIMAL(18,2) NOT NULL,      -- Số tiền cuối cùng khách phải trả = (Total - Discount + Shipping)
    
    order_status VARCHAR(50) DEFAULT 'PENDING', -- PENDING, CONFIRMED, SHIPPING, DELIVERED, CANCELLED, RETURNED
    note NVARCHAR(500),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

-- 21. Bảng Chi tiết đơn hàng
CREATE TABLE Order_Detail (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES [Order](id) ON DELETE CASCADE,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE SET NULL, -- Biến thể xóa vẫn lưu log mua bán
    
    -- Đóng băng thông tin sản phẩm lúc mua (tránh việc sửa giá/tên sản phẩm làm sai lệch hóa đơn cũ)
    product_name_snapshot NVARCHAR(200) NOT NULL,
    variant_attributes_snapshot NVARCHAR(255) NULL, -- VD: "Size: L, Color: Red"
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(18,2) NOT NULL -- Giá bán thực tế tại thời điểm mua
);

-- 22. Bảng Thanh toán
CREATE TABLE Payment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES [Order](id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL, -- COD, VNPAY, MOMO, BANK_TRANSFER
    payment_status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PAID, REFUNDED, FAILED
    amount DECIMAL(18,2) NOT NULL,
    transaction_reference VARCHAR(100) NULL, -- Mã giao dịch trả về từ ngân hàng/VNPAY (rất quan trọng đối soát)
    payment_date DATETIME NULL
);

-- 23. Bảng Đánh giá & Bình luận
CREATE TABLE Feedback (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id),
    product_id INT FOREIGN KEY REFERENCES Product(id) ON DELETE CASCADE,
    order_id INT FOREIGN KEY REFERENCES [Order](id), -- Xác định xem cơ sở nào khách được đánh giá (đã mua mới được đánh giá)
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment NVARCHAR(MAX),
    status BIT DEFAULT 1, -- 1: Hiện, 0: Ẩn (nếu dính comment thô tục/spam)
    admin_response NVARCHAR(MAX) NULL, -- Phần trả lời từ Staff/Admin
    response_by INT NULL FOREIGN KEY REFERENCES [User](id) ON DELETE SET NULL, -- Ai trả lời feedback này
    responded_at DATETIME NULL, -- Thời gian trả lời gần nhất
    created_at DATETIME DEFAULT GETDATE()
);
GO



-- Phần thêm bảng vào 
-- nếu có thay đổi ae phải add vào DB 

-- Thêm bảng mới phục vụ quản lý lô hàng theo cơ chế FIFO
CREATE TABLE Product_Batch (
    id INT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    batch_code VARCHAR(50) NOT NULL, -- Ví dụ: BATCH-20260611-01
    cost_price DECIMAL(18,2) NOT NULL, -- Giá vốn nhập riêng của lô này
    sale_price DECIMAL(18,2) NOT NULL, -- Giá bán riêng của lô này
    initial_quantity INT NOT NULL, -- Số lượng nhập ban đầu
    current_quantity INT NOT NULL, -- Số lượng còn lại (Sẽ trừ dần về 0 theo FIFO)
    created_at DATETIME DEFAULT GETDATE() -- Sắp xếp theo thời gian tăng dần để tìm lô cũ nhất
);


-- =========================================================================
-- Thêm tabel mới vào DB----
-- =========================================================================

USE ClothesShopDB; 
GO

IF OBJECT_ID('User_Saved_Voucher', 'U') IS NOT NULL 
    DROP TABLE User_Saved_Voucher;
GO

CREATE TABLE User_Saved_Voucher (
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE, 
    voucher_id INT FOREIGN KEY REFERENCES Voucher(id) ON DELETE CASCADE,
    saved_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, voucher_id)
);
GO


DECLARE @i INT = 1;
WHILE @i <= 40
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM [User] WHERE username = 'test_user_' + CAST(@i AS VARCHAR))
    BEGIN
        INSERT INTO [User] (username, password, full_name, email) 
        VALUES ('test_user_' + CAST(@i AS VARCHAR), '123456', 'Test User ' + CAST(@i AS VARCHAR), 'test' + CAST(@i AS VARCHAR) + '@gmail.com');
    END
    SET @i = @i + 1;
END
GO


INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 10 id, 1 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 1);


INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 20 id, 2 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 2);


INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 25 id, 3 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 3);

INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 35 id, 4 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 4);


INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 1 id, 5 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 5);


INSERT INTO User_Saved_Voucher (user_id, voucher_id)
SELECT TOP 5 id, 7 FROM [User] WHERE id NOT IN (SELECT user_id FROM User_Saved_Voucher WHERE voucher_id = 7);
GO

SELECT 
    v.id AS VoucherID,
    v.code AS VoucherCode,
    v.usage_limit AS Total_Limit,
    v.used_count AS Total_Used,
    COUNT(usv.user_id) AS Total_Saved,
    (v.usage_limit - COUNT(usv.user_id)) AS Available_To_Collect
FROM 
    Voucher v
LEFT JOIN 
    User_Saved_Voucher usv ON v.id = usv.voucher_id
GROUP BY 
    v.id, v.code, v.usage_limit, v.used_count
ORDER BY 
    v.id ASC;