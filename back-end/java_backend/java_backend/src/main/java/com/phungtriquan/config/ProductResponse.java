package com.phungtriquan.config;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {
    private UUID id;
    private String slug;
    private String productName;
    private String sku;
    private BigDecimal salePrice;
    private BigDecimal comparePrice;
    private BigDecimal buyingPrice;
    private Integer quantity;
    private String shortDescription;
    private String productDescription;
    private String productType;
    private Boolean published;
    private Boolean disableOutOfStock;
    private String note;
    private String image;
    private String placeholder;
    private String brand;
    private String size;
    private List<CategoryResponse> categories;
    private List<TagResponse> tags;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<String> images; // ← THÊM VÀO CUỐI
}
