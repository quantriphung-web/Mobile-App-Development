package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "customer_addresses")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CustomerAddress {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    
    private Customer customer;

    @Column(name = "address_line1", columnDefinition = "TEXT")
    private String addressLine1;

    @Column(name = "address_line2", columnDefinition = "TEXT")
    private String addressLine2;

    @Column(name = "phone_number", length = 255)
    private String phoneNumber;

    @Column(name = "dial_code", length = 100)
    private String dialCode;

    @Column(length = 255)
    private String country;

    @Column(name = "postal_code", length = 255)
    private String postalCode;

    @Column(length = 255)
    private String city;
}
