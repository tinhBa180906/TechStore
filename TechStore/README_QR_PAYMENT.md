# VietQR (manual verification)

Current local configuration: the project owner supplied Techcombank (`TCB`), account `38607102006`, name `NGUYEN TUNG THAI`; these values now replace the initial empty template. No bank ownership or transfer has been independently verified. Setup instructions below describe the original blank-template baseline; preserve or replace receiving details intentionally when deploying.

1. Run `database/QR_Payment_Migration.sql` on the **local/development** `TechStore_PRJ301` database using SSMS, or `sqlcmd -b -i database/QR_Payment_Migration.sql` with your SQL Server connection options. Never rerun the original create/seed SQL to upgrade.
2. Fill `web/WEB-INF/vietqr.properties` with the store's legitimate receiving bank ID/BIN, account number and account holder name. All values are intentionally empty; no real/demo account has been invented. Verify ownership and test details with your bank before use. File is protected under WEB-INF; it contains receiving details only, no bank password/OTP/token.
3. Build/deploy the existing Servlet/JSP application and copy WEB-INF configuration along with web assets. Restart Tomcat. Missing/invalid config rejects QR checkout **before** creating an invoice; COD remains available. Existing QR orders display a configuration error without a fake QR.
4. Customer selects VietQR, submits checkout once, scans the order-specific QR, then clicks “Tôi đã chuyển khoản”. This only requests verification. Admin must compare the actual bank transaction, exact amount and `TECHSTORE<InvoiceID>` before pressing Confirm Payment. PAID does not complete the order. Paid QR cancellation is blocked until a separate refund process exists.

## Quick Link reference and limitations

Official reference: https://www.vietqr.io/danh-sach-api/link-tao-ma-nhanh/ (redirects to https://www.vietqr.io/qr-dong).
Checked during implementation: current documentation uses `compact2.svg` (the task's older example uses `.png`). The implementation uses the current SVG URL. Amount is a positive integral VND value, at most 13 digits; fractions are rejected without rounding. Transfer content is stable `TECHSTORE<InvoiceID>`, ASCII and fewer than 50 characters.

`accountName` is rendered on the image; the official documentation says it is **not part of the VietQR payload standard**. The scanning bank app resolves/validates the beneficiary name; the website cannot guarantee automatic name filling in every banking app. Verify the beneficiary before transferring. Standard templates/provider availability may change; an image failure leaves manual receiving details visible. Never treat image load or a customer declaration as proof of payment. No API key, SDK, webhook or automatic bank verification is used.

Keep the receiving configuration stable while unpaid orders exist. Changing it changes the receiving account shown on old orders; their amount/reference still come from immutable invoice details/ID. Do not configure someone else's bank account for tests. No real transfer is needed for the included checks.
