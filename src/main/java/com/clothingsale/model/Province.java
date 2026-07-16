package com.clothingsale.model;

public class Province {

    private String id;
    private String provinceName;
    private String type;

    public Province() {
    }

    public Province(String id, String provinceName, String type) {
        this.id = id;
        this.provinceName = provinceName;
        this.type = type;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

}