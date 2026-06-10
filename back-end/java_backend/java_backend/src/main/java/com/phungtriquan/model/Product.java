package com.phungtriquan.model;

import com.phungtriquan.config.SpringContext;
import com.phungtriquan.repository.StaffAccountRepository;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "products")
@Getter
@Setter
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
@org.hibernate.annotations.Check(constraints = "compare_price >= 0 AND sale_price >= 0")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(name = "product_name", nullable = false)
    private String productName;

    private String sku;

    @Column(name = "sale_price", nullable = false)
    @Builder.Default
    private BigDecimal salePrice = BigDecimal.ZERO;

    @Column(name = "compare_price")
    @Builder.Default
    private BigDecimal comparePrice = BigDecimal.ZERO;

    @Column(name = "buying_price")
    private BigDecimal buyingPrice;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 0;

    @Column(name = "short_description", nullable = false, length = 165)
    private String shortDescription;

    @Column(name = "product_description", nullable = false, columnDefinition = "TEXT")
    private String productDescription;

    @Column(name = "product_type", length = 64)
    private String productType;

    @Builder.Default
    private Boolean published = false;

    @Column(name = "disable_out_of_stock")
    @Builder.Default
    private Boolean disableOutOfStock = true;

    @Column(columnDefinition = "TEXT")
    private String note;

    private String image;
    private String placeholder;

    private String brand;
    private String size;

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductCategory> productCategories = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductTag> productTags = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<Gallery> galleries = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductImage> productImages = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<Variant> variants = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductAttribute> productAttributes = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductCoupon> productCoupons = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToOne(mappedBy = "product", cascade = CascadeType.ALL)
    @ToString.Exclude
    private ProductShippingInfo productShippingInfo;

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductSupplier> productSuppliers = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<Sell> sells = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<OrderItem> orderItems = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<CardItem> cardItems = new ArrayList<>();

    @JsonIgnoreProperties({"product"})
    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    @ToString.Exclude
    private List<ProductReview> reviews = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "id")
    @ToString.Exclude
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by", referencedColumnName = "id")
    @ToString.Exclude
    private StaffAccount updatedBy;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        resolveAuditor();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        resolveAuditor();
    }

    private void resolveAuditor() {
        try {
            StaffAccountRepository repo = SpringContext.getBean(StaffAccountRepository.class);
            if (repo != null) {
                if (this.createdBy == null) {
                    repo.findFirstByOrderByCreatedAtAsc().ifPresent(first -> this.createdBy = first);
                }
                if (this.updatedBy == null) {
                    repo.findFirstByOrderByCreatedAtAsc().ifPresent(first -> this.updatedBy = first);
                }
            }
        } catch (Exception e) {
            // Spring Context not loaded or running in a context without repository
        }
    }
}