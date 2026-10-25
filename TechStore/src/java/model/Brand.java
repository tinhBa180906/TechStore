package model;

public class Brand {
    private int brandId;
    private String brandName;
    private String country;
    private boolean isActive;

    public Brand() {
    }

    public Brand(int brandId, String brandName, String country, boolean isActive) {
        this.brandId = brandId;
        this.brandName = brandName;
        this.country = country;
        this.isActive = isActive;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
