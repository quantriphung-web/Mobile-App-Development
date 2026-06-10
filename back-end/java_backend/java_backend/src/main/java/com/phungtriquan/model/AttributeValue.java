package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "attribute_values")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class AttributeValue {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "attribute_id")
    @JsonIgnoreProperties({"attributeValues", "productAttributes"})
    private Attribute attribute;

    @Column(name = "attribute_value", length = 255)
    private String attributeValue;

    @Column(length = 50)
    private String color;
    @JsonIgnore
    @OneToMany(mappedBy = "attributeValue")
    private List<VariantValue> variantValues = new ArrayList<>();
}
