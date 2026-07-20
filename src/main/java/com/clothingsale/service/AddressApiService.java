package com.clothingsale.service;

import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.annotations.SerializedName;
import com.google.gson.reflect.TypeToken;
import java.io.IOException;
import java.lang.reflect.Type;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class AddressApiService {

    private static final String BASE_URL
            = "https://provinces.open-api.vn/api/v2";

    private static final long CACHE_TIME
            = Duration.ofHours(12).toMillis();

    private final HttpClient httpClient;
    private final Gson gson;

    private CacheEntry<List<AddressOption>> provinceCache;

    private final Map<String, CacheEntry<List<AddressOption>>> wardCache
            = new ConcurrentHashMap<>();

    public AddressApiService() {
        this.gson = new Gson();

        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(8))
                .followRedirects(HttpClient.Redirect.NORMAL)
                .build();
    }

    public List<AddressOption> getProvinces() throws IOException {
        if (isValidCache(provinceCache)) {
            return provinceCache.getData();
        }

        synchronized (this) {
            if (isValidCache(provinceCache)) {
                return provinceCache.getData();
            }

            Type type = new TypeToken<List<ProvinceResponse>>() {
            }.getType();

            List<ProvinceResponse> apiResult;

            try {
                apiResult = getJson(
                        URI.create(BASE_URL + "/p/"),
                        type
                );
            } catch (IOException ex) {
                if (provinceCache != null
                        && provinceCache.getData() != null
                        && !provinceCache.getData().isEmpty()) {
                    return provinceCache.getData();
                }

                throw ex;
            }

            List<AddressOption> result = new ArrayList<>();

            if (apiResult != null) {
                for (ProvinceResponse province : apiResult) {
                    if (province == null
                            || province.getCode() <= 0
                            || isBlank(province.getName())) {
                        continue;
                    }

                    result.add(new AddressOption(
                            String.valueOf(province.getCode()),
                            province.getName().trim()
                    ));
                }
            }

            result.sort(Comparator.comparing(
                    AddressOption::getName,
                    String.CASE_INSENSITIVE_ORDER
            ));

            result = Collections.unmodifiableList(result);

            provinceCache = new CacheEntry<>(
                    result,
                    System.currentTimeMillis() + CACHE_TIME
            );

            return result;
        }
    }

    public List<AddressOption> getWards(String provinceCode)
            throws IOException {

        String normalizedProvinceCode
                = validateCode(provinceCode, "Province code");

        CacheEntry<List<AddressOption>> currentCache
                = wardCache.get(normalizedProvinceCode);

        if (isValidCache(currentCache)) {
            return currentCache.getData();
        }

        synchronized (wardCache) {
            currentCache = wardCache.get(normalizedProvinceCode);

            if (isValidCache(currentCache)) {
                return currentCache.getData();
            }

            Type type = new TypeToken<List<WardResponse>>() {
            }.getType();

            List<WardResponse> apiResult;

            try {
                URI uri = URI.create(
                        BASE_URL
                        + "/w/?province="
                        + normalizedProvinceCode
                );

                apiResult = getJson(uri, type);
            } catch (IOException ex) {
                if (currentCache != null
                        && currentCache.getData() != null
                        && !currentCache.getData().isEmpty()) {
                    return currentCache.getData();
                }

                throw ex;
            }

            int expectedProvinceCode
                    = Integer.parseInt(normalizedProvinceCode);

            List<AddressOption> result = new ArrayList<>();

            if (apiResult != null) {
                for (WardResponse ward : apiResult) {
                    if (ward == null
                            || ward.getCode() <= 0
                            || ward.getProvinceCode()
                            != expectedProvinceCode
                            || isBlank(ward.getName())) {
                        continue;
                    }

                    result.add(new AddressOption(
                            String.valueOf(ward.getCode()),
                            ward.getName().trim()
                    ));
                }
            }

            result.sort(Comparator.comparing(
                    AddressOption::getName,
                    String.CASE_INSENSITIVE_ORDER
            ));

            result = Collections.unmodifiableList(result);

            wardCache.put(
                    normalizedProvinceCode,
                    new CacheEntry<>(
                            result,
                            System.currentTimeMillis() + CACHE_TIME
                    )
            );

            return result;
        }
    }

    public ResolvedAddress resolveAddress(
            String provinceCode,
            String wardCode) throws IOException {

        String validProvinceCode
                = validateCode(provinceCode, "Province code");

        String validWardCode
                = validateCode(wardCode, "Ward code");

        AddressOption selectedProvince = findByCode(
                getProvinces(),
                validProvinceCode
        );

        if (selectedProvince == null) {
            throw new IllegalArgumentException(
                    "Selected province does not exist."
            );
        }

        AddressOption selectedWard = findByCode(
                getWards(validProvinceCode),
                validWardCode
        );

        if (selectedWard == null) {
            throw new IllegalArgumentException(
                    "Selected ward does not belong to selected province."
            );
        }

        return new ResolvedAddress(
                selectedProvince.getCode(),
                selectedProvince.getName(),
                selectedWard.getCode(),
                selectedWard.getName()
        );
    }

    private AddressOption findByCode(
            List<AddressOption> list,
            String code) {

        if (list == null) {
            return null;
        }

        for (AddressOption option : list) {
            if (option != null
                    && code.equals(option.getCode())) {
                return option;
            }
        }

        return null;
    }

    private <T> List<T> getJson(
            URI uri,
            Type responseType) throws IOException {

        HttpRequest request = HttpRequest.newBuilder()
                .uri(uri)
                .timeout(Duration.ofSeconds(12))
                .header("Accept", "application/json")
                .header("User-Agent", "ClothingSale/1.0")
                .GET()
                .build();

        try {
            HttpResponse<String> response
                    = httpClient.send(
                            request,
                            HttpResponse.BodyHandlers.ofString()
                    );

            if (response.statusCode() != 200) {
                throw new IOException(
                        "Address API returned HTTP "
                        + response.statusCode()
                );
            }

            List<T> data = gson.fromJson(
                    response.body(),
                    responseType
            );

            return data == null
                    ? Collections.emptyList()
                    : data;

        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();

            throw new IOException(
                    "Address API request was interrupted.",
                    ex
            );

        } catch (JsonParseException ex) {
            throw new IOException(
                    "Address API returned invalid JSON.",
                    ex
            );
        }
    }

    private String validateCode(
            String code,
            String fieldName) {

        if (isBlank(code)) {
            throw new IllegalArgumentException(
                    fieldName + " is required."
            );
        }

        String value = code.trim();

        if (!value.matches("\\d{1,10}")) {
            throw new IllegalArgumentException(
                    fieldName + " is invalid."
            );
        }

        return value;
    }

    private boolean isValidCache(CacheEntry<?> cache) {
        return cache != null
                && cache.getData() != null
                && System.currentTimeMillis()
                < cache.getExpiredAt();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static class ProvinceResponse {

        private String name;
        private int code;

        public String getName() {
            return name;
        }

        public int getCode() {
            return code;
        }
    }

    private static class WardResponse {

        private String name;
        private int code;

        @SerializedName("province_code")
        private int provinceCode;

        public String getName() {
            return name;
        }

        public int getCode() {
            return code;
        }

        public int getProvinceCode() {
            return provinceCode;
        }
    }

    private static class CacheEntry<T> {

        private final T data;
        private final long expiredAt;

        public CacheEntry(T data, long expiredAt) {
            this.data = data;
            this.expiredAt = expiredAt;
        }

        public T getData() {
            return data;
        }

        public long getExpiredAt() {
            return expiredAt;
        }
    }

    public static class AddressOption {

        private final String code;
        private final String name;

        public AddressOption(String code, String name) {
            this.code = code;
            this.name = name;
        }

        public String getCode() {
            return code;
        }

        public String getName() {
            return name;
        }
    }

    public static class ResolvedAddress {

        private final String provinceCode;
        private final String provinceName;
        private final String wardCode;
        private final String wardName;

        public ResolvedAddress(
                String provinceCode,
                String provinceName,
                String wardCode,
                String wardName) {

            this.provinceCode = provinceCode;
            this.provinceName = provinceName;
            this.wardCode = wardCode;
            this.wardName = wardName;
        }

        public String getProvinceCode() {
            return provinceCode;
        }

        public String getProvinceName() {
            return provinceName;
        }

        public String getWardCode() {
            return wardCode;
        }

        public String getWardName() {
            return wardName;
        }
    }
}
