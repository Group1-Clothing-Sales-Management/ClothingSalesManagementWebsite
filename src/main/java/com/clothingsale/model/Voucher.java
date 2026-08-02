package com.clothingsale.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.StringJoiner;
import java.util.concurrent.TimeUnit;

public class Voucher {

    private int id;
    private String code;
    private String title;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal maxDiscountAmount;
    private BigDecimal minOrderValue;
    private Timestamp startDate;
    private Timestamp endDate;
    private int usageLimit;
    private int usedCount;
    private int limitPerUser;
    private String terminateReason;

    /*
     * Multi-category scope:
     * - categoryId == null: entire store.
     * - categoryId != null: selected parent/group category.
     * - selectedCategoryIds: the categories that actually receive the voucher.
     *
     * Voucher.category_id is retained as the selected parent/group so the
     * existing database can be migrated without dropping the column.
     */
    private Integer categoryId;
    private String categoryName;
    private Integer categoryParentId;
    private boolean categoryHasChildren;
    private boolean categoryScopeActive = true;
    private List<Integer> selectedCategoryIds = new ArrayList<>();
    private List<String> selectedCategoryNames = new ArrayList<>();

    private int userUsedCount;
    private BigDecimal applicableSubtotal = BigDecimal.ZERO;
    private BigDecimal applicableDiscount = BigDecimal.ZERO;
    private BigDecimal amountNeeded = BigDecimal.ZERO;
    private boolean eligibleForCheckout;
    private String checkoutIneligibilityReason;

    public Voucher() {
    }

    public Voucher(
            int id,
            String code,
            String title,
            String discountType,
            BigDecimal discountValue,
            BigDecimal maxDiscountAmount,
            BigDecimal minOrderValue,
            Timestamp startDate,
            Timestamp endDate,
            int usageLimit,
            int usedCount,
            int limitPerUser,
            String terminateReason,
            Integer categoryId) {

        this.id = id;
        this.code = code;
        this.title = title;
        this.discountType = discountType;
        this.discountValue = discountValue;
        this.maxDiscountAmount = maxDiscountAmount;
        this.minOrderValue = minOrderValue;
        this.startDate = startDate;
        this.endDate = endDate;
        this.usageLimit = usageLimit;
        this.usedCount = usedCount;
        this.limitPerUser = limitPerUser;
        this.terminateReason = terminateReason;
        this.categoryId = categoryId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public int getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(int usageLimit) {
        this.usageLimit = usageLimit;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isAvailable() {
        return usageLimit > 0 && usedCount < usageLimit;
    }

    public int getLimitPerUser() {
        return limitPerUser;
    }

    public void setLimitPerUser(int limitPerUser) {
        this.limitPerUser = limitPerUser;
    }

    public String getTerminateReason() {
        return terminateReason;
    }

    public void setTerminateReason(String terminateReason) {
        this.terminateReason = terminateReason;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public Integer getCategoryParentId() {
        return categoryParentId;
    }

    public void setCategoryParentId(Integer categoryParentId) {
        this.categoryParentId = categoryParentId;
    }

    public boolean isCategoryHasChildren() {
        return categoryHasChildren;
    }

    public void setCategoryHasChildren(boolean categoryHasChildren) {
        this.categoryHasChildren = categoryHasChildren;
    }

    public boolean isCategoryScopeActive() {
        return categoryScopeActive;
    }

    public void setCategoryScopeActive(boolean categoryScopeActive) {
        this.categoryScopeActive = categoryScopeActive;
    }

    public List<Integer> getSelectedCategoryIds() {
        return selectedCategoryIds;
    }

    public void setSelectedCategoryIds(List<Integer> selectedCategoryIds) {
        this.selectedCategoryIds = selectedCategoryIds == null
                ? new ArrayList<>()
                : new ArrayList<>(selectedCategoryIds);
    }

    public void addSelectedCategoryId(Integer categoryId) {
        if (categoryId != null && !selectedCategoryIds.contains(categoryId)) {
            selectedCategoryIds.add(categoryId);
        }
    }

    public List<String> getSelectedCategoryNames() {
        return selectedCategoryNames;
    }

    public void setSelectedCategoryNames(List<String> selectedCategoryNames) {
        this.selectedCategoryNames = selectedCategoryNames == null
                ? new ArrayList<>()
                : new ArrayList<>(selectedCategoryNames);
    }

    public void addSelectedCategoryName(String categoryName) {
        if (categoryName != null && !categoryName.trim().isEmpty()) {
            selectedCategoryNames.add(categoryName.trim());
        }
    }

    public int getSelectedCategoryCount() {
        return selectedCategoryIds == null ? 0 : selectedCategoryIds.size();
    }

    public int getUserUsedCount() {
        return userUsedCount;
    }

    public void setUserUsedCount(int userUsedCount) {
        this.userUsedCount = userUsedCount;
    }

    public BigDecimal getApplicableSubtotal() {
        return applicableSubtotal;
    }

    public void setApplicableSubtotal(BigDecimal applicableSubtotal) {
        this.applicableSubtotal = safeMoney(applicableSubtotal);
    }

    public BigDecimal getApplicableDiscount() {
        return applicableDiscount;
    }

    public void setApplicableDiscount(BigDecimal applicableDiscount) {
        this.applicableDiscount = safeMoney(applicableDiscount);
    }

    public BigDecimal getAmountNeeded() {
        return amountNeeded;
    }

    public void setAmountNeeded(BigDecimal amountNeeded) {
        this.amountNeeded = safeMoney(amountNeeded);
    }

    public boolean isEligibleForCheckout() {
        return eligibleForCheckout;
    }

    public void setEligibleForCheckout(boolean eligibleForCheckout) {
        this.eligibleForCheckout = eligibleForCheckout;
    }

    public String getCheckoutIneligibilityReason() {
        return checkoutIneligibilityReason;
    }

    public void setCheckoutIneligibilityReason(String checkoutIneligibilityReason) {
        this.checkoutIneligibilityReason = checkoutIneligibilityReason;
    }

    public boolean isGlobalScope() {
        return categoryId == null;
    }

    public boolean isRootCategoryScope() {
        return categoryId != null;
    }

    public String getScopeLabel() {
        if (isGlobalScope()) {
            return "Entire Store";
        }

        if (selectedCategoryNames == null || selectedCategoryNames.isEmpty()) {
            String parent = categoryName == null || categoryName.trim().isEmpty()
                    ? "Selected categories"
                    : categoryName.trim();
            return parent;
        }

        StringJoiner joiner = new StringJoiner(", ");
        for (String selectedName : selectedCategoryNames) {
            if (selectedName != null && !selectedName.trim().isEmpty()) {
                joiner.add(selectedName.trim());
            }
        }

        String selectedText = joiner.toString();
        if (selectedText.isEmpty()) {
            return "Selected categories";
        }

        return selectedText;
    }

    public String getScopeGroupLabel() {
        if (isGlobalScope()) {
            return "Entire Store";
        }

        String parent = categoryName == null || categoryName.trim().isEmpty()
                ? "Category group"
                : categoryName.trim();
        return parent + " · " + getSelectedCategoryCount() + " selected";
    }

    public String getCustomerStatus() {
        long now = System.currentTimeMillis();

        if (limitPerUser > 0 && userUsedCount >= limitPerUser) {
            return "USED";
        }

        if (startDate == null || endDate == null) {
            return "EXPIRED";
        }

        if (startDate.getTime() > now) {
            return "UPCOMING";
        }

        if (endDate.getTime() < now) {
            return "EXPIRED";
        }

        if (!isAvailable()) {
            return "EXHAUSTED";
        }

        return "AVAILABLE";
    }

    public long getDaysRemaining() {
        if (endDate == null) {
            return 0;
        }

        long remaining = endDate.getTime() - System.currentTimeMillis();

        return Math.max(
                0,
                (long) Math.ceil(
                        remaining
                        / (double) TimeUnit.DAYS.toMillis(1)
                )
        );
    }

    private BigDecimal safeMoney(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}