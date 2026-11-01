package util;

import jakarta.servlet.ServletContext;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/** Quick Link only; never verifies bank transfers or changes payment state. */
public final class VietQRUtil {
    private final String bankId;
    private final String accountNo;
    private final String accountName;

    public VietQRUtil(String bankId, String accountNo, String accountName) {
        this.bankId = bankId == null ? "" : bankId.trim();
        this.accountNo = accountNo == null ? "" : accountNo.trim();
        this.accountName = accountName == null ? "" : accountName.trim();
        if (!this.bankId.matches("[A-Za-z0-9]{2,20}")
                || !this.accountNo.matches("[A-Za-z0-9]{1,19}")
                || this.accountName.isEmpty() || this.accountName.length() > 100
                || this.accountName.contains("<") || this.accountName.contains(">")
                || isPlaceholder(this.bankId) || isPlaceholder(this.accountNo)
                || isPlaceholder(this.accountName)) {
            throw new IllegalArgumentException("VietQR chưa được cấu hình hợp lệ. Vui lòng chọn COD hoặc liên hệ TechStore.");
        }
    }

    private static boolean isPlaceholder(String value) {
        String upper = value.toUpperCase(java.util.Locale.ROOT);
        return upper.contains("PLACEHOLDER") || upper.startsWith("YOUR_") || upper.startsWith("REPLACE_");
    }

    public static VietQRUtil load(ServletContext context) {
        Properties properties = new Properties();
        try (InputStream input = context.getResourceAsStream("/WEB-INF/vietqr.properties")) {
            if (input == null) throw new IOException("Missing VietQR configuration");
            properties.load(new InputStreamReader(input, StandardCharsets.UTF_8));
        } catch (IOException e) {
            context.log("Cannot load VietQR configuration", e);
            throw new IllegalArgumentException("Chưa thể tải cấu hình VietQR. Vui lòng chọn COD hoặc liên hệ TechStore.");
        }
        return new VietQRUtil(properties.getProperty("vietqr.bankId"),
                properties.getProperty("vietqr.accountNo"), properties.getProperty("vietqr.accountName"));
    }

    public static String transferContent(int orderId) {
        if (orderId < 1) throw new IllegalArgumentException("Mã đơn không hợp lệ.");
        return "TECHSTORE" + orderId;
    }

    public static String amountVnd(BigDecimal amount) {
        if (amount == null || amount.signum() <= 0)
            throw new IllegalArgumentException("Số tiền VietQR phải là số nguyên VND dương.");
        try {
            String value = amount.toBigIntegerExact().toString();
            if (value.length() > 13) throw new ArithmeticException("VietQR amount exceeds 13 digits");
            return value;
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException("Số tiền không phù hợp VietQR: cần số nguyên VND dương, tối đa 13 chữ số.");
        }
    }

    public String imageUrl(int orderId, BigDecimal amount) {
        return "https://img.vietqr.io/image/" + bankId + "-" + accountNo
                + "-compact2.svg?amount=" + amountVnd(amount)
                + "&addInfo=" + encode(transferContent(orderId)) + "&accountName=" + encode(accountName);
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    public String getBankId() { return bankId; }
    public String getAccountNo() { return accountNo; }
    public String getAccountName() { return accountName; }
}
