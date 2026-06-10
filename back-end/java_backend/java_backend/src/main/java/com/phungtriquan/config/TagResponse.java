package com.phungtriquan.config;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TagResponse {
    private UUID id;
    private String tagName;
    private String icon;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
