package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "order_statuses")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class OrderStatus {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(name = "status_name", length = 255)
    private String statusName;

    @Column(length = 10)
    private String color;

    @Column(length = 10)
    private String privacy;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @OneToMany(mappedBy = "orderStatus")
    private List<Order> orders = new ArrayList<>();
}
