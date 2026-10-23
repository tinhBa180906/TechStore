/*
TECHSTORE - PRJ301 - GROUP 1 | FRESH DATABASE v1.0
Nguyen Tung Thai - Vu Hong Quang - Khuat Ba Tinh
Microsoft SQL Server (SSMS), tested by static review; runtime verification in SQL Server required.

IMPORTANT:
- This creates a NEW database: TechStore_PRJ301. It does NOT modify old TechStore.
- Run the ENTIRE file in SQL Server Management Studio (F5). "GO" is an SSMS batch separator.
- Running it twice won't duplicate the sample data. For a completely fresh reset,
  manually delete database TechStore_PRJ301 first (only if you intend to lose its data).
- PasswordHash uses PBKDF2-HMAC-SHA256 (210000 iterations, 16-byte random salt).
  It is NOT plaintext and NOT BCrypt. Use the provided PasswordUtil.java in Java.
- Demonstration prices and orders are fictional course sample data.
- Products have NULL ImageURL: show a placeholder until you add local images.
- Checkout reserves stock immediately for PENDING orders. Java MUST use one JDBC
  transaction: guarded stock decrement -> Invoice -> InvoiceDetail -> COMMIT.
  On any failure: ROLLBACK. NEVER deduct stock in both Java and a trigger.
- To cancel pending orders, call dbo.sp_CancelPendingOrder; it restores stock once.
- Demo completed invoices represent past sales: StockQuantity is already the
  CURRENT remaining stock and is not decremented again by inserting sample history.
*/

IF DB_ID(N'TechStore_PRJ301') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE TechStore_PRJ301');
END;
GO
USE TechStore_PRJ301;
GO

/* ==============================================================
   A. TABLES (8 TABLES) - CREATE IN FOREIGN KEY ORDER
   =============================================================== */

IF OBJECT_ID(N'dbo.Brand', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Brand (
        BrandID      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Brand PRIMARY KEY,
        BrandName    NVARCHAR(80) NOT NULL CONSTRAINT UQ_Brand_Name UNIQUE,
        Country      NVARCHAR(80) NULL,
        IsActive     BIT NOT NULL CONSTRAINT DF_Brand_IsActive DEFAULT (1)
    );
END;
GO

IF OBJECT_ID(N'dbo.Category', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Category (
        CategoryID   INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Category PRIMARY KEY,
        CategoryName NVARCHAR(80) NOT NULL CONSTRAINT UQ_Category_Name UNIQUE
    );
END;
GO

IF OBJECT_ID(N'dbo.Customer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customer (
        CustomerID     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customer PRIMARY KEY,
        FullName       NVARCHAR(100) NOT NULL,
        Phone          VARCHAR(15) NULL,
        DefaultAddress NVARCHAR(255) NULL,
        CreatedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_Customer_CreatedAt DEFAULT (SYSDATETIME()),
        CONSTRAINT CK_Customer_FullName CHECK (LEN(LTRIM(RTRIM(FullName))) >= 2)
    );
END;
GO

IF OBJECT_ID(N'dbo.UserAccount', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserAccount (
        AccountID    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UserAccount PRIMARY KEY,
        CustomerID   INT NULL,
        Username     VARCHAR(50) NOT NULL CONSTRAINT UQ_UserAccount_Username UNIQUE,
        Email        VARCHAR(120) NOT NULL CONSTRAINT UQ_UserAccount_Email UNIQUE,
        PasswordHash VARCHAR(255) NOT NULL,
        Role         VARCHAR(12) NOT NULL CONSTRAINT DF_UserAccount_Role DEFAULT ('CUSTOMER'),
        IsActive     BIT NOT NULL CONSTRAINT DF_UserAccount_IsActive DEFAULT (1),
        CreatedAt    DATETIME2(0) NOT NULL CONSTRAINT DF_UserAccount_CreatedAt DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_UserAccount_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
        CONSTRAINT CK_UserAccount_Role CHECK (Role IN ('ADMIN','CUSTOMER')),
        CONSTRAINT CK_UserAccount_CustomerRole CHECK (
            (Role='ADMIN' AND CustomerID IS NULL) OR
            (Role='CUSTOMER' AND CustomerID IS NOT NULL)
        )
    );
    CREATE UNIQUE INDEX UX_UserAccount_CustomerID
        ON dbo.UserAccount(CustomerID) WHERE CustomerID IS NOT NULL;
END;
GO

IF OBJECT_ID(N'dbo.Product', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Product (
        ProductID      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Product PRIMARY KEY,
        ProductName    NVARCHAR(150) NOT NULL CONSTRAINT UQ_Product_ProductName UNIQUE,
        BrandID        INT NOT NULL,
        CategoryID     INT NOT NULL,
        [Description]  NVARCHAR(1000) NULL,
        Price          DECIMAL(18,0) NOT NULL,
        StockQuantity  INT NOT NULL CONSTRAINT DF_Product_Stock DEFAULT (0),
        WarrantyPeriod INT NOT NULL CONSTRAINT DF_Product_Warranty DEFAULT (12),
        ImageURL       NVARCHAR(500) NULL,
        IsFeatured     BIT NOT NULL CONSTRAINT DF_Product_Featured DEFAULT (0),
        IsActive       BIT NOT NULL CONSTRAINT DF_Product_Active DEFAULT (1),
        CreatedAt      DATETIME2(0) NOT NULL CONSTRAINT DF_Product_CreatedAt DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_Product_Brand FOREIGN KEY (BrandID) REFERENCES dbo.Brand(BrandID),
        CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES dbo.Category(CategoryID),
        CONSTRAINT CK_Product_Price CHECK (Price > 0),
        CONSTRAINT CK_Product_Stock CHECK (StockQuantity >= 0),
        CONSTRAINT CK_Product_Warranty CHECK (WarrantyPeriod >= 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Invoice (
        InvoiceID       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Invoice PRIMARY KEY,
        CustomerID      INT NOT NULL,
        DateCreated     DATETIME2(0) NOT NULL CONSTRAINT DF_Invoice_Date DEFAULT (SYSDATETIME()),
        OrderStatus     VARCHAR(12) NOT NULL CONSTRAINT DF_Invoice_Status DEFAULT ('PENDING'),
        PaymentMethod   VARCHAR(10) NOT NULL CONSTRAINT DF_Invoice_Payment DEFAULT ('COD'),
        ShippingName    NVARCHAR(100) NOT NULL,
        ShippingPhone   VARCHAR(15) NOT NULL,
        ShippingAddress NVARCHAR(255) NOT NULL,
        CompletedAt     DATETIME2(0) NULL,
        CONSTRAINT FK_Invoice_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
        CONSTRAINT CK_Invoice_Status CHECK (OrderStatus IN ('PENDING','CONFIRMED','COMPLETED','CANCELLED')),
        CONSTRAINT CK_Invoice_Payment CHECK (PaymentMethod='COD')
    );
END;
GO

IF OBJECT_ID(N'dbo.InvoiceDetail', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InvoiceDetail (
        InvoiceDetailID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_InvoiceDetail PRIMARY KEY,
        InvoiceID       INT NOT NULL,
        ProductID       INT NOT NULL,
        Quantity        INT NOT NULL,
        UnitPrice       DECIMAL(18,0) NOT NULL,
        CONSTRAINT FK_InvoiceDetail_Invoice FOREIGN KEY (InvoiceID) REFERENCES dbo.Invoice(InvoiceID),
        CONSTRAINT FK_InvoiceDetail_Product FOREIGN KEY (ProductID) REFERENCES dbo.Product(ProductID),
        CONSTRAINT UQ_InvoiceDetail_Line UNIQUE (InvoiceID,ProductID),
        CONSTRAINT CK_InvoiceDetail_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_InvoiceDetail_UnitPrice CHECK (UnitPrice > 0)
    );
END;
GO

/* Optional review feature (FR-25): create now, implement UI only if time permits */
IF OBJECT_ID(N'dbo.ProductReview', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductReview (
        ReviewID    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ProductReview PRIMARY KEY,
        AccountID   INT NOT NULL,
        ProductID   INT NOT NULL,
        Rating      TINYINT NOT NULL,
        Comment     NVARCHAR(1000) NULL,
        CreatedAt   DATETIME2(0) NOT NULL CONSTRAINT DF_Review_Date DEFAULT (SYSDATETIME()),
        CONSTRAINT FK_Review_Account FOREIGN KEY (AccountID) REFERENCES dbo.UserAccount(AccountID),
        CONSTRAINT FK_Review_Product FOREIGN KEY (ProductID) REFERENCES dbo.Product(ProductID),
        CONSTRAINT UQ_Review_AccountProduct UNIQUE (AccountID,ProductID),
        CONSTRAINT CK_Review_Rating CHECK (Rating BETWEEN 1 AND 5)
    );
END;
GO

/* ==============================================================
   B. INDEXES
   =============================================================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Product_Catalog' AND object_id=OBJECT_ID('dbo.Product'))
    CREATE INDEX IX_Product_Catalog ON dbo.Product(IsActive,CategoryID,BrandID,Price);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_Invoice_CustomerDate' AND object_id=OBJECT_ID('dbo.Invoice'))
    CREATE INDEX IX_Invoice_CustomerDate ON dbo.Invoice(CustomerID,DateCreated DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_InvoiceDetail_Product' AND object_id=OBJECT_ID('dbo.InvoiceDetail'))
    CREATE INDEX IX_InvoiceDetail_Product ON dbo.InvoiceDetail(ProductID);
GO

/* ==============================================================
   C. SAFE STATUS CANCELLATION
   - Updates PENDING -> CANCELLED exactly once for owning customer.
   - Restores all reserved stock. Repeat call is rejected.
   - Admin is allowed to invoke same procedure only after checking
     permissions in Java, supplying original CustomerID.
   =============================================================== */
CREATE OR ALTER PROCEDURE dbo.sp_CancelPendingOrder
    @InvoiceID INT,
    @CustomerID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE dbo.Invoice
        SET OrderStatus = 'CANCELLED'
        WHERE InvoiceID = @InvoiceID AND CustomerID = @CustomerID
          AND OrderStatus = 'PENDING';

        IF @@ROWCOUNT <> 1
            THROW 51001, N'Khong tim thay don PENDING cua khach hang nay.', 1;

        UPDATE p
        SET p.StockQuantity = p.StockQuantity + d.TotalQuantity
        FROM dbo.Product p
        INNER JOIN (
            SELECT ProductID, SUM(Quantity) AS TotalQuantity
            FROM dbo.InvoiceDetail
            WHERE InvoiceID = @InvoiceID
            GROUP BY ProductID
        ) d ON d.ProductID = p.ProductID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* ==============================================================
   D. USEFUL VIEWS FOR JAVA DAO AND DASHBOARD
   =============================================================== */
CREATE OR ALTER VIEW dbo.vw_ProductCatalog
AS
SELECT p.ProductID,p.ProductName,p.BrandID,b.BrandName,
       p.CategoryID,c.CategoryName,p.[Description],p.Price,
       p.StockQuantity,p.WarrantyPeriod,p.ImageURL,
       p.IsFeatured,p.IsActive,p.CreatedAt,
       COALESCE(s.UnitsSold,0) AS UnitsSold
FROM dbo.Product p
JOIN dbo.Brand b ON p.BrandID=b.BrandID
JOIN dbo.Category c ON p.CategoryID=c.CategoryID
LEFT JOIN (
    SELECT d.ProductID,SUM(d.Quantity) AS UnitsSold
    FROM dbo.InvoiceDetail d
    JOIN dbo.Invoice i ON i.InvoiceID=d.InvoiceID
    WHERE i.OrderStatus='COMPLETED'
    GROUP BY d.ProductID
) s ON p.ProductID=s.ProductID;
GO

CREATE OR ALTER VIEW dbo.vw_OrderTotals
AS
SELECT i.InvoiceID,i.CustomerID,i.DateCreated,i.OrderStatus,
       i.PaymentMethod,i.ShippingName,i.ShippingPhone,
       i.ShippingAddress,i.CompletedAt,
       COALESCE(SUM(CAST(d.Quantity AS DECIMAL(18,0))*d.UnitPrice),0) AS TotalAmount,
       COALESCE(SUM(d.Quantity),0) AS ItemCount
FROM dbo.Invoice i
LEFT JOIN dbo.InvoiceDetail d ON i.InvoiceID=d.InvoiceID
GROUP BY i.InvoiceID,i.CustomerID,i.DateCreated,i.OrderStatus,
         i.PaymentMethod,i.ShippingName,i.ShippingPhone,
         i.ShippingAddress,i.CompletedAt;
GO

/* ==============================================================
   E. SEED: CATEGORIES, BRANDS AND PRODUCTS
   =============================================================== */
INSERT INTO dbo.Category(CategoryName)
SELECT v.CategoryName
FROM (VALUES (N'Điện thoại'),(N'Laptop'),(N'Phụ kiện'),(N'Màn hình')) v(CategoryName)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Category c WHERE c.CategoryName=v.CategoryName);
GO

INSERT INTO dbo.Brand(BrandName,Country)
SELECT v.BrandName,v.Country FROM (VALUES
    (N'Apple',N'Mỹ'),(N'Samsung',N'Hàn Quốc'),(N'Dell',N'Mỹ'),
    (N'ASUS',N'Đài Loan'),(N'Sony',N'Nhật Bản'),(N'HP',N'Mỹ'),
    (N'Lenovo',N'Trung Quốc'),(N'Xiaomi',N'Trung Quốc'),
    (N'LG',N'Hàn Quốc'),(N'Acer',N'Đài Loan')
) v(BrandName,Country)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Brand b WHERE b.BrandName=v.BrandName);
GO

/* Product entries automatically resolved to category/brand IDs. */
INSERT INTO dbo.Product(ProductName,BrandID,CategoryID,[Description],Price,StockQuantity,WarrantyPeriod,ImageURL,IsFeatured,CreatedAt)
SELECT v.ProductName,b.BrandID,c.CategoryID,v.[Description],v.Price,v.StockQuantity,v.WarrantyPeriod,
       NULL,v.IsFeatured, DATEADD(day,-v.DaysAgo,SYSDATETIME())
FROM (VALUES
    (N'iPhone 15 Pro Max 256GB', N'Apple', N'Điện thoại', N'iPhone 15 Pro Max 256GB. Thiết bị thuộc nhóm Điện thoại, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 28990000, 34, 12, 1, 180),
    (N'iPhone 14 128GB', N'Apple', N'Điện thoại', N'iPhone 14 128GB. Thiết bị thuộc nhóm Điện thoại, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 14990000, 28, 12, 0, 170),
    (N'iPhone 16 128GB', N'Apple', N'Điện thoại', N'iPhone 16 128GB. Thiết bị thuộc nhóm Điện thoại, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 21490000, 50, 12, 1, 60),
    (N'MacBook Air M2 13 inch', N'Apple', N'Laptop', N'MacBook Air M2 13 inch. Thiết bị thuộc nhóm Laptop, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 21990000, 27, 12, 1, 150),
    (N'MacBook Pro M3 14 inch', N'Apple', N'Laptop', N'MacBook Pro M3 14 inch. Thiết bị thuộc nhóm Laptop, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 38990000, 11, 12, 0, 95),
    (N'AirPods Pro 2 USB-C', N'Apple', N'Phụ kiện', N'AirPods Pro 2 USB-C. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 5490000, 75, 12, 0, 42),
    (N'Apple Studio Display 27 inch', N'Apple', N'Màn hình', N'Apple Studio Display 27 inch. Thiết bị thuộc nhóm Màn hình, thương hiệu Apple; thông số và giá dành cho dữ liệu demo.', 37990000, 5, 12, 0, 120),
    (N'Samsung Galaxy S24 Ultra', N'Samsung', N'Điện thoại', N'Samsung Galaxy S24 Ultra. Thiết bị thuộc nhóm Điện thoại, thương hiệu Samsung; thông số và giá dành cho dữ liệu demo.', 27990000, 20, 12, 1, 75),
    (N'Samsung Galaxy A55 5G', N'Samsung', N'Điện thoại', N'Samsung Galaxy A55 5G. Thiết bị thuộc nhóm Điện thoại, thương hiệu Samsung; thông số và giá dành cho dữ liệu demo.', 8990000, 52, 12, 0, 90),
    (N'Samsung Galaxy Z Flip5', N'Samsung', N'Điện thoại', N'Samsung Galaxy Z Flip5. Thiết bị thuộc nhóm Điện thoại, thương hiệu Samsung; thông số và giá dành cho dữ liệu demo.', 16990000, 16, 12, 0, 155),
    (N'Samsung Odyssey G5 27 inch', N'Samsung', N'Màn hình', N'Samsung Odyssey G5 27 inch. Thiết bị thuộc nhóm Màn hình, thương hiệu Samsung; thông số và giá dành cho dữ liệu demo.', 6790000, 29, 24, 0, 45),
    (N'Dell XPS 15 9530', N'Dell', N'Laptop', N'Dell XPS 15 9530. Thiết bị thuộc nhóm Laptop, thương hiệu Dell; thông số và giá dành cho dữ liệu demo.', 35990000, 9, 24, 1, 175),
    (N'Dell Inspiron 15 3520', N'Dell', N'Laptop', N'Dell Inspiron 15 3520. Thiết bị thuộc nhóm Laptop, thương hiệu Dell; thông số và giá dành cho dữ liệu demo.', 15490000, 48, 12, 0, 120),
    (N'Dell Alienware m16', N'Dell', N'Laptop', N'Dell Alienware m16. Thiết bị thuộc nhóm Laptop, thương hiệu Dell; thông số và giá dành cho dữ liệu demo.', 44990000, 7, 24, 0, 110),
    (N'Dell P2422H 24 inch', N'Dell', N'Màn hình', N'Dell P2422H 24 inch. Thiết bị thuộc nhóm Màn hình, thương hiệu Dell; thông số và giá dành cho dữ liệu demo.', 4390000, 58, 36, 0, 82),
    (N'ASUS ROG Strix G15', N'ASUS', N'Laptop', N'ASUS ROG Strix G15. Thiết bị thuộc nhóm Laptop, thương hiệu ASUS; thông số và giá dành cho dữ liệu demo.', 30990000, 20, 24, 1, 150),
    (N'ASUS Zenbook 14 OLED', N'ASUS', N'Laptop', N'ASUS Zenbook 14 OLED. Thiết bị thuộc nhóm Laptop, thương hiệu ASUS; thông số và giá dành cho dữ liệu demo.', 23990000, 33, 24, 0, 65),
    (N'ASUS Vivobook 15', N'ASUS', N'Laptop', N'ASUS Vivobook 15. Thiết bị thuộc nhóm Laptop, thương hiệu ASUS; thông số và giá dành cho dữ liệu demo.', 13990000, 54, 12, 0, 135),
    (N'ASUS TUF Gaming A15', N'ASUS', N'Laptop', N'ASUS TUF Gaming A15. Thiết bị thuộc nhóm Laptop, thương hiệu ASUS; thông số và giá dành cho dữ liệu demo.', 25990000, 18, 24, 0, 25),
    (N'Sony WH-1000XM5', N'Sony', N'Phụ kiện', N'Sony WH-1000XM5. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Sony; thông số và giá dành cho dữ liệu demo.', 7490000, 73, 12, 1, 145),
    (N'Sony WF-1000XM5', N'Sony', N'Phụ kiện', N'Sony WF-1000XM5. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Sony; thông số và giá dành cho dữ liệu demo.', 5290000, 44, 12, 0, 38),
    (N'Sony SRS-XB13 Bluetooth', N'Sony', N'Phụ kiện', N'Sony SRS-XB13 Bluetooth. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Sony; thông số và giá dành cho dữ liệu demo.', 1190000, 120, 12, 0, 110),
    (N'HP Pavilion 15', N'HP', N'Laptop', N'HP Pavilion 15. Thiết bị thuộc nhóm Laptop, thương hiệu HP; thông số và giá dành cho dữ liệu demo.', 15990000, 40, 12, 0, 126),
    (N'HP Envy x360', N'HP', N'Laptop', N'HP Envy x360. Thiết bị thuộc nhóm Laptop, thương hiệu HP; thông số và giá dành cho dữ liệu demo.', 24990000, 29, 12, 0, 112),
    (N'HP Victus 16', N'HP', N'Laptop', N'HP Victus 16. Thiết bị thuộc nhóm Laptop, thương hiệu HP; thông số và giá dành cho dữ liệu demo.', 27990000, 13, 24, 0, 69),
    (N'Lenovo ThinkPad X1 Carbon', N'Lenovo', N'Laptop', N'Lenovo ThinkPad X1 Carbon. Thiết bị thuộc nhóm Laptop, thương hiệu Lenovo; thông số và giá dành cho dữ liệu demo.', 42990000, 14, 36, 1, 136),
    (N'Lenovo Legion 5', N'Lenovo', N'Laptop', N'Lenovo Legion 5. Thiết bị thuộc nhóm Laptop, thương hiệu Lenovo; thông số và giá dành cho dữ liệu demo.', 28990000, 31, 24, 0, 125),
    (N'Lenovo IdeaPad Slim 5', N'Lenovo', N'Laptop', N'Lenovo IdeaPad Slim 5. Thiết bị thuộc nhóm Laptop, thương hiệu Lenovo; thông số và giá dành cho dữ liệu demo.', 17490000, 42, 12, 0, 30),
    (N'Lenovo L24i Monitor', N'Lenovo', N'Màn hình', N'Lenovo L24i Monitor. Thiết bị thuộc nhóm Màn hình, thương hiệu Lenovo; thông số và giá dành cho dữ liệu demo.', 3690000, 56, 36, 0, 96),
    (N'Xiaomi Redmi Note 13 Pro', N'Xiaomi', N'Điện thoại', N'Xiaomi Redmi Note 13 Pro. Thiết bị thuộc nhóm Điện thoại, thương hiệu Xiaomi; thông số và giá dành cho dữ liệu demo.', 7990000, 97, 18, 0, 88),
    (N'Xiaomi 14 256GB', N'Xiaomi', N'Điện thoại', N'Xiaomi 14 256GB. Thiết bị thuộc nhóm Điện thoại, thương hiệu Xiaomi; thông số và giá dành cho dữ liệu demo.', 18990000, 42, 18, 1, 46),
    (N'Xiaomi Power Bank 10000mAh', N'Xiaomi', N'Phụ kiện', N'Xiaomi Power Bank 10000mAh. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Xiaomi; thông số và giá dành cho dữ liệu demo.', 450000, 160, 6, 0, 104),
    (N'Xiaomi Redmi Buds 5', N'Xiaomi', N'Phụ kiện', N'Xiaomi Redmi Buds 5. Thiết bị thuộc nhóm Phụ kiện, thương hiệu Xiaomi; thông số và giá dành cho dữ liệu demo.', 890000, 110, 12, 0, 57),
    (N'LG UltraGear 27GR75Q 27 inch', N'LG', N'Màn hình', N'LG UltraGear 27GR75Q 27 inch. Thiết bị thuộc nhóm Màn hình, thương hiệu LG; thông số và giá dành cho dữ liệu demo.', 7990000, 26, 24, 1, 70),
    (N'LG UltraWide 29WQ600', N'LG', N'Màn hình', N'LG UltraWide 29WQ600. Thiết bị thuộc nhóm Màn hình, thương hiệu LG; thông số và giá dành cho dữ liệu demo.', 5390000, 38, 24, 0, 97),
    (N'Acer Nitro 5', N'Acer', N'Laptop', N'Acer Nitro 5. Thiết bị thuộc nhóm Laptop, thương hiệu Acer; thông số và giá dành cho dữ liệu demo.', 23990000, 35, 12, 0, 162),
    (N'Acer Aspire 5', N'Acer', N'Laptop', N'Acer Aspire 5. Thiết bị thuộc nhóm Laptop, thương hiệu Acer; thông số và giá dành cho dữ liệu demo.', 14490000, 49, 12, 0, 61),
    (N'Acer KA242Y 24 inch', N'Acer', N'Màn hình', N'Acer KA242Y 24 inch. Thiết bị thuộc nhóm Màn hình, thương hiệu Acer; thông số và giá dành cho dữ liệu demo.', 3290000, 65, 24, 0, 19)
) v(ProductName,BrandName,CategoryName,[Description],Price,StockQuantity,WarrantyPeriod,IsFeatured,DaysAgo)
JOIN dbo.Brand b ON b.BrandName=v.BrandName
JOIN dbo.Category c ON c.CategoryName=v.CategoryName
WHERE NOT EXISTS (SELECT 1 FROM dbo.Product p WHERE p.ProductName=v.ProductName);
GO

/* ==============================================================
   F. DEMO USER SEED
   Passwords are salted PBKDF2-HMAC-SHA256, NOT plaintext.
   Admin account:    admin          / Admin@123456
   Customer accounts: customer1, customer2, customer3 / Customer@123456
   Change or deactivate all test credentials before any public hosting.
   =============================================================== */
IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE FullName=N'Nguyễn Minh An')
    INSERT INTO dbo.Customer(FullName,Phone,DefaultAddress) VALUES (N'Nguyễn Minh An','0912345678',N'Cầu Giấy, Hà Nội');
IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE FullName=N'Trần Hoàng Bình')
    INSERT INTO dbo.Customer(FullName,Phone,DefaultAddress) VALUES (N'Trần Hoàng Bình','0988111222',N'Đống Đa, Hà Nội');
IF NOT EXISTS (SELECT 1 FROM dbo.Customer WHERE FullName=N'Lê Thu Hà')
    INSERT INTO dbo.Customer(FullName,Phone,DefaultAddress) VALUES (N'Lê Thu Hà','0909222333',N'Nam Từ Liêm, Hà Nội');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.UserAccount WHERE Username='admin')
    INSERT INTO dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role)
    VALUES (NULL,'admin','admin@techstore.local','pbkdf2_sha256$210000$UzsrHSRPMf8GNRvO2lSmtA==$g+oISqBuTYlU+1MBZebVUzenLYbaSgnH0mz9gGgwLBg=','ADMIN');
IF NOT EXISTS (SELECT 1 FROM dbo.UserAccount WHERE Username='customer1')
    INSERT INTO dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role)
    SELECT CustomerID,'customer1','customer1@techstore.local','pbkdf2_sha256$210000$JfcUEsXHHBJLhK5VmaBrxg==$6HREAw1XcVnjMf8hgQfWIOuDoHJ4oMHhKCf+6tdOLbk=','CUSTOMER'
    FROM dbo.Customer WHERE FullName=N'Nguyễn Minh An';
IF NOT EXISTS (SELECT 1 FROM dbo.UserAccount WHERE Username='customer2')
    INSERT INTO dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role)
    SELECT CustomerID,'customer2','customer2@techstore.local','pbkdf2_sha256$210000$se36VZqvkOspdMAO3vpoUA==$TZ+ihv93Afnxt8qXbSiBbvo9nKomHfkoIqhjCmeiajo=','CUSTOMER'
    FROM dbo.Customer WHERE FullName=N'Trần Hoàng Bình';
IF NOT EXISTS (SELECT 1 FROM dbo.UserAccount WHERE Username='customer3')
    INSERT INTO dbo.UserAccount(CustomerID,Username,Email,PasswordHash,Role)
    SELECT CustomerID,'customer3','customer3@techstore.local','pbkdf2_sha256$210000$DfoODk1ibmEqIYEz5VBfig==$xhKscYPbA6gs168rX4Kzd+H8mll1TvvlTC1gdjFp2OA=','CUSTOMER'
    FROM dbo.Customer WHERE FullName=N'Lê Thu Hà';
GO

/* Historical completed orders for reporting and top-selling items.
   Historic sales do NOT touch current stock. Seed only once. */
IF NOT EXISTS (SELECT 1 FROM dbo.Invoice)
BEGIN
    DECLARE @InvoiceID INT;
    -- Demo completed invoice 1
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-07-15T09:15:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-07-15T09:15:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer1';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'iPhone 15 Pro Max 256GB';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'AirPods Pro 2 USB-C';
    -- Demo completed invoice 2
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-07-25T11:45:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-07-25T11:45:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer2';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Dell Inspiron 15 3520';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,2,p.Price FROM dbo.Product p WHERE p.ProductName=N'Sony SRS-XB13 Bluetooth';
    -- Demo completed invoice 3
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-08-03T16:20:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-08-03T16:20:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer3';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,2,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Redmi Note 13 Pro';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,3,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Power Bank 10000mAh';
    -- Demo completed invoice 4
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-08-17T14:05:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-08-17T14:05:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer1';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'MacBook Air M2 13 inch';
    -- Demo completed invoice 5
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-09-06T10:30:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-09-06T10:30:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer2';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,2,p.Price FROM dbo.Product p WHERE p.ProductName=N'Sony WH-1000XM5';
    -- Demo completed invoice 6
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-09-22T18:40:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-09-22T18:40:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer3';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Samsung Galaxy A55 5G';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Redmi Buds 5';
    -- Demo completed invoice 7
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-10-03T13:50:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-10-03T13:50:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer1';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Lenovo Legion 5';
    -- Demo completed invoice 8
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-10-12T09:10:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-10-12T09:10:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer2';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Samsung Odyssey G5 27 inch';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,2,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Power Bank 10000mAh';
    -- Demo completed invoice 9
    INSERT INTO dbo.Invoice(CustomerID,DateCreated,OrderStatus,PaymentMethod,ShippingName,ShippingPhone,ShippingAddress,CompletedAt)
    SELECT c.CustomerID,CONVERT(DATETIME2(0),'2026-10-18T17:30:00',126),'COMPLETED','COD',c.FullName,
           COALESCE(c.Phone,'0000000000'),COALESCE(c.DefaultAddress,N'Địa chỉ demo'),
           DATEADD(day,2,CONVERT(DATETIME2(0),'2026-10-18T17:30:00',126))
    FROM dbo.Customer c JOIN dbo.UserAccount a ON a.CustomerID=c.CustomerID
    WHERE a.Username='customer3';
    SET @InvoiceID = CONVERT(INT,SCOPE_IDENTITY());
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Redmi Note 13 Pro';
    INSERT INTO dbo.InvoiceDetail(InvoiceID,ProductID,Quantity,UnitPrice)
    SELECT @InvoiceID,p.ProductID,1,p.Price FROM dbo.Product p WHERE p.ProductName=N'Xiaomi Power Bank 10000mAh';
END;
GO

/* ==============================================================
   G. QUICK VERIFICATION / SIMPLE REPORT QUERIES
   =============================================================== */
PRINT N'TechStore_PRJ301 setup finished.';
SELECT 'Brand' AS TableName, COUNT(*) AS RowCount FROM dbo.Brand
UNION ALL SELECT 'Category',COUNT(*) FROM dbo.Category
UNION ALL SELECT 'Customer',COUNT(*) FROM dbo.Customer
UNION ALL SELECT 'UserAccount',COUNT(*) FROM dbo.UserAccount
UNION ALL SELECT 'Product',COUNT(*) FROM dbo.Product
UNION ALL SELECT 'Invoice',COUNT(*) FROM dbo.Invoice
UNION ALL SELECT 'InvoiceDetail',COUNT(*) FROM dbo.InvoiceDetail
UNION ALL SELECT 'ProductReview',COUNT(*) FROM dbo.ProductReview;

-- Admin report: completed revenue and average completed order value.
SELECT COUNT(*) AS CompletedOrderCount,
       COALESCE(SUM(TotalAmount),0) AS Revenue,
       COALESCE(AVG(TotalAmount),0) AS AvgOrderValue
FROM dbo.vw_OrderTotals WHERE OrderStatus='COMPLETED';

-- Best sellers for the homepage.
SELECT TOP 5 ProductID,ProductName,BrandName,Price,UnitsSold
FROM dbo.vw_ProductCatalog WHERE IsActive=1
ORDER BY UnitsSold DESC,ProductID ASC;

-- SQL Server pagination example (Java must bind @offset and @pageSize via PreparedStatement).
-- SELECT ... FROM dbo.vw_ProductCatalog WHERE IsActive=1
-- ORDER BY ProductID OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;
GO
