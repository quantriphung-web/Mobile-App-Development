package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "card_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class CardItem {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "card_id")
    @JsonIgnore
    private Card card;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    
    private Product product;

    private Integer quantity;
}
