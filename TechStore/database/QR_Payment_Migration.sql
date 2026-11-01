-- Additive migration for LOCAL/development TechStore_PRJ301. Run with SSMS or sqlcmd -b.
-- Run this after the existing schema has been installed, never rerun the create/seed script.
USE [TechStore_PRJ301];
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
        THROW 51000, 'Invoice table is missing. Install the existing schema first.', 1;

    IF COL_LENGTH(N'dbo.Invoice', N'PaymentStatus') IS NULL
        ALTER TABLE dbo.Invoice ADD PaymentStatus VARCHAR(20) NOT NULL
            CONSTRAINT DF_Invoice_PaymentStatus DEFAULT ('UNPAID') WITH VALUES;

    -- Discover the actual COD-only constraint by its definition, never assume its name.
    DECLARE @name sysname, @definition nvarchar(max), @normalized nvarchar(max), @dropSql nvarchar(max);
    DECLARE payment_checks CURSOR LOCAL FAST_FORWARD FOR
        SELECT name, definition FROM sys.check_constraints
        WHERE parent_object_id = OBJECT_ID(N'dbo.Invoice');
    OPEN payment_checks;
    FETCH NEXT FROM payment_checks INTO @name, @definition;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @normalized = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            @definition, '[', ''), ']', ''), '(', ''), ')', ''), ' ', ''));
        IF @normalized IN (N'paymentmethod=''cod''', N'''cod''=paymentmethod', N'paymentmethodin''cod''')
        BEGIN
            SET @dropSql = N'ALTER TABLE dbo.Invoice DROP CONSTRAINT ' + QUOTENAME(@name);
            EXEC (@dropSql);
        END;
        FETCH NEXT FROM payment_checks INTO @name, @definition;
    END;
    CLOSE payment_checks;
    DEALLOCATE payment_checks;

    IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
        WHERE parent_object_id=OBJECT_ID(N'dbo.Invoice') AND name=N'CK_Invoice_QRPaymentMethod')
        EXEC (N'ALTER TABLE dbo.Invoice WITH CHECK ADD CONSTRAINT CK_Invoice_QRPaymentMethod CHECK (PaymentMethod IN (''COD'',''QR''))');
    IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
        WHERE parent_object_id=OBJECT_ID(N'dbo.Invoice') AND name=N'CK_Invoice_PaymentStatus')
        EXEC (N'ALTER TABLE dbo.Invoice WITH CHECK ADD CONSTRAINT CK_Invoice_PaymentStatus CHECK (PaymentStatus IN (''UNPAID'',''PENDING_VERIFY'',''PAID''))');

    -- Keep the existing transactional stock restoration. Payment confirmation and cancellation
    -- contend on the same Invoice row, so neither can race past the other's status check.
    EXEC (N'CREATE OR ALTER PROCEDURE dbo.sp_CancelPendingOrder
        @InvoiceID INT, @CustomerID INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SET XACT_ABORT ON;
        BEGIN TRY
            BEGIN TRANSACTION;
            UPDATE dbo.Invoice SET OrderStatus = ''CANCELLED''
            WHERE InvoiceID=@InvoiceID AND CustomerID=@CustomerID AND OrderStatus=''PENDING''
              AND NOT (PaymentMethod=''QR'' AND PaymentStatus=''PAID'');
            IF @@ROWCOUNT <> 1
                THROW 51001, ''Only an unpaid pending order owned by this customer can be cancelled. Paid QR orders require a refund process.'', 1;
            UPDATE p SET p.StockQuantity=p.StockQuantity+d.TotalQuantity
            FROM dbo.Product p INNER JOIN (
                SELECT ProductID,SUM(Quantity) TotalQuantity FROM dbo.InvoiceDetail
                WHERE InvoiceID=@InvoiceID GROUP BY ProductID
            ) d ON d.ProductID=p.ProductID;
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH
    END');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
-- Existing COD records deliberately remain UNPAID; no historical payment is inferred.
SELECT PaymentMethod,PaymentStatus,COUNT_BIG(*) AS InvoiceCount
FROM dbo.Invoice GROUP BY PaymentMethod,PaymentStatus;
