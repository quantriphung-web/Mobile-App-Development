package com.phungtriquan.config;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductRequest {
    private String slug;

    @NotBlank
    private String productName;

    private String sku;
    private BigDecimal salePrice;
    private BigDecimal comparePrice;
    private BigDecimal buyingPrice;
    private Integer quantity;

    @NotBlank
    private String shortDescription;

    @NotBlank
    private String productDescription;

    private String productType;
    private Boolean published;
    private Boolean disableOutOfStock;
    private String note;
    private String image;
    private String placeholder;
    private String brand;
    private String size;

    private List<UUID> categoryIds;
    private List<UUID> tagIds;
}
