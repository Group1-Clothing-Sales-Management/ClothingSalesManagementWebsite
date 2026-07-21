package com.clothingsale.model;

/** Danh mục ngân hàng hỗ trợ tạo mã QR VietQR cho khoản hoàn tiền. */
public class RefundBank {

    private final String bankId;
    private final String bankName;

    public RefundBank(String bankId, String bankName) {
        this.bankId = bankId;
        this.bankName = bankName;
    }

    public String getBankId() { return bankId; }
    public String getBankName() { return bankName; }
}
