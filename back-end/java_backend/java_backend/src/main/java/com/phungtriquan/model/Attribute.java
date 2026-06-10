package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "attributes")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Attribute {

    @Id
    //@GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(name = "attribute_name", length = 255)
    private String attributeName;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @OneToMany(mappedBy = "attribute")
    @JsonIgnoreProperties({"attribute"})
    private List<AttributeValue> attributeValues = new ArrayList<>();

    @OneToMany(mappedBy = "attribute")
    @JsonIgnoreProperties({"attribute"})
    private List<ProductAttribute> productAttributes = new ArrayList<>();
}
