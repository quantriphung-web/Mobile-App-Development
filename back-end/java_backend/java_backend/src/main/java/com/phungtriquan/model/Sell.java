package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.util.*;

@Entity
@Table(name = "sells")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Sell {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(precision = 19, scale = 4)
    private BigDecimal price;

    private Integer quantity;
}
