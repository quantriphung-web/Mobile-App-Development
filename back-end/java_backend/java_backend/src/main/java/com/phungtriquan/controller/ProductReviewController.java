package com.phungtriquan.controller;

import com.phungtriquan.config.ProductReviewDto;
import com.phungtriquan.config.UpdateReviewRequest;
import com.phungtriquan.service.ProductReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProductReviewController {

    private final ProductReviewService reviewService;

    // GET /api/products/{productId}/reviews
    @GetMapping("/{productId}/reviews")
    public ResponseEntity<List<ProductReviewDto>> getReviews(
            @PathVariable UUID productId) {
        List<ProductReviewDto> result = reviewService.getReviews(productId)
                .stream()
                .map(ProductReviewDto::from)
                .toList();
        return ResponseEntity.ok(result);
    }

    // POST /api/products/{productId}/reviews  (multipart/form-data)
    @PostMapping(value = "/{productId}/reviews",
                 consumes = "multipart/form-data")
    public ResponseEntity<ProductReviewDto> createReview(
            @PathVariable UUID productId,
            @RequestParam("rating") Integer rating,
            @RequestParam(value = "reviewText", defaultValue = "") String reviewText,
            @RequestParam(value = "photos", required = false) List<MultipartFile> photos,
            Authentication authentication
    ) throws IOException {
        ProductReviewDto saved = ProductReviewDto.from(
                reviewService.createReview(productId, rating, reviewText, photos, authentication));
        return ResponseEntity.status(201).body(saved);
    }

    // PUT /api/products/{productId}/reviews/{reviewId}
    @PutMapping("/{productId}/reviews/{reviewId}")
    public ResponseEntity<ProductReviewDto> updateReview(
            @PathVariable UUID productId,
            @PathVariable Long reviewId,
            @RequestBody UpdateReviewRequest request,
            Authentication authentication) {
        return ResponseEntity.ok(
                ProductReviewDto.from(
                        reviewService.updateReview(productId, reviewId, request, authentication)));
    }

    // DELETE /api/products/{productId}/reviews/{reviewId}
    @DeleteMapping("/{productId}/reviews/{reviewId}")
    public ResponseEntity<Void> deleteReview(
            @PathVariable UUID productId,
            @PathVariable Long reviewId,
            Authentication authentication) {
        reviewService.deleteReview(productId, reviewId, authentication);
        return ResponseEntity.noContent().build();
    }

    // POST /api/products/{productId}/reviews/{reviewId}/helpful
    @PostMapping("/{productId}/reviews/{reviewId}/helpful")
    public ResponseEntity<ProductReviewDto> markHelpful(
            @PathVariable UUID productId,
            @PathVariable Long reviewId) {
        return reviewService.markHelpful(reviewId)
                .map(r -> ResponseEntity.ok(ProductReviewDto.from(r)))
                .orElse(ResponseEntity.notFound().build());
    }
}