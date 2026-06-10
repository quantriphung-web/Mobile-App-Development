package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;

@Entity
@Table(name = "cards")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Card {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    
    private Customer customer;

    @OneToMany(mappedBy = "card")
    
    private List<CardItem> cardItems = new ArrayList<>();
}
