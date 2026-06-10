package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "orders")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Order {

    @Id
    @Column(length = 50)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id")
    //@JsonIgnore
    private Coupon coupon;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id")
    //@JsonIgnore
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_status_id")
    @JsonIgnore
    private OrderStatus orderStatus;

    @Column(name = "order_approved_at")
    private Instant orderApprovedAt;

    @Column(name = "order_delivered_carrier_date")
    private Instant orderDeliveredCarrierDate;

    @Column(name = "order_delivered_customer_date")
    private Instant orderDeliveredCustomerDate;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @OneToMany(mappedBy = "order")
    private List<OrderItem> orderItems = new ArrayList<>();
}
