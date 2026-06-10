package com.phungtriquan.config;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryRequest {
    private UUID parentId;

    @NotBlank
    private String categoryName;

    private String categoryDescription;
    private String icon;
    private String image;
    private String placeholder;
    private Boolean active;
    private Set<String> genres;
}
