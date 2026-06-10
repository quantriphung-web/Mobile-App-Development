package com.phungtriquan.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "slideshows")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Slideshow {

    @Id
    //@GeneratedValue
    @Column(columnDefinition = "uuid", updatable = false)
    private UUID id;

    @Column(length = 80)
    private String title;

    @Column(name = "destination_url", columnDefinition = "TEXT")
    private String destinationUrl;

    @Column(columnDefinition = "TEXT")
    private String image;

    @Column(columnDefinition = "TEXT")
    private String placeholder;

    @Column(length = 160)
    private String description;

    @Column(name = "btn_label", length = 50)
    private String btnLabel;

    @Column(name = "display_order")
    private Integer displayOrder;

    private Boolean published;

    private Integer clicks;

    @Column(columnDefinition = "TEXT")
    private String styles;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;
}
