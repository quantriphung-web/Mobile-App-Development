package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "shipping_zones")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShippingZone {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 255)
    private String name;

    @Column(name = "display_name", length = 255)
    private String displayName;

    @Column(name = "free_shipping")
    private Boolean freeShipping;

    @Column(name = "rate_type", length = 64)
    private String rateType;

    private Boolean active;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;
    @JsonIgnore
    @OneToMany(mappedBy = "shippingZone")
    private List<ShippingCountryZone> shippingCountryZones = new ArrayList<>();
    @JsonIgnore
    @OneToMany(mappedBy = "shippingZone")
    private List<ShippingRate> shippingRates = new ArrayList<>();
}
