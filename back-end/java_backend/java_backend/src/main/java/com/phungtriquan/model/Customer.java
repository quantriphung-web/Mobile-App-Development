package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "customers")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Customer {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(columnDefinition = "TEXT")
    private String email;

    @Column(name = "password_hash", columnDefinition = "TEXT")
    private String passwordHash;

    private Boolean active;

    @Column(name = "registered_at")
    private Instant registeredAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @OneToMany(mappedBy = "customer")
    @JsonIgnore
    private List<CustomerAddress> customerAddresses = new ArrayList<>();

    @OneToMany(mappedBy = "customer")
    @JsonIgnore
    private List<Notification> notifications = new ArrayList<>();

    @OneToMany(mappedBy = "customer")
    @JsonIgnore
    private List<Order> orders = new ArrayList<>();

    @OneToMany(mappedBy = "customer")
    @JsonIgnore
    private List<Card> cards = new ArrayList<>();
}
