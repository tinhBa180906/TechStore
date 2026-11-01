# VietQR payment implementation changelog

## Follow-up - User-authorized Git delivery on qrpayment
Status: Prepared for commit

User explicitly requested a new `qrpayment` branch and commit under their own Git identity, superseding the earlier no-commit instruction for this delivery step. Verified existing Git identity: `tungthai2mai <210707450+tungthai2mai@users.noreply.github.com>`. Commit author/committer use that identity without AI co-author attribution. Scope: the 21 feature/source/documentation/test files listed in the merge guide; two existing untracked PDF/DOCX reports in the repository parent remain excluded. No push requested or performed. No code/database changes for this delivery step. Verification before staging: git diff --check PASS; no existing qrpayment branch found.

## Follow-up - Admin payment reconciliation UI and removal of storefront top strip
Status: Completed

Files created: none. Files modified: `web/WEB-INF/views/admin/orders.jsp`, `web/css/admin-orders.css`, `web/js/admin-orders.js`, `web/WEB-INF/views/common/header.jsp`, `tests/QRPaymentIntegrationTest.java`, `QR_PAYMENT_TEST_RESULTS.md`, `QR_PAYMENT_MERGE_GUIDE.md`, this changelog.
Methods/mappings/schema changed: none. Admin JSP now places a compact VietQR reconciliation panel after recipient/order information instead of the unstyled payment fields above the order header. Shows localized payment state, exact stored total and TECHSTORE reference, highlights PENDING_VERIFY, and keeps a secondary detail link. Non-paid/non-cancelled QR orders offer “Xác nhận đã nhận tiền”. One shared native dialog shows the selected invoice/amount/reference and requires an acknowledgement checkbox before enabling submit; actual form still POSTs csrf/orderId/action=confirmPayment to the same protected servlet. Sending state disables duplicate submit and shows a spinner; pageshow resets stale UI. Confirmation notice styled separately from delivery status. Existing search/filter/cancel/delivery logic retained.
Header change/reason: removed the actual shared ts-topbar markup containing “Khám phá công nghệ cùng TechStore”, language/currency and duplicate admin shortcut, as explicitly requested. Main header/menu, cart/account and ADMIN profile-menu links remain. Legacy CSS rules left untouched because the badge class is still used elsewhere and unrelated stylesheet cleanup is out of scope.
Conflict containment: new admin selectors scoped to `.admin-orders-page .admin-payment-*`; payment JavaScript in a separate IIFE, existing filtering code untouched. Admin CSS/JS cache bumped to v2. Integration test's old English-label smoke assertion updated to the new panel/dialog markup; full blank-config harness not rerun against configured receiving details.
Database impact: none; no payment/order mutation used for UI checks, no account config change. Admin/CSRF/prepared UPDATE checks remain in the unchanged Java controller/DAO.
Verification: node --check PASS; all JSP Jasper compile PASS/0 errors; all four deployed assets match source. Authenticated admin orders and home/products/product-detail return HTTP 200; topbar absent from all three storefront pages and admin menu remains. Admin CSS/JS HTTP 200. Isolated Node VM callback checks PASS for dialog data binding, acknowledgement gate, submit progress, duplicate guard, pageshow reset and close (no network POST). First callback-check attempt hit PowerShell stdin Unicode conversion in the test expectation; rerun with Unicode escapes passed, app source unchanged. Native browser visual/modal interaction not exercised. git diff --check PASS.
Merge notes: deploy header JSP + admin JSP/CSS/JS together; no Java rebuild/migration required. Feature inventory now includes 10 modified pre-existing source/JSP/CSS/JS files and 11 newly created feature files from earlier phases. Do not overwrite receiving properties or unrelated member changes. No commit/push.

## Follow-up - Transfer feedback and discoverable payment return
Status: Completed

Files created: none. Files modified: `web/WEB-INF/views/payment-qr.jsp`, `web/WEB-INF/views/order-history.jsp`, `web/css/payment-qr.css`, `QR_PAYMENT_TEST_RESULTS.md`, `QR_PAYMENT_MERGE_GUIDE.md`, this changelog.
Methods/mappings changed: none; no Java/DAO/SQL changes. Payment JSP submit listener now shows an animated spinner and “Đang gửi thông báo…”, announces progress and disables duplicate button submissions while preserving native CSRF POST/PRG. A pageshow listener resets the button on browser back/forward restoration. Server-rendered PENDING_VERIFY produces an animated check notice “Đã ghi nhận thông báo chuyển khoản”, focused/announced accessibly, and a waiting-state panel rather than another QR scan prompt. Never claims receipt/payment success; failed requests cannot render the acknowledgement merely because the button was clicked. Reduced-motion preference respected.
History changes/reason: QR UNPAID/non-cancelled orders gain a blue reminder directly under the existing order-status guide and a prominent “Tiếp tục thanh toán” link to their existing Invoice QR. PENDING_VERIFY shows “Đã gửi thông báo chuyển khoản” / “Xem trạng thái”; PAID/CANCELLED retain a neutral details link, no pay prompt. Removed the faint duplicate footer QR link for active unpaid/verification orders. Existing filters/tables/cancel forms remain.
Conflict containment: payment-qr.css v3 loaded by the QR and history JSPs; QR selectors remain `.qr-payment-page`, new history selectors are `.history-page .qrpay-history-*`. Shared CSS/JS and global names untouched. JS remains inside existing page IIFE.
Database impact: none; no invoice/payment writes during this UI verification. Existing COD/payment state machine unchanged.
Verification: payment page JavaScript node --check PASS; all JSP Jasper compile PASS/0 errors; all three deployed files match source; history/QR/CSS HTTP 200; existing PENDING_VERIFY order rendered the acknowledgement. New unpaid CTA branches reviewed/compiled; interactive browser animation, BFCache and unpaid-link click-through not exercised. No database mutation harness rerun for this presentation-only change. git diff --check PASS.
Merge notes: ship both JSPs with CSS v3; preserve bank config and all existing POST fields/state predicates. No commit/push.

## Follow-up - Compact VietQR payment interface
Status: Completed

Files created: `web/css/payment-qr.css`. Files modified: `web/WEB-INF/views/payment-qr.jsp`, `QR_PAYMENT_TEST_RESULTS.md`, `QR_PAYMENT_MERGE_GUIDE.md`, this changelog. Only the QR JSP/CSS are copied to the local deployment; receiving configuration and existing member changes preserved.
Methods/mappings changed: none. Changes/reason: replaced the long text/product-first layout with a compact two-column payment card; QR image reduced from 320px to 210px desktop / 176px mobile with aspect ratio preserved. Amount and short localized state badge lead; concise receiving rows with inline copy icons and highlighted reference. Customer declaration and order link sit inside the payment card above a collapsed product-detail section; mobile has a fixed bottom action bar with safe-area/content spacing. Retained cancelled/paid/no-config states, manual-transfer image fallback, existing POST fields/CSRF and role/status conditions. Copy listener is enclosed in an IIFE rather than a global function. Techcombank display label derives from configured TCB code, with other bank IDs displayed unchanged.
Conflict containment: every new CSS selector is scoped under `.qr-payment-page`, internal classes/IDs use `qrpay-`, stylesheet only linked from payment-qr.jsp with a cache version. Shared orders.css/style.css, checkout/admin/history and all Java/SQL untouched in this follow-up. No new framework.
Database impact: none, no order or payment mutation performed for UI verification. Existing COD/payment business rules unchanged.
Verification: all JSP Jasper compile PASS / 0 errors; deployed view/CSS hashes match source; new stylesheet HTTP 200; authenticated read of an existing QR order HTTP 200 and new layout/styles/collapsible summary present; action markup precedes product summary. git diff --check PASS. Browser viewport/clipboard/real banking scan not exercised; no screenshots required. Re-running the database mutation harness is unnecessary for this presentation-only change.
Merge notes: include new payment-qr.css with payment-qr.jsp, preserve the receiving properties and existing feature code; full final inventory is 11 new feature files and 7 modified pre-existing source/JSP files. No commit/push.

## Follow-up - Configure user-supplied Techcombank receiving account
Status: Completed

Files created: none. Files modified: `web/WEB-INF/vietqr.properties`, `README_QR_PAYMENT.md`, `QR_PAYMENT_MERGE_GUIDE.md`, `QR_PAYMENT_TEST_RESULTS.md`, this changelog. The same properties file is copied to the ignored local Tomcat deployment.
Methods/mappings changed: none. Changes/reason: user explicitly supplied Techcombank, account 38607102006, beneficiary NGUYEN TUNG THAI; configured bankId TCB and the exact supplied values to enable local QR checkout. Helper reads properties on each request, so no rebuild/restart is required.
Database impact: none; no invoice created and no transfer/payment confirmation performed. Existing COD behavior unchanged. Previous phase entries describe the earlier blank-config test baseline.
Verification: source/deployed properties compared and local homepage checked after deployment. Bank ownership, actual QR scan and real transfers are not verified. Full missing-config integration harness is not rerun against receiving config because it expects blank properties.
Merge notes: current source configuration now contains the user-supplied receiving account; preserve the intended recipient's configuration when integrating on another machine. Earlier blank-template instructions apply to setup without receiving information.

## Phase 1 - Existing checkout audit
Status: Completed

Files created: `QR_PAYMENT_CHANGELOG.md`.
Files modified: none. Classes/mappings changed: none.

Findings:
- Initial `git status --short`: no tracked modifications; two existing untracked PDF/DOCX reports in the repository parent are preserved. Project root is `TechStore/`, Git root is its parent. No AGENTS.md found in the project or immediate ancestors.
- `OrderSupport.cart()` uses a session `LinkedHashMap<Integer, CartItem>`; `CartServlet` serializes mutations on the session. Login uses session `user` (`Account`), role CUSTOMER with CustomerID; admin requires ADMIN. Existing `orderCsrf` protects order POSTs.
- `OrderDAO.checkout()` already has a JDBC transaction: decrement active stock with sufficient-stock condition, reread DB prices, insert PENDING/COD Invoice with generated ID, insert InvoiceDetail, commit; rollback on SQL/runtime failure. No client price is trusted. Cart clears only after checkout returns successfully. Session synchronization and PRG already prevent ordinary duplicate checkout; a dedicated one-use checkout token will strengthen replay handling.
- Display total uses session cart; authoritative order total is `vw_OrderTotals`, computed from stored detail prices/quantities. Existing view does not include payment status.
- `OrderDAO.getOrders()` loads totals and details. Admin `updateStatus()` preserves PENDING -> CONFIRMED -> COMPLETED. Customer/admin cancellation calls `sp_CancelPendingOrder`, whose conditional PENDING update and stock restore are in one transaction.
- Schema script defines existing `PaymentMethod VARCHAR(10)` and `CK_Invoice_Payment CHECK (PaymentMethod='COD')`; no PaymentStatus. Migration will discover actual constraint metadata before replacing the COD-only check, add only PaymentStatus, and protect the existing cancel procedure against PAID QR cancellation under the same Invoice lock.
- NetBeans Ant build imports missing/ignored `nbproject/build-impl.xml`; installed JDK 17, Tomcat 10.1 and deployed JDBC/JSTL jars allow direct javac and JSP compilation without changing project type.

Reason: establish compatibility boundaries before edits. Database impact: none.
Existing behavior potentially affected later: checkout, history/admin order loading, cancellation. COD transaction, stock logic and delivery status transitions will be retained.
Verification: source/schema reviewed; git status recorded; no implementation build needed in this phase.
Merge notes: do not run the original destructive database create/seed script for this feature. Use the separate additive migration.

## Phase 2 - Minimal database migration and model/DAO
Status: Completed

Files created: `database/QR_Payment_Migration.sql`.
Files modified: `src/java/model/Order.java`, `src/java/dao/OrderDAO.java`, this changelog.
Methods: added Order paymentStatus getter/setter; added payment-aware `OrderDAO.checkout(..., paymentMethod)` overload (old signature delegates to COD); changed `getOrders()`/`readOrder()` to read status through an Invoice join without changing vw_OrderTotals.
Changes/reason: validate COD/QR, persist server-selected UNPAID, retain transactional stock/details writes, lock products in stable ID order to reduce deadlocks. Migration discovers COD-only CHECK from sys.check_constraints, adds PaymentStatus/default/check and COD/QR method check, modifies the existing cancellation procedure with an atomic PAID QR guard. No new table or view.
Database: applied successfully on local TechStore_PRJ301; 12 existing COD invoices retained with UNPAID (no historical payment inferred). Live procedure matched the source procedure before alteration. PK/FK and other table schemas unchanged; stock untouched by migration. Initial EXEC/QUOTENAME syntax error was corrected before successful execution.
Verification: local migration PASS. Full Java/JSP build deferred until feature wiring. Existing cancellation transaction and totals view preserved.
Affected behavior: order queries require migration; paid QR PENDING invoices cannot be cancelled. COD cancellation remains unchanged.
Merge notes: run migration before deploying Java changes; use sqlcmd -b or SSMS. Do not use old seed script to upgrade. Guard and payment confirmation serialize on the same Invoice row.

## Phase 3 - VietQR receiving configuration and Quick Link helper
Status: Completed

Files created: `src/java/util/VietQRUtil.java`, `web/WEB-INF/vietqr.properties`, `README_QR_PAYMENT.md`.
Files modified: this changelog. Added methods: VietQRUtil constructor, `load(ServletContext)`, `amountVnd(BigDecimal)`, `transferContent(int)`, `imageUrl(int, BigDecimal)`, receiving-detail getters and private encoding/placeholder validation.
Changes/reason: one small helper loads UTF-8 configuration from protected WEB-INF, rejects missing/placeholder/path-unsafe configuration, generates encoded Quick Links with exact positive integral VND (max 13 digits), fixed TECHSTORE plus actual ID. No SDK/key or fake account.
Database impact: none. Existing functionality: none in this phase; COD does not need config.
Verification: official VietQR docs read; current format is compact2.svg, adapted from task's older PNG example. Docs explicitly state accountName is displayed on the image, not encoded in the VietQR standard; bank app beneficiary resolution cannot be guaranteed. Unit/build tests scheduled in Phase 8.
Merge notes: fill all three properties with a verified store account, deploy the file with web assets, keep configuration stable while unpaid invoices exist. README explains provider failure/manual transfer and no automatic verification.

## Phase 4 - Checkout payment selection
Status: Completed

Files created: none. Files modified: `src/java/controller/OrderServlet.java`, `src/java/dao/OrderDAO.java`, `web/WEB-INF/views/checkout.jsp`, this changelog.
Methods: OrderServlet doGet/doPost, OrderDAO payment-aware checkout overload. Existing /checkout and /orders mappings retained.
Changes: two radio options with COD default and selection retained after validation error; hidden one-use checkoutToken created on GET, checked/consumed under existing session lock only after successful commit. Existing CSRF stays required. Missing method defaults COD, forged values rejected. Config checked before any QR database write. Server recalculates QR amount from DB prices inside existing transaction and rejects fractional/oversized totals without rounding. Successful QR checkout PRG redirects to /payment-qr?orderId=<generated key>; COD still redirects directly to /orders. PaymentStatus cannot be supplied by client; DAO always writes UNPAID. Cart clears only after commit.
Reason: preserve COD and prevent ordinary double-submit/replay while adding QR without a second inventory debit.
Database: new order inserts only, transactional as before; no additional schema changes. Existing features affected: checkout form and validation only.
Verification: code reviewed against existing session locking/PRG; complete compiled/integration checks in Phase 8. QR destination implemented in next phase.
Merge notes: checkout.jsp and OrderServlet must ship together (checkoutToken required); config is deliberately blank, so QR is blocked until configured. Duplicate submissions are rejected rather than creating a second invoice.

## Phase 5 - Invoice-based QR page and history link
Status: Completed

Files created: `web/WEB-INF/views/payment-qr.jsp`.
Files modified: `OrderDAO.java`, `OrderServlet.java`, `web/WEB-INF/views/order-history.jsp`, this changelog (Java paths as above).
Methods/mappings: added `OrderDAO.getOrder(int, Integer)` with owner-filtered SQL; added GET `/payment-qr` to existing OrderServlet. doGet authorizes an active CUSTOMER owner or active ADMIN, loads DB Invoice/totals/details and derives QR from only that data. Unowned/missing/COD invoices return 404, invalid ID 400, DB failure 503.
Changes/reason: new responsive JSP reuses orders.css, displays products, amount, receiving details, stable reference and manual verification instructions; image error leaves manual instructions/details; copy buttons handle clipboard failure. CANCELLED and PAID never render QR or encourage another transfer. PENDING_VERIFY warns against duplicate transfer. History displays method/status and a link to reopen the QR/status page. Paid QR cancellation button hidden. Opening/reloading does not write anything. POST button markup prepared for Phase 6.
Database: read-only Invoice/InvoiceDetail/totals queries; no schema change, no new order on GET.
Existing features affected: history payment label now uses real values; existing order actions remain. No UI framework added.
Verification: authorization and DB-derived amount/reference reviewed; JSP compilation and HTTP tests scheduled for Phase 8.
Merge notes: deploy JSP alongside mapping/helper/config; amount query parameters are ignored. Receiving details escape with c:out; no customer PII is sent to VietQR.

## Phase 6 - Customer transfer declaration
Status: Completed

Files created: none. Files modified: `src/java/dao/OrderDAO.java`, `src/java/controller/OrderServlet.java`, this changelog.
Methods/mapping: added `OrderDAO.requestPaymentVerification(int, int)`; POST `/payment-qr` branch in OrderServlet.doPost.
Changes/reason: active CUSTOMER + existing CSRF + fixed action required. Atomic prepared UPDATE requires owning CustomerID, QR, UNPAID and not CANCELLED; only writes PENDING_VERIFY. Zero-row updates validate the owner/invoice/method/cancellation then allow idempotent retries for already PENDING_VERIFY/PAID without another write. Customer-provided PaymentStatus is never read. PRG reloads DB status and displays the verification-pending message in the existing QR page. No invoice creation, stock write, automatic PAID, receipt upload or polling.
Database: conditional payment state update only, no schema change. Old COD and order flow unaffected.
Verification: race/state/ownership predicates reviewed; integration/replay tests in Phase 8.
Merge notes: deploy DAO/controller together; GET remains read-only. PAID stays PAID on stale customer POST; cancelled orders reject declaration.

## Phase 7 - Manual ADMIN payment confirmation
Status: Completed

Files created: none. Files modified: `src/java/dao/OrderDAO.java`, `src/java/controller/admin/AdminOrderServlet.java`, `web/WEB-INF/views/admin/orders.jsp`, this changelog.
Methods/mappings: added `OrderDAO.confirmPayment(int)`; extended AdminOrderServlet doGet/doPost on unchanged `/admin/orders`; extended `OrderDAO.updateStatus()` completion predicate. No new admin route.
Changes: ADMIN and CSRF checked before all writes. Fixed POST action confirmPayment conditionally sets PAID only for QR, UNPAID/PENDING_VERIFY, non-cancelled invoices; already PAID is an idempotent no-op. No PaymentStatus request parameter accepted. Confirmation writes no inventory/order-status fields. PRG flash notice distinguishes confirmation vs already confirmed. Existing admin card layout gains Payment Method / Payment Status fields and actual reference, detail link, and bank-reconciliation warning/confirm button. Existing search preview uses real payment data. Existing cancel and delivery forms remain; paid QR cancellation hidden and blocked by migration procedure. QR cannot be marked COMPLETED until PAID (COD completion remains as before).
Reason: only bank reconciliation by ADMIN can mark paid; prevent refund-less cancellation and premature completion of unpaid transfers. Payment confirmation and cancellation use mutually exclusive predicates on same locked Invoice row, preserving one-time stock restoration.
Database: guarded status UPDATE only; migration's cancel guard reused. No schema/stock change in this phase.
Verification: permission, CSRF, idempotency, cancelled/COD exclusion reviewed. Runtime compilation/authorization/concurrency checks follow in Phase 8.
Merge notes: deploy admin JSP, servlet and DAO together with Phase 2 migration. Confirm Payment is intentionally separate from order confirmation/completion; UNPAID QR may be bank-confirmed directly if admin already sees the real transfer.

## Phase 8 - Compilation, JDBC/HTTP integration and compatibility tests
Status: Completed (remaining external/manual checks explicitly NOT RUN)

Files created: `tests/QRPaymentIntegrationTest.java`, `tests/Run-QRPaymentChecks.ps1`, `QR_PAYMENT_TEST_RESULTS.md`.
Files modified: this changelog. Production methods/mappings changed: none in this phase.
Changes/reason: dependency-free standalone test harness and repeatable PowerShell compile/test runner. Tests exercise real local SQL Server and HTTP Servlet/JSP flows with isolated temporary fixtures; positive QR checkout controller also tested using Servlet proxies and in-memory test-only receiving config, never deployed/rendered or sent to provider. Runner separates production/test output directories.
Database: migration rerun PASS; test-created accounts/customers/product/invoices/details removed by fixture ID on completion. No existing invoice/product changed; original 12 COD invoices retained. Identity gaps from tests expected, no reseeding. Zero remaining test accounts/products verified in SQL.
Verification: complete final harness run 70 assertions PASS/exit 0; covers ownership, CSRF/ADMIN-only PAID, forged statuses, cancellation/payment race, checkout race/replay, one stock debit, no payment stock changes, SQL detail failure rollback, and old mappings. All Java compiled. All JSP Jasper compile PASS with 0 errors. Existing Ant command attempted and FAIL due pre-existing missing nbproject/build-impl.xml; direct javac/Jasper compile used without changing project type. First test attempt's empty-cart CSRF lookup fixed in harness and rerun successfully; initial Jasper classpath corrected to include tomcat-juli.
Remaining tests: actual bank image/scan and interactive image-fallback/copy/responsive checks NOT RUN without verified receiving account/browser interaction. No real bank transfer. TEST_RESULTS distinguishes all 18 scenarios and these limits.
Merge notes: run harness only against local development; build artifacts stay ignored, tests are not application servlets or production dependencies. Restore existing NetBeans metadata locally if requiring IDE Ant build. Do not treat offline test config or test PAID fixture updates as real received payments.

## Phase 9 - Final review and merge/rollback guide
Status: Completed

Files created: `QR_PAYMENT_MERGE_GUIDE.md`.
Files modified: this changelog. No production method/mapping/schema changes in this phase.
Changes/reason: reviewed tracked diff and new files, documented all 10 created files / 7 modified existing files, new methods/mapping, JSP integration, SQL order, receiving configuration, COD/admin compatibility, actual checks/limits and non-destructive rollback guidance. Explicitly warns against losing QR/PAID data or reverting the cancellation guard while QR invoices exist. No commit, branch merge, reset/clean or push performed.
Database: no new schema changes; final migration rerun already passed and original COD records retained. Final fixture cleanup preserves member/seed data; only test-created artifacts removed. Local Tomcat is running feature source with blank receiving config.
Verification: Java compile PASS; all JSP Jasper compile PASS/0 errors; final complete test run 70 assertions PASS; `git diff --check` PASS. Ant fails only at existing missing nbproject/build-impl.xml import. External banking-app QR scan and interactive browser fallback/copy checks explicitly NOT RUN in TEST_RESULTS. Final git status reviewed: seven modified tracked project source/JSP files plus ten feature files; two pre-existing untracked reports untouched.
Existing feature risks/merge notes: migration precedes deploy, checkout form/controller ship together, preserve recipient's receiving properties during integration, do not deploy test classes. COD remains available without bank config. No Product Reviews/PDF/unrelated work introduced. Follow MERGE_GUIDE for exact paths, test commands and rollback conditions.
