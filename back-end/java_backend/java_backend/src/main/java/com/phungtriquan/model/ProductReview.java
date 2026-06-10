package com.phungtriquan.model;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.Arrays;

@Entity
@Table(
    name = "product_reviews",
    uniqueConstraints = @UniqueConstraint(columnNames = {"product_id", "user_id"})
)
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ProductReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private StaffAccount user;

    @Column(name = "reviewer_name", length = 100)
    private String reviewerName;

    @Column(name = "avatar_letter", length = 5)
    private String avatarLetter;

    @Column(name = "avatar_color", length = 20)
    private String avatarColor;

    @Column(nullable = false)
    @Builder.Default
    private Integer rating = 5;

    @Column(name = "review_text", columnDefinition = "TEXT")
    private String reviewText;

    @Column(name = "review_date", length = 50)
    private String reviewDate;

    @Column(name = "has_photo")
    @Builder.Default
    private Boolean hasPhoto = false;

    @Column(name = "helpful_count")
    @Builder.Default
    private Integer helpfulCount = 0;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "photo_urls", columnDefinition = "TEXT[]")
    private String[] photoUrls;

    @Column(name = "created_at")
    @Builder.Default
    private Instant createdAt = Instant.now();

    // ✅ Trim khi load từ database
    @PostLoad
    public void trimPhotoUrls() {
        if (photoUrls != null) {
            photoUrls = Arrays.stream(photoUrls)
                    .filter(url -> url != null && !url.isBlank())
                    .map(String::trim)
                    .toArray(String[]::new);
        }
    }

    // ✅ Tách 2 method riêng để đảm bảo cả 2 đều được gọi
    @PrePersist
    public void prePersist() {
        trimBeforeSave();
    }

    @PreUpdate
    public void preUpdate() {
        trimBeforeSave();
    }

    // ✅ Logic trim dùng chung
    private void trimBeforeSave() {
        if (photoUrls != null) {
            photoUrls = Arrays.stream(photoUrls)
                    .filter(url -> url != null && !url.isBlank())
                    .map(String::trim)
                    .toArray(String[]::new);
        }
        if (reviewerName != null) reviewerName = reviewerName.trim();
        if (reviewText   != null) reviewText   = reviewText.trim();
    }
}