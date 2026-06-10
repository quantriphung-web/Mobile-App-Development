package com.phungtriquan.config;

import lombok.Data;

import java.util.List;

@Data
public class UpdateReviewRequest {
    private Integer rating;
    private String reviewText;
    private List<String> photoUrls;
}
