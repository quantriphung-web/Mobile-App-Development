package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.*;

@Entity
@Table(name = "product_shipping_info")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductShippingInfo {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(precision = 19, scale = 4)
    private BigDecimal weight;

    @Column(name = "weight_unit", length = 10)
    private String weightUnit;

    @Column(precision = 19, scale = 4)
    private BigDecimal volume;

    @Column(name = "volume_unit", length = 10)
    private String volumeUnit;

    @Column(name = "dimension_width", precision = 19, scale = 4)
    private BigDecimal dimensionWidth;

    @Column(name = "dimension_height", precision = 19, scale = 4)
    private BigDecimal dimensionHeight;

    @Column(name = "dimension_depth", precision = 19, scale = 4)
    private BigDecimal dimensionDepth;

    @Column(name = "dimension_unit", length = 10)
    private String dimensionUnit;
}
