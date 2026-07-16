package com.clothingsale.model;

public class Ward {

    private String id;
    private String wardName;
    private String type;
    private String districtId;

    public Ward() {
    }

    public Ward(String id, String wardName, String type, String districtId) {
        this.id = id;
        this.wardName = wardName;
        this.type = type;
        this.districtId = districtId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getWardName() {
        return wardName;
    }

    public void setWardName(String wardName) {
        this.wardName = wardName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getDistrictId() {
        return districtId;
    }

    public void setDistrictId(String districtId) {
        this.districtId = districtId;
    }

}