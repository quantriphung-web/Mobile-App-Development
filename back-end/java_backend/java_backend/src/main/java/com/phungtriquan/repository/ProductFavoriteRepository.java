package com.phungtriquan.repository;

import com.phungtriquan.model.ProductFavorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductFavoriteRepository extends JpaRepository<ProductFavorite, UUID> {

    List<ProductFavorite> findByUser_IdOrderByCreatedAtDesc(UUID userId);

    Optional<ProductFavorite> findByUser_IdAndProduct_Id(UUID userId, UUID productId);

    boolean existsByUser_IdAndProduct_Id(UUID userId, UUID productId);

    void deleteByUser_IdAndProduct_Id(UUID userId, UUID productId);
}
