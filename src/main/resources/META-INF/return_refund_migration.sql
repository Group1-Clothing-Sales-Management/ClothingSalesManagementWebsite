/*
 * Chạy file này trên ClothesShopDB nếu database đã tạo từ schema.sql cũ.
 * File không xoá dữ liệu cũ; mỗi bảng chỉ được tạo khi chưa tồn tại.
 */
USE [ClothesShopDB];
GO

IF OBJECT_ID(N'dbo.Return_Request', N'U') IS NULL
BEGIN
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
        reviewed_by INT NULL, reviewed_at DATETIME NULL,
        received_by INT NULL, received_at DATETIME NULL,
        refund_requested_by INT NULL, refund_requested_at DATETIME NULL,
        refunded_by INT NULL, refunded_at DATETIME NULL,
        CONSTRAINT PK_Return_Request PRIMARY KEY (id),
        CONSTRAINT UQ_ReturnRequest_Code UNIQUE (request_code),
        CONSTRAINT CK_ReturnRequest_Amount CHECK (refund_amount >= 0),
        CONSTRAINT CK_ReturnRequest_Type CHECK (request_type IN ('RETURN', 'EXCHANGE')),
        CONSTRAINT CK_ReturnRequest_Status CHECK (status IN ('PENDING','INFO_REQUIRED','APPROVED','REJECTED','RECEIVED','REFUND_PENDING','COMPLETED')),
        CONSTRAINT FK_ReturnRequest_Order FOREIGN KEY (order_id) REFERENCES dbo.[Order](id),
        CONSTRAINT FK_ReturnRequest_Customer FOREIGN KEY (customer_id) REFERENCES dbo.[User](id) ON DELETE SET NULL,
        CONSTRAINT FK_ReturnRequest_ReviewedBy FOREIGN KEY (reviewed_by) REFERENCES dbo.[User](id),
        CONSTRAINT FK_ReturnRequest_ReceivedBy FOREIGN KEY (received_by) REFERENCES dbo.[User](id),
        CONSTRAINT FK_ReturnRequest_RefundRequestedBy FOREIGN KEY (refund_requested_by) REFERENCES dbo.[User](id),
        CONSTRAINT FK_ReturnRequest_RefundedBy FOREIGN KEY (refunded_by) REFERENCES dbo.[User](id)
    );
END
GO

IF OBJECT_ID(N'dbo.Return_Request_Item', N'U') IS NULL
BEGIN
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
END
GO

IF OBJECT_ID(N'dbo.Return_Request_History', N'U') IS NULL
BEGIN
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
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReturnRequest_StatusDate' AND object_id = OBJECT_ID(N'dbo.Return_Request'))
    CREATE INDEX IX_ReturnRequest_StatusDate ON dbo.Return_Request(status, requested_at DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReturnRequest_Order' AND object_id = OBJECT_ID(N'dbo.Return_Request'))
    CREATE INDEX IX_ReturnRequest_Order ON dbo.Return_Request(order_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ReturnRequest_ActiveOrder' AND object_id = OBJECT_ID(N'dbo.Return_Request'))
    CREATE UNIQUE INDEX UX_ReturnRequest_ActiveOrder ON dbo.Return_Request(order_id)
        WHERE status IN ('PENDING', 'INFO_REQUIRED', 'APPROVED', 'RECEIVED', 'REFUND_PENDING');
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReturnRequestItem_Variant' AND object_id = OBJECT_ID(N'dbo.Return_Request_Item'))
    CREATE INDEX IX_ReturnRequestItem_Variant ON dbo.Return_Request_Item(variant_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ReturnHistory_RequestDate' AND object_id = OBJECT_ID(N'dbo.Return_Request_History'))
    CREATE INDEX IX_ReturnHistory_RequestDate ON dbo.Return_Request_History(return_request_id, changed_at DESC);
GO
