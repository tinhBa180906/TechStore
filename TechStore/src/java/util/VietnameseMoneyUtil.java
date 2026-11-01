package util;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

/** Integral VND to Vietnamese words. No rounding and no third-party library. */
public final class VietnameseMoneyUtil {
    private static final String[] DIGITS = {"không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"};
    private static final String[] SMALL_SCALES = {"", "nghìn", "triệu"};
    private VietnameseMoneyUtil() { }

    public static String toWords(BigDecimal amount) {
        if (amount == null || amount.signum() < 0) throw new IllegalArgumentException("Số tiền VND không hợp lệ.");
        BigInteger value;
        try { value = amount.toBigIntegerExact(); }
        catch (ArithmeticException e) { throw new IllegalArgumentException("Số tiền VND phải là số nguyên."); }
        if (value.signum() == 0) return "Không đồng.";
        List<Integer> groups = new ArrayList<>();
        BigInteger thousand = BigInteger.valueOf(1000);
        while (value.signum() > 0) {
            BigInteger[] split = value.divideAndRemainder(thousand);
            groups.add(split[1].intValue()); value = split[0];
        }
        StringBuilder words = new StringBuilder();
        for (int i = groups.size() - 1; i >= 0; i--) {
            int group = groups.get(i);
            if (group == 0) continue;
            String scale = (SMALL_SCALES[i % 3] + " tỷ".repeat(i / 3)).trim();
            if (words.length() > 0) words.append(' ');
            words.append(readGroup(group, words.length() > 0));
            if (!scale.isEmpty()) words.append(' ').append(scale);
        }
        return Character.toUpperCase(words.charAt(0)) + words.substring(1) + " đồng.";
    }

    private static String readGroup(int value, boolean full) {
        int hundreds = value / 100, tens = value / 10 % 10, ones = value % 10;
        StringBuilder text = new StringBuilder();
        if (hundreds > 0 || full) text.append(DIGITS[hundreds]).append(" trăm");
        if (tens > 1) append(text, DIGITS[tens] + " mươi");
        else if (tens == 1) append(text, "mười");
        else if (ones > 0 && (hundreds > 0 || full)) append(text, "lẻ");
        if (ones > 0) append(text, ones == 1 && tens > 1 ? "mốt" : ones == 5 && tens > 0 ? "lăm" : DIGITS[ones]);
        return text.toString();
    }

    private static void append(StringBuilder text, String word) {
        if (text.length() > 0) text.append(' ');
        text.append(word);
    }
}
