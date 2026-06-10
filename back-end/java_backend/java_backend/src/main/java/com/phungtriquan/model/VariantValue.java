package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "variant_values")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class VariantValue {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_id")
    private Variant variant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_value_id")
    private AttributeValue attributeValue;
}
