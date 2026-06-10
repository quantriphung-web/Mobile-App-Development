package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "product_attribute_values")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductAttributeValue {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_attribute_id")
    private ProductAttribute productAttribute;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attribute_value_id")
    private AttributeValue attributeValue;
}
