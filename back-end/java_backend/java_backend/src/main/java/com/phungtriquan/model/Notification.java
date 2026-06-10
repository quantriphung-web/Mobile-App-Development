package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "notifications")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Notification {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id")
    private Customer customer;

    @Column(length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private Boolean seen;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "receive_time")
    private Instant receiveTime;

    @Column(name = "notification_expiry_date")
    private java.time.LocalDate notificationExpiryDate;
}
