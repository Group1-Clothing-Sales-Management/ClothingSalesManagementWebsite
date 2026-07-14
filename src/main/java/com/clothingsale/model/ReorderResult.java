package com.clothingsale.model;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

public class ReorderResult {

    private boolean success;
    private int addedItems;
    private int skippedItems;
    private String message;
    private Set<Integer> variantIds;

    public ReorderResult(boolean success, int addedItems, int skippedItems, String message) {
        this(success, addedItems, skippedItems, message, Collections.emptySet());
    }

    public ReorderResult(boolean success, int addedItems, int skippedItems,
            String message, Set<Integer> variantIds) {
        this.success = success;
        this.addedItems = addedItems;
        this.skippedItems = skippedItems;
        this.message = message;
        this.variantIds = variantIds == null
                ? Collections.emptySet()
                : Collections.unmodifiableSet(new LinkedHashSet<>(variantIds));
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

    public Set<Integer> getVariantIds() {
        return variantIds;
    }
}
