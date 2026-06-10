package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "shipping_country_zones")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShippingCountryZone {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_zone_id")
    private ShippingZone shippingZone;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "country_id")
    private Country country;
}
