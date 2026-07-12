USE ClothesShopDB;
GO

IF OBJECT_ID('dbo.Wishlist', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Wishlist (
        user_id INT NOT NULL,
        product_id INT NOT NULL,
        variant_id INT NULL,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT PK_Wishlist PRIMARY KEY (user_id, product_id),
        CONSTRAINT FK_Wishlist_User FOREIGN KEY (user_id)
            REFERENCES dbo.[User](id) ON DELETE CASCADE,
        CONSTRAINT FK_Wishlist_Product FOREIGN KEY (product_id)
            REFERENCES dbo.Product(id) ON DELETE CASCADE,
        CONSTRAINT FK_Wishlist_Variant FOREIGN KEY (variant_id)
            REFERENCES dbo.Product_Variant(id)
    );
END
GO

IF OBJECT_ID('dbo.Wishlist', 'U') IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE name = 'IX_Wishlist_Variant'
          AND object_id = OBJECT_ID('dbo.Wishlist')
    )
BEGIN
    CREATE INDEX IX_Wishlist_Variant ON dbo.Wishlist(variant_id);
END
GO
