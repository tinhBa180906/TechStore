# VietQR verification results

## Follow-up: admin payment dialog and storefront header

- PASS: JavaScript syntax; all JSP Jasper compilation (0 errors); local deployed header/admin JSP/CSS/JS hashes match source.
- PASS: authenticated admin orders HTTP 200 with payment panel/dialog and preserved CSRF/fixed confirmPayment action; CSS/JS v2 HTTP 200.
- PASS: home, products and product-detail HTTP 200, removed ts-topbar markup absent, existing ADMIN product-management menu preserved.
- PASS: isolated Node VM callback checks populate correct invoice/amount/reference; checkbox gates submit; sending disables submit, duplicate events are rejected; pageshow resets controls; close callback works. No payment-changing request sent. Unicode escapes used in test expectations to avoid PowerShell stdin encoding substitution.
- NOT RUN: real browser dialog focus/keyboard/viewport visual interaction and actual payment-confirmation POST for this UI-only update. Existing controller/DAO/payment state predicates unchanged. Historical harness admin-render smoke assertion updated for the new localized panel; full blank-config harness not rerun.

## Follow-up: transfer feedback and return-to-payment action

- PASS: page JavaScript syntax validated with node --check; all JSPs compiled by Jasper with 0 errors.
- PASS: local deployed QR/history JSPs and CSS match source; history, both existing QR pages and stylesheet return HTTP 200. An existing PENDING_VERIFY invoice renders the new acknowledgement panel.
- PASS (source review): UNPAID QR/non-cancelled history reminder links to the same Invoice with “Tiếp tục thanh toán”; pending verification offers a status link, PAID/cancelled never get a pay-again CTA. Existing POST/CSRF unchanged. Spinner is only sending feedback; acknowledgement is conditional on DB-loaded PENDING_VERIFY, never a client-side claim of PAID.
- NOT RUN: interactive browser spinner/check animation, reduced-motion rendering, BFCache button-reset and clicking the new CTA on an unpaid customer invoice. No existing payment state changed for these UI checks. Historical integration assertions below are not a rerun of this follow-up.

## Follow-up: compact payment UI

- PASS: Jasper compilation of all JSPs after layout update (0 errors).
- PASS: authenticated GET of an existing QR invoice returns HTTP 200 with the new scoped layout, stylesheet and collapsed product summary; action markup is inside the payment section before product details.
- PASS: new CSS served HTTP 200; deployed JSP/CSS match source; shared CSS, Java, SQL and receiving configuration unchanged.
- PASS: code review retains CUSTOMER/UNPAID/non-cancelled declaration form, CSRF/order/action fields, paid/cancelled exclusions and manual image-failure fallback.
- NOT RUN: visual viewport inspection, real browser clipboard interaction, image-error interaction and bank scan. QR sizes are specified as 210px desktop / 176px mobile with unchanged source/aspect ratio; mobile action bar is fixed with safe-area spacing. No new database-changing tests needed for UI-only changes; historical 70-assertion results remain below.

Follow-up configuration: user-supplied Techcombank receiving details have now been installed in source and local deployment. The 70-assertion results below refer to the earlier blank-config baseline. Configuration deployment only is checked in this follow-up; actual bank scan/ownership/transfer remain NOT RUN. The full harness expects blank config and was not rerun against the receiving configuration.

Run date: 2026-11-01. Local environment: JDK 17, Apache Tomcat 10.1.59, SQL Server SQLEXPRESS, TechStore_PRJ301. No real bank transfer was made. No remote QR image was requested by the test harness.

## Build and database

| Check | Status | Evidence / limit |
| --- | --- | --- |
| Production Java compilation | PASS | All src/java sources compiled with installed Tomcat servlet API and existing JDBC/JSTL jars. |
| Test Java compilation | PASS | Standalone Java test uses existing app classes, JDK HttpClient, Servlet interfaces and JDBC; no test dependency added. |
| All JSP compilation | PASS | Tomcat Jasper JspC `-compile` completed with **0 errors**, including all new/changed JSPs and existing pages. |
| Existing NetBeans Ant build | FAIL | `ant -f build.xml compile` cannot import missing `nbproject/build-impl.xml` at build.xml:12. This file was already absent/ignored before the feature; no conversion to Maven and no replacement of existing build.xml. Direct Java/Jasper compile and runtime tests passed. |
| Migration first successful execution | PASS | Added only Invoice.PaymentStatus, method/status constraints and paid-QR guard in existing cancellation procedure. 12 pre-existing COD invoices retained as UNPAID; no historical payment inferred. |
| Migration second execution | PASS | Re-ran complete script successfully; no duplicate column/constraint. Existing OrderStatus constraint retained. |
| Fixture cleanup | PASS | Harness removed only its own IDs/unique test accounts and product in finally; SQL confirmed zero qrtest accounts/products after tests. Existing invoice count remains 12. Identity values advance normally; not reseeded. |
| Final diff whitespace | PASS | `git diff --check` returned no errors. |

## Required scenarios

Statuses below cover precisely the stated evidence. Test 05's real image/scan portion is NOT RUN; offline URL construction is independently PASS.

| Test | Status | What was executed |
| --- | --- | --- |
| 01 COD compatibility | PASS | JDBC COD create/PENDING/stock and cancellation; authenticated HTTP checkout without paymentMethod defaults COD and PRG redirects; concurrent replay creates one invoice. |
| 02 QR creates exactly one invoice | PASS | Real OrderServlet.doPost invoked with Servlet-interface proxies and **in-memory test-only config**, actual JDBC/DB writes and redirect capture: one QR invoice, correct `/payment-qr?orderId=<actual ID>` PRG, cart cleared and token consumed. Config never deployed/rendered. DAO complete-invoice check also passed. Concurrent duplicate/replay rejection tested through live HTTP shared checkout path using COD. Configured QR checkout through a real browser is NOT RUN (no legitimate receiving config supplied). |
| 03 PaymentMethod QR | PASS | Both QR controller and DAO persisted QR in SQL Server. |
| 04 PaymentStatus UNPAID | PASS | Both QR controller and DAO persisted UNPAID; forged client PAID ignored. |
| 05 Correct scannable bank QR | NOT RUN | No verified bank account supplied, so remote image/actual banking-app scan not tested. **Offline PASS:** exact bank/account path, UTF-8 accountName encoding, exact integral amount, stable TECHSTORE128; DB order total ignores amount query; invalid/zero/fractional/over-13-digit amounts rejected. Test-only fictional strings are only used in memory, never shown on the website or sent to the provider. Official docs say beneficiary name is image text, not guaranteed part of scan payload. |
| 06 QR refresh | PASS | Repeated authenticated GETs preserve invoice count, UNPAID and inventory. |
| 07 Customer declares transfer | PASS | Authenticated CSRF POST changes UNPAID -> PENDING_VERIFY; repeated POST leaves status and stock unchanged. |
| 08 Customer cannot set PAID | PASS | Direct customer POST `/admin/orders` returns 403; forged paymentStatus=PAID on customer declaration still becomes only PENDING_VERIFY; missing CSRF 403; GET declaration has no effect. |
| 09 Ownership | PASS | Customer B's GET of A's QR returns 404; foreign-owner POST rejected; DAO owner filtering checked; anonymous redirects login; ADMIN can view. |
| 10 Admin confirmation | PASS | Authenticated ADMIN CSRF POST changes QR to PAID while order remains PENDING; GET does not confirm; COD excluded from payment confirmation. |
| 11 Confirmation replay | PASS | Repeat admin POST is a no-op; stock unchanged; stale customer declaration cannot downgrade PAID; paid page tells customer not to transfer again. |
| 12 Cancelled order | PASS | DAO and HTTP admin confirmation rejected; customer declaration rejected; cancelled page contains no QR URL. Concurrent confirm vs cancel ends only PAID/PENDING with stock reserved OR UNPAID/CANCELLED with one restoration. |
| 13 Existing admin orders | PASS | Admin JSP renders; existing CONFIRMED then COMPLETED POST transitions run on paid QR; existing statistics query still returns revenue. COD create/cancel checked separately. |
| 14 Stock consistency | PASS | One debit per order; customer/admin payment changes debit zero; repeat cancellation does not restore twice; paid QR cancellation rejected; concurrent cancel/payment race has consistent stock. |
| 15 Transaction rollback | PASS | Insufficient stock leaves counts/stock unchanged. Test DAO subclass supplies negative detail price to force **real SQL constraint failure after Invoice insertion**: Invoice, InvoiceDetail and stock all roll back. No trigger or production-code failure injection added. |
| 16 Missing/forged method | PASS | Missing method creates COD; forged method rejected by DAO and live HTTP with no invoice; token replay rejected. |
| 17 Missing VietQR config | PASS | Blank config throws clear validation error before live QR checkout writes; existing QR page shows configuration warning with no fake image URL; malformed bank path rejected. COD remains usable. |
| 18 Existing mappings/JSPs | PASS | Authenticated HTTP 200 for /home, /products, /cart, /checkout, /orders, /login, /register, /profile and /product-detail; /admin/orders and /payment-qr exercised separately. All JSPs compiled with Jasper. |

Final complete harness run: **70 assertions PASS**, process exit 0, fixture cleanup PASS. Raw local output is in ignored `build/qr-check/integration-results.txt`. First harness attempt stopped because empty-cart checkout has no CSRF form; harness was corrected to obtain the existing token from product detail, then rerun successfully. No application fix was needed for that test setup error.

## Repeat the checks

Deploy these sources to local Tomcat and apply migration first. Verify DBContext points to local development DB. From project root in PowerShell (replace machine paths):

```powershell
.\tests\Run-QRPaymentChecks.ps1 `
  -TomcatHome 'D:\path\apache-tomcat-10.1.59' `
  -DeployedApp 'D:\path\tomcat-base\webapps\TechStore' `
  -JavaHome 'C:\Program Files\Java\jdk-17' `
  -BaseUrl 'http://localhost:8081/TechStore'
```

The script compiles production/test classes to separate ignored output directories. It does not deploy, migrate or restart Tomcat. Tests temporarily insert uniquely named fixture customers/accounts/product/invoices and delete only those records on completion; use local DB only. It expects blank receiving config for missing-config scenarios. It supplies a fictional config only to the in-memory controller invocation, without rendering or requesting an image.

## Explicit remaining manual checks

- NOT RUN: real receiving-account QR image generation and banking-app scan/autofill. Configure a legitimate store account, verify details/amount/reference before use; no real transfer required for checking autofill.
- NOT RUN: browser interaction for Copy buttons, responsive visual appearance and deliberately blocked external image. Their JSP/JavaScript paths were reviewed/compiled; fallback text/manual receiving details exist but actual browser network-failure rendering was not exercised.
- NOT RUN: NetBeans IDE build with restored private project metadata. Existing Ant failure and alternative compile results are reported above.
- Tests check ordinary session-token replay and local two-request races, not distributed/multi-server exactly-once guarantees or recovery from an uncertain JDBC commit/network crash.
