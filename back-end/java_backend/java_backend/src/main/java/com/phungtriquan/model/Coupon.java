package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "coupons")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Coupon {

    @Id
    
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(length = 50)
    private String code;

    @Column(name = "discount_value", precision = 19, scale = 4)
    private BigDecimal discountValue;

    @Column(name = "discount_type", length = 50)
    private String discountType;

    @Column(name = "times_used", precision = 19, scale = 4)
    private BigDecimal timesUsed;

    @Column(name = "max_usage", precision = 19, scale = 4)
    private BigDecimal maxUsage;

    @Column(name = "order_amount_limit", precision = 19, scale = 4)
    private BigDecimal orderAmountLimit;

    @Column(name = "coupon_start_date")
    private Instant couponStartDate;

    @Column(name = "coupon_end_date")
    private Instant couponEndDate;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @OneToMany(mappedBy = "coupon")
    private List<ProductCoupon> productCoupons = new ArrayList<>();
}
