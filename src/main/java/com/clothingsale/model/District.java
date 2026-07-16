package com.clothingsale.model;

public class District {

    private String id;
    private String districtName;
    private String type;
    private String provinceId;

    public District() {
    }

    public District(String id, String districtName, String type, String provinceId) {
        this.id = id;
        this.districtName = districtName;
        this.type = type;
        this.provinceId = provinceId;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(String provinceId) {
        this.provinceId = provinceId;
    }

}