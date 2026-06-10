package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "variant_options")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class VariantOption {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id")
    @JsonIgnore
    private Variant variant;

    @Column(columnDefinition = "TEXT")
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    //@JsonIgnore
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_option_id")
    //@JsonIgnore
    private AttributeValue variantOptionAttribute;
}
