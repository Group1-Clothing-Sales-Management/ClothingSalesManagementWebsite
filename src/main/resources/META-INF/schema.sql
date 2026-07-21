USE [master];
GO

IF DB_ID(N'ClothesShopDB') IS NOT NULL
BEGIN
    ALTER DATABASE [ClothesShopDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [ClothesShopDB];
END
GO

CREATE DATABASE [ClothesShopDB];
GO

ALTER DATABASE [ClothesShopDB] SET RECOVERY SIMPLE;
GO

USE [ClothesShopDB];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO

/* =========================================================================
   I. ADMINISTRATIVE DIVISIONS
   ========================================================================= */

CREATE TABLE dbo.Province (
    id VARCHAR(20) NOT NULL,
    province_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30) NULL,
    CONSTRAINT PK_Province PRIMARY KEY (id)
);

CREATE TABLE dbo.District (
    id VARCHAR(20) NOT NULL,
    district_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30) NULL,
    province_id VARCHAR(20) NOT NULL,
    CONSTRAINT PK_District PRIMARY KEY (id),
    CONSTRAINT FK_District_Province FOREIGN KEY (province_id)
        REFERENCES dbo.Province(id)
);

CREATE TABLE dbo.Ward (
    id VARCHAR(20) NOT NULL,
    ward_name NVARCHAR(100) NOT NULL,
    type NVARCHAR(30) NULL,
    district_id VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Ward PRIMARY KEY (id),
    CONSTRAINT FK_Ward_District FOREIGN KEY (district_id)
        REFERENCES dbo.District(id)
);
GO

/* =========================================================================
   II. ACCOUNTS AND AUTHORIZATION
   ========================================================================= */

CREATE TABLE dbo.[Role] (
    id INT IDENTITY(1,1) NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    description NVARCHAR(255) NULL,
    CONSTRAINT PK_Role PRIMARY KEY (id),
    CONSTRAINT UQ_Role_Name UNIQUE (role_name)
);

CREATE TABLE dbo.Permission (
    id INT IDENTITY(1,1) NOT NULL,
    permission_code VARCHAR(80) NOT NULL,
    permission_name NVARCHAR(150) NOT NULL,
    description NVARCHAR(500) NULL,
    CONSTRAINT PK_Permission PRIMARY KEY (id),
    CONSTRAINT UQ_Permission_Code UNIQUE (permission_code)
);

CREATE TABLE dbo.Role_Permission (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    CONSTRAINT PK_Role_Permission PRIMARY KEY (role_id, permission_id),
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (role_id)
        REFERENCES dbo.[Role](id) ON DELETE CASCADE,
    CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (permission_id)
        REFERENCES dbo.Permission(id) ON DELETE CASCADE
);

CREATE TABLE dbo.[User] (
    id INT IDENTITY(1,1) NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NULL,
    avatar_url VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_User_Status DEFAULT ('ACTIVE'),
    created_at DATETIME NOT NULL
        CONSTRAINT DF_User_CreatedAt DEFAULT (GETDATE()),
    updated_at DATETIME NOT NULL
        CONSTRAINT DF_User_UpdatedAt DEFAULT (GETDATE()),
    role_id INT NOT NULL,
    CONSTRAINT PK_User PRIMARY KEY (id),
    CONSTRAINT UQ_User_Username UNIQUE (username),
    CONSTRAINT UQ_User_Email UNIQUE (email),
    CONSTRAINT FK_User_Role FOREIGN KEY (role_id)
        REFERENCES dbo.[Role](id)
);

CREATE TABLE dbo.User_Address (
    id INT IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    ward_id VARCHAR(20) NULL,
    address_detail NVARCHAR(255) NOT NULL,
    is_default BIT NOT NULL
        CONSTRAINT DF_UserAddress_Default DEFAULT (0),
    CONSTRAINT PK_User_Address PRIMARY KEY (id),
    CONSTRAINT FK_UserAddress_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE CASCADE,
    CONSTRAINT FK_UserAddress_Ward FOREIGN KEY (ward_id)
        REFERENCES dbo.Ward(id)
);

CREATE TABLE dbo.Security_Token (
    id INT IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    token_type VARCHAR(30) NOT NULL,
    token_value VARCHAR(255) NOT NULL,
    expiry_date DATETIME NOT NULL,
    is_used BIT NOT NULL
        CONSTRAINT DF_SecurityToken_IsUsed DEFAULT (0),
    CONSTRAINT PK_Security_Token PRIMARY KEY (id),
    CONSTRAINT UQ_SecurityToken_Value UNIQUE (token_value),
    CONSTRAINT FK_SecurityToken_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE CASCADE
);

CREATE TABLE dbo.Activity_Log (
    id BIGINT IDENTITY(1,1) NOT NULL,
    user_id INT NULL,
    action_type VARCHAR(50) NOT NULL,
    description NVARCHAR(MAX) NULL,
    ip_address VARCHAR(45) NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_ActivityLog_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Activity_Log PRIMARY KEY (id),
    CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE SET NULL
);
GO

/* =========================================================================
   III. PRODUCT, CATEGORY AND PRICE MANAGEMENT
   ========================================================================= */

CREATE TABLE dbo.Brand (
    id INT IDENTITY(1,1) NOT NULL,
    brand_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    description NVARCHAR(MAX) NULL,
    logo_url VARCHAR(255) NULL,
    CONSTRAINT PK_Brand PRIMARY KEY (id),
    CONSTRAINT UQ_Brand_Slug UNIQUE (slug)
);

CREATE TABLE dbo.Category (
    id INT IDENTITY(1,1) NOT NULL,
    category_name NVARCHAR(100) NOT NULL,
    slug VARCHAR(150) NOT NULL,
    parent_id INT NULL,
    description NVARCHAR(MAX) NULL,
    status BIT NOT NULL
        CONSTRAINT DF_Category_Status DEFAULT (1),
    CONSTRAINT PK_Category PRIMARY KEY (id),
    CONSTRAINT UQ_Category_Slug UNIQUE (slug),
    CONSTRAINT FK_Category_Parent FOREIGN KEY (parent_id)
        REFERENCES dbo.Category(id)
);

CREATE TABLE dbo.Product (
    id INT IDENTITY(1,1) NOT NULL,
    product_name NVARCHAR(200) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    brand_id INT NULL,
    category_id INT NULL,
    short_description NVARCHAR(500) NULL,
    long_description NVARCHAR(MAX) NULL,
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_Product_Status DEFAULT ('DRAFT'),
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Product_CreatedAt DEFAULT (GETDATE()),
    updated_at DATETIME NOT NULL
        CONSTRAINT DF_Product_UpdatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Product PRIMARY KEY (id),
    CONSTRAINT UQ_Product_Slug UNIQUE (slug),
    CONSTRAINT FK_Product_Brand FOREIGN KEY (brand_id)
        REFERENCES dbo.Brand(id),
    CONSTRAINT FK_Product_Category FOREIGN KEY (category_id)
        REFERENCES dbo.Category(id)
);

CREATE TABLE dbo.Product_Image (
    id INT IDENTITY(1,1) NOT NULL,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_main BIT NOT NULL
        CONSTRAINT DF_ProductImage_Main DEFAULT (0),
    sort_order INT NOT NULL
        CONSTRAINT DF_ProductImage_Sort DEFAULT (0),
    CONSTRAINT PK_Product_Image PRIMARY KEY (id),
    CONSTRAINT FK_ProductImage_Product FOREIGN KEY (product_id)
        REFERENCES dbo.Product(id) ON DELETE CASCADE
);

-- Kept temporarily because CustomerProductDAO and CartDAO still query these
-- two legacy tables. Product_Variant.color and size remain the main fields.
CREATE TABLE dbo.Attribute (
    id INT IDENTITY(1,1) NOT NULL,
    attribute_name NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Attribute PRIMARY KEY (id),
    CONSTRAINT UQ_Attribute_Name UNIQUE (attribute_name)
);

CREATE TABLE dbo.Product_Variant (
    id INT IDENTITY(1,1) NOT NULL,
    product_id INT NOT NULL,
    sku VARCHAR(50) NOT NULL,
    cost_price DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_ProductVariant_Cost DEFAULT (0),
    list_price DECIMAL(18,2) NULL,
    sale_price DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_ProductVariant_Sale DEFAULT (0),
    stock_quantity INT NOT NULL
        CONSTRAINT DF_ProductVariant_Stock DEFAULT (0),
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_ProductVariant_Status DEFAULT ('ACTIVE'),
    color NVARCHAR(100) NULL,
    size NVARCHAR(100) NULL,
    price_updated_at DATETIME2 NULL,
    price_updated_by INT NULL,
    CONSTRAINT PK_Product_Variant PRIMARY KEY (id),
    CONSTRAINT UQ_ProductVariant_SKU UNIQUE (sku),
    CONSTRAINT CK_ProductVariant_Cost CHECK (cost_price >= 0),
    CONSTRAINT CK_ProductVariant_ListPrice CHECK (list_price IS NULL OR list_price >= 0),
    CONSTRAINT CK_ProductVariant_SalePrice CHECK (sale_price >= 0),
    CONSTRAINT CK_ProductVariant_Stock CHECK (stock_quantity >= 0),
    CONSTRAINT FK_ProductVariant_Product FOREIGN KEY (product_id)
        REFERENCES dbo.Product(id) ON DELETE CASCADE,
    CONSTRAINT FK_ProductVariant_PriceUser FOREIGN KEY (price_updated_by)
        REFERENCES dbo.[User](id) ON DELETE SET NULL
);

CREATE TABLE dbo.Variant_Attribute_Value (
    variant_id INT NOT NULL,
    attribute_id INT NOT NULL,
    attribute_value NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Variant_Attribute_Value PRIMARY KEY (variant_id, attribute_id),
    CONSTRAINT FK_VariantAttribute_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id) ON DELETE CASCADE,
    CONSTRAINT FK_VariantAttribute_Attribute FOREIGN KEY (attribute_id)
        REFERENCES dbo.Attribute(id)
);

CREATE TABLE dbo.Product_Variant_Price_History (
    id BIGINT IDENTITY(1,1) NOT NULL,
    variant_id INT NULL,
    product_name_snapshot NVARCHAR(255) NOT NULL,
    sku_snapshot VARCHAR(50) NOT NULL,
    color_snapshot NVARCHAR(100) NULL,
    size_snapshot NVARCHAR(100) NULL,
    old_list_price DECIMAL(18,2) NULL,
    new_list_price DECIMAL(18,2) NOT NULL,
    old_sale_price DECIMAL(18,2) NULL,
    new_sale_price DECIMAL(18,2) NOT NULL,
    cost_price_snapshot DECIMAL(18,2) NOT NULL,
    change_type VARCHAR(50) NOT NULL,
    change_reason NVARCHAR(500) NULL,
    changed_by INT NULL,
    changed_by_name_snapshot NVARCHAR(100) NULL,
    changed_at DATETIME2 NOT NULL
        CONSTRAINT DF_PriceHistory_ChangedAt DEFAULT (SYSDATETIME()),
    CONSTRAINT PK_ProductVariantPriceHistory PRIMARY KEY (id),
    CONSTRAINT FK_PriceHistory_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id) ON DELETE SET NULL,
    CONSTRAINT FK_PriceHistory_User FOREIGN KEY (changed_by)
        REFERENCES dbo.[User](id) ON DELETE SET NULL
);
GO

/* =========================================================================
   IV. INVENTORY MANAGEMENT
   Product_Variant.stock_quantity is the current-stock source of truth.
   Product_Batch stores FIFO batch balances and never stores sale price.
   ========================================================================= */

CREATE TABLE dbo.Supplier (
    id INT IDENTITY(1,1) NOT NULL,
    supplier_name NVARCHAR(200) NOT NULL,
    contact_name NVARCHAR(100) NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(100) NULL,
    address NVARCHAR(500) NULL,
    status BIT NOT NULL
        CONSTRAINT DF_Supplier_Status DEFAULT (1),
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Supplier_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Supplier PRIMARY KEY (id)
);

CREATE TABLE dbo.Import_Receipt (
    id INT IDENTITY(1,1) NOT NULL,
    receipt_code VARCHAR(60) NOT NULL,
    supplier_id INT NOT NULL,
    user_id INT NOT NULL,
    total_amount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_ImportReceipt_Total DEFAULT (0),
    created_at DATETIME NOT NULL
        CONSTRAINT DF_ImportReceipt_CreatedAt DEFAULT (GETDATE()),
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_ImportReceipt_Status DEFAULT ('DRAFT'),
    note NVARCHAR(500) NULL,
    vendor_reference NVARCHAR(100) NULL,
    confirmed_by INT NULL,
    confirmed_at DATETIME NULL,
    CONSTRAINT PK_Import_Receipt PRIMARY KEY (id),
    CONSTRAINT UQ_ImportReceipt_Code UNIQUE (receipt_code),
    CONSTRAINT CK_ImportReceipt_Total CHECK (total_amount >= 0),
    CONSTRAINT FK_ImportReceipt_Supplier FOREIGN KEY (supplier_id)
        REFERENCES dbo.Supplier(id),
    CONSTRAINT FK_ImportReceipt_Creator FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id),
    CONSTRAINT FK_ImportReceipt_Confirmer FOREIGN KEY (confirmed_by)
        REFERENCES dbo.[User](id)
);

CREATE TABLE dbo.Import_Receipt_Detail (
    id INT IDENTITY(1,1) NOT NULL,
    import_receipt_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(18,2) NOT NULL,
    line_total DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Import_Receipt_Detail PRIMARY KEY (id),
    CONSTRAINT CK_ImportDetail_Quantity CHECK (quantity > 0),
    CONSTRAINT CK_ImportDetail_UnitCost CHECK (unit_cost >= 0),
    CONSTRAINT CK_ImportDetail_LineTotal CHECK (line_total >= 0),
    CONSTRAINT UQ_ImportDetail_ReceiptVariant UNIQUE (import_receipt_id, variant_id),
    CONSTRAINT FK_ImportDetail_Receipt FOREIGN KEY (import_receipt_id)
        REFERENCES dbo.Import_Receipt(id) ON DELETE CASCADE,
    CONSTRAINT FK_ImportDetail_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id)
);

CREATE TABLE dbo.Product_Batch (
    id INT IDENTITY(1,1) NOT NULL,
    variant_id INT NOT NULL,
    batch_code VARCHAR(80) NOT NULL,
    cost_price DECIMAL(18,2) NOT NULL,
    initial_quantity INT NOT NULL,
    current_quantity INT NOT NULL,
    import_receipt_id INT NULL,
    import_receipt_detail_id INT NULL,
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_ProductBatch_Status DEFAULT ('AVAILABLE'),
    created_at DATETIME NOT NULL
        CONSTRAINT DF_ProductBatch_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Product_Batch PRIMARY KEY (id),
    CONSTRAINT UQ_ProductBatch_Code UNIQUE (batch_code),
    CONSTRAINT CK_ProductBatch_Cost CHECK (cost_price >= 0),
    CONSTRAINT CK_ProductBatch_Initial CHECK (initial_quantity >= 0),
    CONSTRAINT CK_ProductBatch_Current CHECK (
        current_quantity >= 0 AND current_quantity <= initial_quantity
    ),
    CONSTRAINT FK_ProductBatch_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id),
    CONSTRAINT FK_ProductBatch_Receipt FOREIGN KEY (import_receipt_id)
        REFERENCES dbo.Import_Receipt(id),
    CONSTRAINT FK_ProductBatch_ReceiptDetail FOREIGN KEY (import_receipt_detail_id)
        REFERENCES dbo.Import_Receipt_Detail(id)
);

CREATE TABLE dbo.Inventory_Log (
    id BIGINT IDENTITY(1,1) NOT NULL,
    variant_id INT NULL,
    user_id INT NULL,
    product_name_snapshot NVARCHAR(200) NULL,
    sku_snapshot VARCHAR(50) NULL,
    quantity_before INT NULL,
    change_quantity INT NOT NULL,
    quantity_after INT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    reference_type VARCHAR(50) NULL,
    reference_id INT NULL,
    note NVARCHAR(500) NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_InventoryLog_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Inventory_Log PRIMARY KEY (id),
    CONSTRAINT CK_InventoryLog_After CHECK (
        quantity_after IS NULL OR quantity_after >= 0
    ),
    CONSTRAINT FK_InventoryLog_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id) ON DELETE SET NULL,
    CONSTRAINT FK_InventoryLog_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE SET NULL
);

CREATE TABLE dbo.Stock_Adjustment (
    id INT IDENTITY(1,1) NOT NULL,
    adjustment_code VARCHAR(60) NOT NULL,
    adjustment_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL
        CONSTRAINT DF_StockAdjustment_Status DEFAULT ('DRAFT'),
    reason NVARCHAR(500) NOT NULL,
    created_by INT NOT NULL,
    approved_by INT NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_StockAdjustment_CreatedAt DEFAULT (GETDATE()),
    approved_at DATETIME NULL,
    CONSTRAINT PK_Stock_Adjustment PRIMARY KEY (id),
    CONSTRAINT UQ_StockAdjustment_Code UNIQUE (adjustment_code),
    CONSTRAINT FK_StockAdjustment_Creator FOREIGN KEY (created_by)
        REFERENCES dbo.[User](id),
    CONSTRAINT FK_StockAdjustment_Approver FOREIGN KEY (approved_by)
        REFERENCES dbo.[User](id)
);

CREATE TABLE dbo.Stock_Adjustment_Detail (
    id INT IDENTITY(1,1) NOT NULL,
    adjustment_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity_before INT NOT NULL,
    change_quantity INT NOT NULL,
    quantity_after INT NOT NULL,
    note NVARCHAR(255) NULL,
    CONSTRAINT PK_Stock_Adjustment_Detail PRIMARY KEY (id),
    CONSTRAINT UQ_StockAdjustmentDetail UNIQUE (adjustment_id, variant_id),
    CONSTRAINT CK_StockAdjustmentDetail_Before CHECK (quantity_before >= 0),
    CONSTRAINT CK_StockAdjustmentDetail_Change CHECK (change_quantity <> 0),
    CONSTRAINT CK_StockAdjustmentDetail_After CHECK (
        quantity_after >= 0
        AND quantity_after = quantity_before + change_quantity
    ),
    CONSTRAINT FK_StockAdjustmentDetail_Header FOREIGN KEY (adjustment_id)
        REFERENCES dbo.Stock_Adjustment(id) ON DELETE CASCADE,
    CONSTRAINT FK_StockAdjustmentDetail_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id)
);
GO

/* =========================================================================
   VI. CART, VOUCHER, ORDER, PAYMENT AND FEEDBACK
   ========================================================================= */

CREATE TABLE dbo.Cart (
    user_id INT NOT NULL,
    variant_id INT NOT NULL,
    quantity INT NOT NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Cart_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Cart PRIMARY KEY (user_id, variant_id),
    CONSTRAINT CK_Cart_Quantity CHECK (quantity > 0),
    CONSTRAINT FK_Cart_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE CASCADE,
    CONSTRAINT FK_Cart_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id) ON DELETE CASCADE
);

CREATE TABLE dbo.Wishlist (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    variant_id INT NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Wishlist_CreatedAt DEFAULT (GETDATE()),
    updated_at DATETIME NOT NULL
        CONSTRAINT DF_Wishlist_UpdatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Wishlist PRIMARY KEY (user_id, product_id),
    CONSTRAINT FK_Wishlist_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlist_Product FOREIGN KEY (product_id)
        REFERENCES dbo.Product(id) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlist_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id)
);

CREATE TABLE dbo.Voucher (
    id INT IDENTITY(1,1) NOT NULL,
    code VARCHAR(50) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(18,2) NOT NULL,
    max_discount_amount DECIMAL(18,2) NULL,
    min_order_value DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Voucher_MinOrder DEFAULT (0),
    start_date DATETIME NOT NULL,
    end_date DATETIME NOT NULL,
    usage_limit INT NOT NULL,
    used_count INT NOT NULL
        CONSTRAINT DF_Voucher_UsedCount DEFAULT (0),
    limit_per_user INT NOT NULL
        CONSTRAINT DF_Voucher_LimitPerUser DEFAULT (1),
    terminate_reason NVARCHAR(255) NULL,
    category_id INT NULL,
    CONSTRAINT PK_Voucher PRIMARY KEY (id),
    CONSTRAINT UQ_Voucher_Code UNIQUE (code),
    CONSTRAINT CK_Voucher_DiscountValue CHECK (discount_value > 0),
    CONSTRAINT CK_Voucher_MaxDiscount CHECK (
        max_discount_amount IS NULL OR max_discount_amount >= 0
    ),
    CONSTRAINT CK_Voucher_MinOrder CHECK (min_order_value >= 0),
    CONSTRAINT CK_Voucher_Date CHECK (end_date > start_date),
    CONSTRAINT CK_Voucher_Usage CHECK (
        usage_limit > 0 AND used_count >= 0 AND used_count <= usage_limit
    ),
    CONSTRAINT CK_Voucher_UserLimit CHECK (limit_per_user > 0),
    CONSTRAINT FK_Voucher_Category FOREIGN KEY (category_id)
        REFERENCES dbo.Category(id)
);

CREATE TABLE dbo.Shipment (
    id INT IDENTITY(1,1) NOT NULL,
    carrier_name NVARCHAR(100) NOT NULL,
    shipping_status VARCHAR(50) NOT NULL,
    tracking_code VARCHAR(100) NULL,
    shipping_cost DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Shipment_Cost DEFAULT (0),
    estimated_delivery_time DATETIME NULL,
    CONSTRAINT PK_Shipment PRIMARY KEY (id),
    CONSTRAINT CK_Shipment_Cost CHECK (shipping_cost >= 0)
);

CREATE TABLE dbo.[Order] (
    id INT IDENTITY(1,1) NOT NULL,
    order_code VARCHAR(50) NOT NULL,
    user_id INT NULL,
    voucher_id INT NULL,
    shipment_id INT NULL,
    recipient_name NVARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    ward_id VARCHAR(20) NULL,
    address_detail NVARCHAR(255) NOT NULL,
    total_items_price DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Order_Discount DEFAULT (0),
    shipping_fee DECIMAL(18,2) NOT NULL
        CONSTRAINT DF_Order_Shipping DEFAULT (0),
    total_payment DECIMAL(18,2) NOT NULL,
    order_status VARCHAR(50) NOT NULL
        CONSTRAINT DF_Order_Status DEFAULT ('PENDING'),
    note NVARCHAR(500) NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Order_CreatedAt DEFAULT (GETDATE()),
    updated_at DATETIME NOT NULL
        CONSTRAINT DF_Order_UpdatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Order PRIMARY KEY (id),
    CONSTRAINT UQ_Order_Code UNIQUE (order_code),
    CONSTRAINT CK_Order_ItemsTotal CHECK (total_items_price >= 0),
    CONSTRAINT CK_Order_Discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_Order_ShippingFee CHECK (shipping_fee >= 0),
    CONSTRAINT CK_Order_TotalPayment CHECK (total_payment >= 0),
    CONSTRAINT FK_Order_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE SET NULL,
    CONSTRAINT FK_Order_Voucher FOREIGN KEY (voucher_id)
        REFERENCES dbo.Voucher(id),
    CONSTRAINT FK_Order_Shipment FOREIGN KEY (shipment_id)
        REFERENCES dbo.Shipment(id),
    CONSTRAINT FK_Order_Ward FOREIGN KEY (ward_id)
        REFERENCES dbo.Ward(id)
);

CREATE TABLE dbo.Order_Detail (
    id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    variant_id INT NULL,
    product_name_snapshot NVARCHAR(200) NOT NULL,
    variant_attributes_snapshot NVARCHAR(255) NULL,
    quantity INT NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_Order_Detail PRIMARY KEY (id),
    CONSTRAINT CK_OrderDetail_Quantity CHECK (quantity > 0),
    CONSTRAINT CK_OrderDetail_Price CHECK (price >= 0),
    CONSTRAINT FK_OrderDetail_Order FOREIGN KEY (order_id)
        REFERENCES dbo.[Order](id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetail_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id) ON DELETE SET NULL
);

CREATE TABLE dbo.Payment (
    id INT IDENTITY(1,1) NOT NULL,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL
        CONSTRAINT DF_Payment_Status DEFAULT ('UNPAID'),
    amount DECIMAL(18,2) NOT NULL,
    transaction_reference VARCHAR(100) NULL,
    payment_date DATETIME NULL,
    CONSTRAINT PK_Payment PRIMARY KEY (id),
    CONSTRAINT UQ_Payment_Order UNIQUE (order_id),
    CONSTRAINT CK_Payment_Amount CHECK (amount >= 0),
    CONSTRAINT FK_Payment_Order FOREIGN KEY (order_id)
        REFERENCES dbo.[Order](id) ON DELETE CASCADE
);

/* =========================================================================
   V. RETURN, EXCHANGE AND REFUND MANAGEMENT
   Return_Request lưu một yêu cầu đổi trả; các bảng con lưu sản phẩm và lịch sử.
   Thiết kế tách riêng giúp Staff và Admin nhìn được đầy đủ từng bước xử lý,
   đồng thời không làm mất dữ liệu đơn hàng gốc.
   ========================================================================= */

CREATE TABLE dbo.Return_Request (
    id INT IDENTITY(1,1) NOT NULL,
    request_code VARCHAR(60) NOT NULL,
    order_id INT NOT NULL,
    customer_id INT NULL,
    request_type VARCHAR(30) NOT NULL,
    reason VARCHAR(50) NOT NULL,
    customer_note NVARCHAR(1000) NULL,
    staff_note NVARCHAR(1000) NULL,
    refund_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_ReturnRequest_Refund DEFAULT (0),
    status VARCHAR(40) NOT NULL CONSTRAINT DF_ReturnRequest_Status DEFAULT ('PENDING'),
    requested_at DATETIME NOT NULL CONSTRAINT DF_ReturnRequest_RequestedAt DEFAULT (GETDATE()),
    reviewed_by INT NULL,
    reviewed_at DATETIME NULL,
    received_by INT NULL,
    received_at DATETIME NULL,
    refund_requested_by INT NULL,
    refund_requested_at DATETIME NULL,
    refunded_by INT NULL,
    refunded_at DATETIME NULL,
    -- Thông tin tài khoản khách nhận tiền và dữ liệu QR hoàn tiền.
    refund_bank_id VARCHAR(30) NULL,
    refund_bank_name NVARCHAR(120) NULL,
    refund_account_name NVARCHAR(120) NULL,
    refund_account_number VARCHAR(50) NULL,
    refund_qr_url NVARCHAR(1200) NULL,
    refund_transfer_description NVARCHAR(255) NULL,
    -- Ảnh chứng từ chuyển khoản và thời điểm xác nhận hoàn tiền.
    refund_proof_path NVARCHAR(1000) NULL,
    refund_confirmed_by INT NULL,
    refund_confirmed_at DATETIME NULL,
    CONSTRAINT PK_Return_Request PRIMARY KEY (id),
    CONSTRAINT UQ_ReturnRequest_Code UNIQUE (request_code),
    CONSTRAINT CK_ReturnRequest_Amount CHECK (refund_amount >= 0),
    CONSTRAINT CK_ReturnRequest_Type CHECK (request_type IN ('RETURN', 'EXCHANGE')),
    CONSTRAINT CK_ReturnRequest_Status CHECK (status IN ('PENDING', 'INFO_REQUIRED', 'APPROVED', 'REJECTED', 'RECEIVED', 'REFUND_PENDING', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT FK_ReturnRequest_Order FOREIGN KEY (order_id) REFERENCES dbo.[Order](id),
    CONSTRAINT FK_ReturnRequest_Customer FOREIGN KEY (customer_id) REFERENCES dbo.[User](id) ON DELETE SET NULL,
    CONSTRAINT FK_ReturnRequest_ReviewedBy FOREIGN KEY (reviewed_by) REFERENCES dbo.[User](id),
    CONSTRAINT FK_ReturnRequest_ReceivedBy FOREIGN KEY (received_by) REFERENCES dbo.[User](id),
    CONSTRAINT FK_ReturnRequest_RefundRequestedBy FOREIGN KEY (refund_requested_by) REFERENCES dbo.[User](id),
    CONSTRAINT FK_ReturnRequest_RefundedBy FOREIGN KEY (refunded_by) REFERENCES dbo.[User](id),
    CONSTRAINT FK_ReturnRequest_RefundConfirmedBy FOREIGN KEY (refund_confirmed_by) REFERENCES dbo.[User](id)
);

CREATE TABLE dbo.Return_Request_Item (
    id INT IDENTITY(1,1) NOT NULL,
    return_request_id INT NOT NULL,
    order_detail_id INT NOT NULL,
    variant_id INT NULL,
    product_name_snapshot NVARCHAR(200) NOT NULL,
    variant_attributes_snapshot NVARCHAR(255) NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_ReturnRequestItem PRIMARY KEY (id),
    CONSTRAINT UQ_ReturnRequestItem_Detail UNIQUE (return_request_id, order_detail_id),
    CONSTRAINT CK_ReturnRequestItem_Quantity CHECK (quantity > 0),
    CONSTRAINT CK_ReturnRequestItem_Price CHECK (unit_price >= 0),
    CONSTRAINT FK_ReturnRequestItem_Request FOREIGN KEY (return_request_id) REFERENCES dbo.Return_Request(id) ON DELETE CASCADE,
    CONSTRAINT FK_ReturnRequestItem_OrderDetail FOREIGN KEY (order_detail_id) REFERENCES dbo.Order_Detail(id),
    CONSTRAINT FK_ReturnRequestItem_Variant FOREIGN KEY (variant_id) REFERENCES dbo.Product_Variant(id) ON DELETE SET NULL
);

CREATE TABLE dbo.Return_Request_History (
    id BIGINT IDENTITY(1,1) NOT NULL,
    return_request_id INT NOT NULL,
    old_status VARCHAR(40) NULL,
    new_status VARCHAR(40) NOT NULL,
    note NVARCHAR(1000) NULL,
    changed_by INT NULL,
    changed_at DATETIME NOT NULL CONSTRAINT DF_ReturnHistory_ChangedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_ReturnRequestHistory PRIMARY KEY (id),
    CONSTRAINT FK_ReturnHistory_Request FOREIGN KEY (return_request_id) REFERENCES dbo.Return_Request(id) ON DELETE CASCADE,
    CONSTRAINT FK_ReturnHistory_User FOREIGN KEY (changed_by) REFERENCES dbo.[User](id) ON DELETE SET NULL
);
GO

CREATE TABLE dbo.Voucher_Usage (
    id BIGINT IDENTITY(1,1) NOT NULL,
    voucher_id INT NOT NULL,
    user_id INT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    used_at DATETIME NOT NULL
        CONSTRAINT DF_VoucherUsage_UsedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Voucher_Usage PRIMARY KEY (id),
    CONSTRAINT UQ_VoucherUsage_Order UNIQUE (order_id),
    CONSTRAINT CK_VoucherUsage_Discount CHECK (discount_amount >= 0),
    CONSTRAINT FK_VoucherUsage_Voucher FOREIGN KEY (voucher_id)
        REFERENCES dbo.Voucher(id),
    CONSTRAINT FK_VoucherUsage_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id) ON DELETE SET NULL,
    CONSTRAINT FK_VoucherUsage_Order FOREIGN KEY (order_id)
        REFERENCES dbo.[Order](id)
);

CREATE TABLE dbo.Feedback (
    id INT IDENTITY(1,1) NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT NULL,
    order_detail_id INT NULL,
    variant_id INT NULL,
    size NVARCHAR(100) NULL,
    color NVARCHAR(100) NULL,
    rating INT NOT NULL,
    comment NVARCHAR(MAX) NULL,
    status BIT NOT NULL
        CONSTRAINT DF_Feedback_Status DEFAULT (1),
    admin_response NVARCHAR(MAX) NULL,
    response_by INT NULL,
    responded_at DATETIME NULL,
    created_at DATETIME NOT NULL
        CONSTRAINT DF_Feedback_CreatedAt DEFAULT (GETDATE()),
    CONSTRAINT PK_Feedback PRIMARY KEY (id),
    CONSTRAINT CK_Feedback_Rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT FK_Feedback_User FOREIGN KEY (user_id)
        REFERENCES dbo.[User](id),
    CONSTRAINT FK_Feedback_Product FOREIGN KEY (product_id)
        REFERENCES dbo.Product(id) ON DELETE CASCADE,
    CONSTRAINT FK_Feedback_Order FOREIGN KEY (order_id)
        REFERENCES dbo.[Order](id),
    CONSTRAINT FK_Feedback_OrderDetail FOREIGN KEY (order_detail_id)
        REFERENCES dbo.Order_Detail(id),
    CONSTRAINT FK_Feedback_Variant FOREIGN KEY (variant_id)
        REFERENCES dbo.Product_Variant(id),
    CONSTRAINT FK_Feedback_ResponseUser FOREIGN KEY (response_by)
        REFERENCES dbo.[User](id) ON DELETE SET NULL
);
GO

/* =========================================================================
   VII. INDEXES
   ========================================================================= */

CREATE INDEX IX_District_Province ON dbo.District(province_id);
CREATE INDEX IX_Ward_District ON dbo.Ward(district_id);
CREATE INDEX IX_User_RoleStatus ON dbo.[User](role_id, status);
CREATE INDEX IX_Category_ParentStatus ON dbo.Category(parent_id, status);
CREATE INDEX IX_Product_CategoryStatus ON dbo.Product(category_id, status);
CREATE INDEX IX_Product_BrandStatus ON dbo.Product(brand_id, status);
CREATE INDEX IX_ProductImage_Main ON dbo.Product_Image(product_id, is_main);
CREATE INDEX IX_ProductVariant_ProductStatus ON dbo.Product_Variant(product_id, status);
CREATE INDEX IX_ProductVariant_Stock ON dbo.Product_Variant(stock_quantity, status);
CREATE INDEX IX_PriceHistory_VariantDate
    ON dbo.Product_Variant_Price_History(variant_id, changed_at DESC);
CREATE INDEX IX_ImportReceipt_StatusDate
    ON dbo.Import_Receipt(status, created_at DESC);
CREATE INDEX IX_ImportDetail_Variant
    ON dbo.Import_Receipt_Detail(variant_id);
CREATE INDEX IX_ProductBatch_FIFO
    ON dbo.Product_Batch(variant_id, current_quantity, created_at, id);
CREATE INDEX IX_InventoryLog_VariantDate
    ON dbo.Inventory_Log(variant_id, created_at DESC);
CREATE INDEX IX_InventoryLog_Reference
    ON dbo.Inventory_Log(reference_type, reference_id);
CREATE INDEX IX_ReturnRequest_StatusDate
    ON dbo.Return_Request(status, requested_at DESC);
CREATE INDEX IX_ReturnRequest_Order
    ON dbo.Return_Request(order_id);
CREATE UNIQUE INDEX UX_ReturnRequest_ActiveOrder
    ON dbo.Return_Request(order_id)
    WHERE status IN ('PENDING', 'INFO_REQUIRED', 'APPROVED', 'RECEIVED', 'REFUND_PENDING');
CREATE INDEX IX_ReturnRequestItem_Variant
    ON dbo.Return_Request_Item(variant_id);
CREATE INDEX IX_ReturnHistory_RequestDate
    ON dbo.Return_Request_History(return_request_id, changed_at DESC);
CREATE INDEX IX_StockAdjustment_StatusDate
    ON dbo.Stock_Adjustment(status, created_at DESC);
CREATE INDEX IX_Wishlist_Variant ON dbo.Wishlist(variant_id);
CREATE INDEX IX_Voucher_ActiveWindow
    ON dbo.Voucher(start_date, end_date, used_count, usage_limit);
CREATE INDEX IX_Order_UserDate ON dbo.[Order](user_id, created_at DESC);
CREATE INDEX IX_Order_StatusDate ON dbo.[Order](order_status, created_at DESC);
CREATE INDEX IX_OrderDetail_Variant ON dbo.Order_Detail(variant_id);
CREATE INDEX IX_Feedback_ProductStatus ON dbo.Feedback(product_id, status, created_at DESC);
GO

/* =========================================================================
   VII. COMPATIBILITY TRIGGER
   Admin product code writes Product_Variant.color/size directly, while some
   current customer/cart DAO queries still read Attribute tables.
   This trigger keeps the legacy values synchronized.
   ========================================================================= */

CREATE TRIGGER dbo.TR_ProductVariant_DefaultPriceAndLegacyAttributes
ON dbo.Product_Variant
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pv
    SET pv.list_price = COALESCE(pv.list_price, i.sale_price)
    FROM dbo.Product_Variant pv
    INNER JOIN inserted i ON i.id = pv.id
    WHERE pv.list_price IS NULL;

    DECLARE @ColorAttributeId INT =
        (SELECT TOP 1 id FROM dbo.Attribute WHERE attribute_name = N'Color');

    DECLARE @SizeAttributeId INT =
        (SELECT TOP 1 id FROM dbo.Attribute WHERE attribute_name = N'Size');

    IF @ColorAttributeId IS NOT NULL
    BEGIN
        UPDATE vav
        SET vav.attribute_value = i.color
        FROM dbo.Variant_Attribute_Value vav
        INNER JOIN inserted i ON i.id = vav.variant_id
        WHERE vav.attribute_id = @ColorAttributeId
          AND NULLIF(LTRIM(RTRIM(i.color)), N'') IS NOT NULL;

        INSERT INTO dbo.Variant_Attribute_Value
            (variant_id, attribute_id, attribute_value)
        SELECT i.id, @ColorAttributeId, i.color
        FROM inserted i
        WHERE NULLIF(LTRIM(RTRIM(i.color)), N'') IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Variant_Attribute_Value vav
              WHERE vav.variant_id = i.id
                AND vav.attribute_id = @ColorAttributeId
          );

        DELETE vav
        FROM dbo.Variant_Attribute_Value vav
        INNER JOIN inserted i ON i.id = vav.variant_id
        WHERE vav.attribute_id = @ColorAttributeId
          AND NULLIF(LTRIM(RTRIM(i.color)), N'') IS NULL;
    END

    IF @SizeAttributeId IS NOT NULL
    BEGIN
        UPDATE vav
        SET vav.attribute_value = i.size
        FROM dbo.Variant_Attribute_Value vav
        INNER JOIN inserted i ON i.id = vav.variant_id
        WHERE vav.attribute_id = @SizeAttributeId
          AND NULLIF(LTRIM(RTRIM(i.size)), N'') IS NOT NULL;

        INSERT INTO dbo.Variant_Attribute_Value
            (variant_id, attribute_id, attribute_value)
        SELECT i.id, @SizeAttributeId, i.size
        FROM inserted i
        WHERE NULLIF(LTRIM(RTRIM(i.size)), N'') IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.Variant_Attribute_Value vav
              WHERE vav.variant_id = i.id
                AND vav.attribute_id = @SizeAttributeId
          );

        DELETE vav
        FROM dbo.Variant_Attribute_Value vav
        INNER JOIN inserted i ON i.id = vav.variant_id
        WHERE vav.attribute_id = @SizeAttributeId
          AND NULLIF(LTRIM(RTRIM(i.size)), N'') IS NULL;
    END
END
GO

CREATE VIEW dbo.vw_Inventory_Overview
AS
SELECT
    pv.id AS variant_id,
    p.id AS product_id,
    p.product_name,
    pv.sku,
    pv.color,
    pv.size,
    pv.cost_price,
    pv.list_price,
    pv.sale_price,
    pv.stock_quantity,
    CASE
        WHEN pv.stock_quantity = 0 THEN 'OUT_OF_STOCK'
        WHEN pv.stock_quantity <= 5 THEN 'LOW_STOCK'
        ELSE 'IN_STOCK'
    END AS stock_status,
    pv.status AS variant_status,
    p.status AS product_status
FROM dbo.Product_Variant pv
INNER JOIN dbo.Product p ON p.id = pv.product_id;
GO

