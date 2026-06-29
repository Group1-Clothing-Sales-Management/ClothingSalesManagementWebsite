package com.clothingsale.model;

public class ReorderResult {

    private boolean success;
    private int addedItems;
    private int skippedItems;
    private String message;

    public ReorderResult(boolean success, int addedItems, int skippedItems, String message) {
        this.success = success;
        this.addedItems = addedItems;
        this.skippedItems = skippedItems;
        this.message = message;
    }

    public boolean isSuccess() {
        return success;
    }

    public int getAddedItems() {
        return addedItems;
    }

    public int getSkippedItems() {
        return skippedItems;
    }

    public String getMessage() {
        return message;
    }
}
