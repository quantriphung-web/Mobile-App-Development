package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "variants")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Variant {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(columnDefinition = "TEXT")
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "image_id")
    @JsonIgnore 
    private Gallery image;

    @Column(name = "variant_option", columnDefinition = "TEXT")
    private String variantOption;

    @Column(length = 255)
    private String sku;

    @Column(name = "sale_price", precision = 19, scale = 4)
    private BigDecimal salePrice;

    @Column(name = "compare_price", precision = 19, scale = 4)
    private BigDecimal comparePrice;

    @Column(name = "buying_price", precision = 19, scale = 4)
    private BigDecimal buyingPrice;

    private Integer quantity;

    private Boolean active;

    @OneToMany(mappedBy = "variant")
    private List<VariantOption> variantOptions = new ArrayList<>();
}
