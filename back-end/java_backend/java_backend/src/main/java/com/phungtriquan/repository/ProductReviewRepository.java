package com.phungtriquan.repository;

import com.phungtriquan.model.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {
    List<ProductReview> findByProductIdOrderByCreatedAtDesc(UUID productId);

    Optional<ProductReview> findByProductIdAndUser_Id(UUID productId, UUID userId);

    boolean existsByProductIdAndUser_Id(UUID productId, UUID userId);
}
