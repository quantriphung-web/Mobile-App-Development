package com.phungtriquan.config;

import com.phungtriquan.model.ProductReview;
import lombok.Builder;
import lombok.Data;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class ProductReviewDto {
    private Long id;
    private UUID userId;
    private String reviewerName;
    private String avatarLetter;
    private String avatarColor;
    private Integer rating;
    private String reviewText;
    private String reviewDate;
    private Boolean hasPhoto;
    private Integer helpfulCount;
    private List<String> photoUrls;

    public static ProductReviewDto from(ProductReview r) {
        return ProductReviewDto.builder()
                .id(r.getId())
                .userId(r.getUser() != null ? r.getUser().getId() : null)
                .reviewerName(r.getReviewerName())
                .avatarLetter(r.getAvatarLetter())
                .avatarColor(r.getAvatarColor())
                .rating(r.getRating())
                .reviewText(r.getReviewText())
                .reviewDate(r.getReviewDate())
                .hasPhoto(r.getHasPhoto())
                .helpfulCount(r.getHelpfulCount())
                .photoUrls(r.getPhotoUrls() != null
                        ? Arrays.asList(r.getPhotoUrls())
                        : List.of())
                .build();
    }
}