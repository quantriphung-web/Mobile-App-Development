package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "countries")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Country {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 2)
    private String iso;

    @Column(length = 80)
    private String name;

    @Column(name = "upper_name", length = 80)
    private String upperName;

    @Column(length = 3)
    private String iso3;

    private Integer numCode;

    @Column(name = "phone_code")
    private Integer phoneCode;
    @JsonIgnore
    @OneToMany(mappedBy = "country")
    private List<ShippingCountryZone> shippingCountryZones = new ArrayList<>();
}
