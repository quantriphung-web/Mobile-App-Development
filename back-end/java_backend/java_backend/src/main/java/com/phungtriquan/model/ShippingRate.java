package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "shipping_rates")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShippingRate {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_zone_id")
    private ShippingZone shippingZone;

    @Column(name = "weight_unit", length = 10)
    private String weightUnit;

    @Column(name = "min_value", precision = 19, scale = 4)
    private BigDecimal minValue;

    @Column(name = "max_value", precision = 19, scale = 4)
    private BigDecimal maxValue;

    @Column(name = "no_max")
    private Boolean noMax;

    @Column(precision = 19, scale = 4)
    private BigDecimal price;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;
}
