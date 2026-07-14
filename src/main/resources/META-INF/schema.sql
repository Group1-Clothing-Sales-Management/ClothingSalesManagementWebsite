IF DB_ID(N'ClothesShopDB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [ClothesShopDB]');
END
GO
USE [ClothesShopDB];
GO

-- =========================================================================
-- I. PHÂN HỆ ĐỊA GIỚI HÀNH CHÍNH (Sẵn sàng tích hợp API Giao hàng GHN/GHTK)
-- =========================================================================

-- 1. Bảng Tỉnh / Thành phố
IF OBJECT_ID(N'dbo.Province', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Province (
    id VARCHAR(20) PRIMARY KEY, -- Có thể dùng mã Code của Tổng cục Thống kê hoặc API (VD: '01' cho Hà Nội)
    province_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30) -- Thành phố TW, Tỉnh
);
END

-- 2. Bảng Quận / Huyện
IF OBJECT_ID(N'dbo.District', N'U') IS NULL
BEGIN
CREATE TABLE dbo.District (
    id VARCHAR(20) PRIMARY KEY,
    district_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30),
    province_id VARCHAR(20) FOREIGN KEY REFERENCES Province(id)
);
END

-- 3. Bảng Phường / Xã / Thị trấn
IF OBJECT_ID(N'dbo.Ward', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Ward (
    id VARCHAR(20) PRIMARY KEY,
    ward_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30),
    district_id VARCHAR(20) FOREIGN KEY REFERENCES District(id)
);
END


-- =========================================================================
-- II. PHÂN HỆ TÀI KHOẢN & PHÂN QUYỀN
-- =========================================================================

-- 4. Bảng Role
IF OBJECT_ID(N'dbo.Role', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Role (
    id INT IDENTITY(1,1) PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE, -- ADMIN, CUSTOMER, STAFF, MANAGER
    description NVARCHAR(255)
);
END

-- 5. Bảng User
IF OBJECT_ID(N'dbo.User', N'U') IS NULL
BEGIN
CREATE TABLE dbo.[User] (
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
END

-- 6. Bảng Sổ địa chỉ người dùng (Một user có nhiều địa chỉ)
IF OBJECT_ID(N'dbo.User_Address', N'U') IS NULL
BEGIN
CREATE TABLE dbo.User_Address (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    recipient_name NVARCHAR(100) NOT NULL, -- Tên người nhận (có thể mua hộ người khác)
    recipient_phone VARCHAR(15) NOT NULL,   -- Số điện thoại người nhận
    ward_id VARCHAR(20) FOREIGN KEY REFERENCES Ward(id), -- Từ đây JOIN ra District và Province
    address_detail NVARCHAR(255) NOT NULL,  -- Số nhà, tên đường, thôn/xóm
    is_default BIT DEFAULT 0 -- 1: Địa chỉ mặc định
);
END

-- 7. Bảng Token bảo mật (Dùng chung cho cả Reset Pass và Verify Email)
IF OBJECT_ID(N'dbo.Security_Token', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Security_Token (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    token_type VARCHAR(30) NOT NULL, -- RESET_PASSWORD, EMAIL_VERIFICATION
    token_value VARCHAR(255) NOT NULL UNIQUE,
    expiry_date DATETIME NOT NULL,
    is_used BIT DEFAULT 0
);
END

-- 8. Bảng Nhật ký hệ thống
IF OBJECT_ID(N'dbo.Activity_Log', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Activity_Log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL, -- LOGIN, UPDATE_PROFILE, PLACE_ORDER...
    description NVARCHAR(MAX),
    ip_address VARCHAR(45),
    created_at DATETIME DEFAULT GETDATE()
);
END


-- =========================================================================
-- III. PHÂN HỆ SẢN PHẨM & KHO HÀNG (Mô hình EAV linh hoạt, không sợ đổi ngành hàng)
-- =========================================================================

-- 9. Bảng Thương hiệu
IF OBJECT_ID(N'dbo.Brand', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Brand (
    id INT IDENTITY(1,1) PRIMARY KEY,
    brand_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE, -- Phục vụ SEO URL đẹp (VD: 'nike-store')
    description NVARCHAR(MAX),
    logo_url VARCHAR(255)
);
END

-- 10. Bảng Danh mục (Hỗ trợ danh mục đa cấp - Đệ quy)
IF OBJECT_ID(N'dbo.Category', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Category (
    id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    parent_id INT FOREIGN KEY REFERENCES Category(id), -- Thư mục cha (VD: Áo -> Áo Sơ Mi -> Áo Sơ Mi Hàn Quốc)
    description NVARCHAR(MAX),
    status BIT DEFAULT 1
);
END

-- 11. Bảng Sản phẩm (Thông tin cốt lõi)
IF OBJECT_ID(N'dbo.Product', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Product (
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
END

-- 12. Bảng Hình ảnh sản phẩm
IF OBJECT_ID(N'dbo.Product_Image', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Product_Image (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES Product(id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    is_main BIT DEFAULT 0, -- 1: Ảnh đại diện hiển thị ở danh sách
    sort_order INT DEFAULT 0 -- Thứ tự sắp xếp ảnh khi slide
);
END

-- 13. Bảng Biến thể sản phẩm (Mỗi bản ghi là một SKU thực tế trong kho)
IF OBJECT_ID(N'dbo.Product_Variant', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Product_Variant (
    id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES Product(id) ON DELETE CASCADE,
    sku VARCHAR(50) NOT NULL UNIQUE, -- Mã quản lý kho (VD: PREMIUM-JEAN-M-BLUE)
    cost_price DECIMAL(18,2) NOT NULL, -- Giá vốn nhập vào (để tính lợi nhuận gộp sau này)
    sale_price DECIMAL(18,2) NOT NULL, -- Giá bán niêm yết
    stock_quantity INT NOT NULL DEFAULT 0,
    status VARCHAR(30) DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE
    color NVARCHAR(100) NULL,
    size NVARCHAR(100) NULL
);
END

-- 14. Bảng Thuộc tính (Size, Color, Material...)
IF OBJECT_ID(N'dbo.Attribute', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Attribute (
    id INT IDENTITY(1,1) PRIMARY KEY,
    attribute_name NVARCHAR(100) NOT NULL UNIQUE
);
END

-- 15. Bảng Giá trị thuộc tính của từng Biến thể (Cầu nối m-n)
IF OBJECT_ID(N'dbo.Variant_Attribute_Value', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Variant_Attribute_Value (
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    attribute_id INT FOREIGN KEY REFERENCES Attribute(id),
    attribute_value NVARCHAR(100) NOT NULL, -- VD: 'L', 'XL' hoặc 'Đỏ', 'Đen'
    PRIMARY KEY (variant_id, attribute_id)
);
END

-- 16. Bảng Nhật ký kho hàng (Theo dõi chặt chẽ dòng chảy của hàng hóa)
IF OBJECT_ID(N'dbo.Inventory_Log', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Inventory_Log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    user_id INT FOREIGN KEY REFERENCES [User](id), -- Nhân viên thực hiện
    change_quantity INT NOT NULL, -- Số lượng biến động (Nhập kho: +50, Bán hàng: -2)
    transaction_type VARCHAR(50) NOT NULL, -- IMPORT (Nhập kho), EXPORT_SALE (Bán hàng), EXPORT_CANCEL (Hàng lỗi/hủy)
    note NVARCHAR(500), -- Ghi chú lý do hoặc mã đơn hàng liên quan
    created_at DATETIME DEFAULT GETDATE()
);
END


-- =========================================================================
-- IV. PHÂN HỆ GIỎ HÀNG, KHUYẾN MÃI & ĐƠN HÀNG
-- =========================================================================

-- 17. Bảng Giỏ hàng (Lưu trực tiếp DB để đồng bộ trên mọi thiết bị khi User đăng nhập)
IF OBJECT_ID(N'dbo.Cart', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Cart (
    user_id INT FOREIGN KEY REFERENCES [User](id) ON DELETE CASCADE,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (user_id, variant_id)
);
END

-- 18. Bang san pham yeu thich
IF OBJECT_ID(N'dbo.Wishlist', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Wishlist (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_Wishlist PRIMARY KEY (user_id, product_id),
    CONSTRAINT FK_Wishlist_User FOREIGN KEY (user_id)
        REFERENCES [User](id) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlist_Product FOREIGN KEY (product_id)
        REFERENCES Product(id) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlist_Variant FOREIGN KEY (variant_id)
        REFERENCES Product_Variant(id)
);
END

IF OBJECT_ID(N'dbo.Wishlist', N'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.indexes
       WHERE name = N'IX_Wishlist_Variant'
         AND object_id = OBJECT_ID(N'dbo.Wishlist')
   )
BEGIN
    CREATE INDEX IX_Wishlist_Variant ON dbo.Wishlist(variant_id);
END

-- 18. Bảng Mã giảm giá
IF OBJECT_ID(N'dbo.Voucher', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Voucher (
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
END

-- 19. Bảng Đơn vị & Thông tin vận chuyển
IF OBJECT_ID(N'dbo.Shipment', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Shipment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    carrier_name NVARCHAR(100) NOT NULL, -- GHN, GHTK, Tự giao hàng...
    shipping_status VARCHAR(50) NOT NULL, -- PENDING_PICKUP, SHIPPING, DELIVERED, FAILED
    tracking_code VARCHAR(100) NULL, -- Mã vận đơn của bên vận chuyển để khách tra cứu
    shipping_cost DECIMAL(18,2) DEFAULT 0,
    estimated_delivery_time DATETIME NULL
);
END

-- 20. Bảng Đơn hàng (Đóng băng toàn bộ thông tin tại thời điểm mua)
IF OBJECT_ID(N'dbo.Order', N'U') IS NULL
BEGIN
CREATE TABLE dbo.[Order] (
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
END

-- 21. Bảng Chi tiết đơn hàng
IF OBJECT_ID(N'dbo.Order_Detail', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Order_Detail (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES [Order](id) ON DELETE CASCADE,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE SET NULL, -- Biến thể xóa vẫn lưu log mua bán
    
    -- Đóng băng thông tin sản phẩm lúc mua (tránh việc sửa giá/tên sản phẩm làm sai lệch hóa đơn cũ)
    product_name_snapshot NVARCHAR(200) NOT NULL,
    variant_attributes_snapshot NVARCHAR(255) NULL, -- VD: "Size: L, Color: Red"
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(18,2) NOT NULL -- Giá bán thực tế tại thời điểm mua
);
END

-- 22. Bảng Thanh toán
IF OBJECT_ID(N'dbo.Payment', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Payment (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES [Order](id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL, -- COD, VNPAY, MOMO, BANK_TRANSFER
    payment_status VARCHAR(50) DEFAULT 'UNPAID', -- UNPAID, PAID, REFUNDED, FAILED
    amount DECIMAL(18,2) NOT NULL,
    transaction_reference VARCHAR(100) NULL, -- Mã giao dịch trả về từ ngân hàng/VNPAY (rất quan trọng đối soát)
    payment_date DATETIME NULL
);
END

-- 23. Bảng Đánh giá & Bình luận
IF OBJECT_ID(N'dbo.Feedback', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Feedback (
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
END
GO



-- Phần thêm bảng vào 
-- nếu có thay đổi ae phải add vào DB 

-- Thêm bảng mới phục vụ quản lý lô hàng theo cơ chế FIFO
IF OBJECT_ID(N'dbo.Product_Batch', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Product_Batch (
    id INT IDENTITY(1,1) PRIMARY KEY,
    variant_id INT FOREIGN KEY REFERENCES Product_Variant(id) ON DELETE CASCADE,
    batch_code VARCHAR(50) NOT NULL, -- Ví dụ: BATCH-20260611-01
    cost_price DECIMAL(18,2) NOT NULL, -- Giá vốn nhập riêng của lô này
    sale_price DECIMAL(18,2) NOT NULL, -- Giá bán riêng của lô này
    initial_quantity INT NOT NULL, -- Số lượng nhập ban đầu
    current_quantity INT NOT NULL, -- Số lượng còn lại (Sẽ trừ dần về 0 theo FIFO)
    import_receipt_id INT NULL,
    import_receipt_detail_id INT NULL,
    created_at DATETIME DEFAULT GETDATE() -- Sắp xếp theo thời gian tăng dần để tìm lô cũ nhất
);
END

-- =========================================================================
-- V. QUẢN LÝ PHIẾU NHẬP KHO
--
-- The inventory feature was added after the original schema. Keep this
-- section idempotent so it also upgrades an existing ClothesShopDB.
-- =========================================================================

IF OBJECT_ID(N'dbo.Supplier', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Supplier (
        id INT IDENTITY(1,1) PRIMARY KEY,
        supplier_name NVARCHAR(200) NOT NULL,
        phone VARCHAR(30) NULL,
        address NVARCHAR(500) NULL,
        status BIT NOT NULL DEFAULT 1
    );
END

IF OBJECT_ID(N'dbo.Import_Receipt', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Import_Receipt (
        id INT IDENTITY(1,1) PRIMARY KEY,
        receipt_code VARCHAR(60) NOT NULL UNIQUE,
        supplier_id INT NULL,
        user_id INT NULL,
        total_amount DECIMAL(18,2) NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
        note NVARCHAR(500) NULL,
        vendor_reference NVARCHAR(100) NULL,
        confirmed_by INT NULL,
        confirmed_at DATETIME NULL
    );
END

IF COL_LENGTH(N'dbo.Import_Receipt', N'note') IS NULL
    ALTER TABLE dbo.Import_Receipt ADD note NVARCHAR(500) NULL;

IF COL_LENGTH(N'dbo.Import_Receipt', N'vendor_reference') IS NULL
    ALTER TABLE dbo.Import_Receipt ADD vendor_reference NVARCHAR(100) NULL;

IF COL_LENGTH(N'dbo.Import_Receipt', N'confirmed_by') IS NULL
    ALTER TABLE dbo.Import_Receipt ADD confirmed_by INT NULL;

IF COL_LENGTH(N'dbo.Import_Receipt', N'confirmed_at') IS NULL
    ALTER TABLE dbo.Import_Receipt ADD confirmed_at DATETIME NULL;

IF OBJECT_ID(N'dbo.Import_Receipt_Detail', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Import_Receipt_Detail (
        id INT IDENTITY(1,1) PRIMARY KEY,
        import_receipt_id INT NOT NULL,
        variant_id INT NOT NULL,
        quantity INT NOT NULL CHECK (quantity > 0),
        unit_cost DECIMAL(18,2) NOT NULL,
        line_total DECIMAL(18,2) NOT NULL
    );
END

IF COL_LENGTH(N'dbo.Product_Variant', N'color') IS NULL
    ALTER TABLE dbo.Product_Variant ADD color NVARCHAR(100) NULL;

IF COL_LENGTH(N'dbo.Product_Variant', N'size') IS NULL
    ALTER TABLE dbo.Product_Variant ADD size NVARCHAR(100) NULL;

IF COL_LENGTH(N'dbo.Product_Batch', N'import_receipt_id') IS NULL
    ALTER TABLE dbo.Product_Batch ADD import_receipt_id INT NULL;

IF COL_LENGTH(N'dbo.Product_Batch', N'import_receipt_detail_id') IS NULL
    ALTER TABLE dbo.Product_Batch ADD import_receipt_detail_id INT NULL;

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Import_Receipt_Supplier'
      AND parent_object_id = OBJECT_ID(N'dbo.Import_Receipt')
)
BEGIN
    ALTER TABLE dbo.Import_Receipt
        ADD CONSTRAINT FK_Import_Receipt_Supplier
        FOREIGN KEY (supplier_id) REFERENCES dbo.Supplier(id);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Import_Receipt_User'
      AND parent_object_id = OBJECT_ID(N'dbo.Import_Receipt')
)
BEGIN
    ALTER TABLE dbo.Import_Receipt
        ADD CONSTRAINT FK_Import_Receipt_User
        FOREIGN KEY (user_id) REFERENCES dbo.[User](id);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Import_Receipt_Confirmer'
      AND parent_object_id = OBJECT_ID(N'dbo.Import_Receipt')
)
BEGIN
    ALTER TABLE dbo.Import_Receipt
        ADD CONSTRAINT FK_Import_Receipt_Confirmer
        FOREIGN KEY (confirmed_by) REFERENCES dbo.[User](id);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Import_Receipt_Detail_Receipt'
      AND parent_object_id = OBJECT_ID(N'dbo.Import_Receipt_Detail')
)
BEGIN
    ALTER TABLE dbo.Import_Receipt_Detail
        ADD CONSTRAINT FK_Import_Receipt_Detail_Receipt
        FOREIGN KEY (import_receipt_id)
        REFERENCES dbo.Import_Receipt(id) ON DELETE CASCADE;
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Import_Receipt_Detail_Variant'
      AND parent_object_id = OBJECT_ID(N'dbo.Import_Receipt_Detail')
)
BEGIN
    ALTER TABLE dbo.Import_Receipt_Detail
        ADD CONSTRAINT FK_Import_Receipt_Detail_Variant
        FOREIGN KEY (variant_id) REFERENCES dbo.Product_Variant(id);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Product_Batch_Import_Receipt'
      AND parent_object_id = OBJECT_ID(N'dbo.Product_Batch')
)
BEGIN
    ALTER TABLE dbo.Product_Batch
        ADD CONSTRAINT FK_Product_Batch_Import_Receipt
        FOREIGN KEY (import_receipt_id) REFERENCES dbo.Import_Receipt(id);
END

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_Product_Batch_Import_Receipt_Detail'
      AND parent_object_id = OBJECT_ID(N'dbo.Product_Batch')
)
BEGIN
    ALTER TABLE dbo.Product_Batch
        ADD CONSTRAINT FK_Product_Batch_Import_Receipt_Detail
        FOREIGN KEY (import_receipt_detail_id)
        REFERENCES dbo.Import_Receipt_Detail(id);
END
