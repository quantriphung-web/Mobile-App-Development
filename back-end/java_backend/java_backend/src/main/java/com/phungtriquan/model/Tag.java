package com.phungtriquan.model;

import com.phungtriquan.config.SpringContext;
import com.phungtriquan.repository.StaffAccountRepository;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "tags")
@Getter
@Setter
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tag {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @Column(name = "tag_name", nullable = false, unique = true)
    private String tagName;

    @Column(columnDefinition = "TEXT")
    private String icon;

    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", referencedColumnName = "id")
    @ToString.Exclude
    private StaffAccount createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by", referencedColumnName = "id")
    @ToString.Exclude
    private StaffAccount updatedBy;

    @JsonIgnore
    @OneToMany(mappedBy = "tag")
    @Builder.Default
    @ToString.Exclude
    private List<ProductTag> productTags = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
        resolveAuditor();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
        resolveAuditor();
    }

    private void resolveAuditor() {
        try {
            StaffAccountRepository repo = SpringContext.getBean(StaffAccountRepository.class);
            if (repo != null) {
                if (this.createdBy == null) {
                    repo.findFirstByOrderByCreatedAtAsc().ifPresent(first -> this.createdBy = first);
                }
                if (this.updatedBy == null) {
                    repo.findFirstByOrderByCreatedAtAsc().ifPresent(first -> this.updatedBy = first);
                }
            }
        } catch (Exception e) {
        }
    }
}
