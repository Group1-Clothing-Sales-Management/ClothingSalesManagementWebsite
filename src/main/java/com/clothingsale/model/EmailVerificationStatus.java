package com.clothingsale.model;

public enum EmailVerificationStatus {
    SUCCESS,
    USER_NOT_FOUND,
    NOT_PENDING,
    ALREADY_ACTIVE,
    INVALID_CODE,
    CODE_USED,
    CODE_EXPIRED,
    ERROR
}
