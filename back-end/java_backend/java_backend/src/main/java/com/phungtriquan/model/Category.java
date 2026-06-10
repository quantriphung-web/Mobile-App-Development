package com.phungtriquan.model;

import com.phungtriquan.config.SpringContext;
import com.phungtriquan.repository.StaffAccountRepository;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "categories")
@Getter
@Setter
@ToString
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id", referencedColumnName = "id")
    @ToString.Exclude
    private Category parent;

    @Column(name = "category_name", nullable = false, unique = true)
    private String categoryName;

    @Column(name = "category_description", columnDefinition = "TEXT")
    private String categoryDescription;

    private String icon;
    private String image;
    private String placeholder;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "category_genres", joinColumns = @JoinColumn(name = "category_id"))
    @Column(name = "genre")
    @Builder.Default
    private Set<String> genres = new HashSet<>();

    @JsonIgnore
    @OneToMany(mappedBy = "category")
    @Builder.Default
    @ToString.Exclude
    private List<ProductCategory> productCategories = new ArrayList<>();

    @Builder.Default
    private Boolean active = true;

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
            // Spring Context not loaded or running in a context without repository (e.g. some tests)
        }
    }
}
