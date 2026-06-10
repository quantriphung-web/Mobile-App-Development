package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "suppliers")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Supplier {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(name = "supplier_name", length = 255)
    private String supplierName;

    @Column(length = 255)
    private String company;

    @Column(name = "phone_number", length = 255)
    private String phoneNumber;

    @Column(name = "address_line1", columnDefinition = "TEXT")
    private String addressLine1;

    @Column(name = "address_line2", columnDefinition = "TEXT")
    private String addressLine2;

    @Column(name = "country_id")
    private Integer countryId;

    @Column(length = 255)
    private String city;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @OneToMany(mappedBy = "supplier")
    private List<ProductSupplier> productSuppliers = new ArrayList<>();
}
