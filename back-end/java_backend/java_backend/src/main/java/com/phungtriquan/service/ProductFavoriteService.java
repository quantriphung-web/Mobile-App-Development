package com.phungtriquan.service;

import com.phungtriquan.config.BadRequestException;
import com.phungtriquan.config.ProductResponse;
import com.phungtriquan.model.Product;
import com.phungtriquan.model.ProductFavorite;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.ProductFavoriteRepository;
import com.phungtriquan.repository.ProductRepository;
import com.phungtriquan.repository.StaffAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductFavoriteService {

    private final ProductFavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;
    private final StaffAccountRepository staffAccountRepository;
    private final ProductService productService;

    @Transactional(readOnly = true)
    public List<ProductResponse> getUserFavorites(Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        return favoriteRepository.findByUser_IdOrderByCreatedAtDesc(user.getId())
                .stream()
                .map(ProductFavorite::getProduct)
                .map(productService::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<UUID> getFavoriteProductIds(Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        return favoriteRepository.findByUser_IdOrderByCreatedAtDesc(user.getId())
                .stream()
                .map(f -> f.getProduct().getId())
                .toList();
    }

    @Transactional(readOnly = true)
    public boolean isFavorite(UUID productId, Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        return favoriteRepository.existsByUser_IdAndProduct_Id(user.getId(), productId);
    }

    @Transactional
    public void addFavorite(UUID productId, Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new BadRequestException("Product not found"));

        if (favoriteRepository.existsByUser_IdAndProduct_Id(user.getId(), productId)) {
            return;
        }

        favoriteRepository.save(ProductFavorite.builder()
                .user(user)
                .product(product)
                .createdAt(Instant.now())
                .build());
    }

    @Transactional
    public void removeFavorite(UUID productId, Authentication authentication) {
        StaffAccount user = getAuthenticatedUser(authentication);
        favoriteRepository.deleteByUser_IdAndProduct_Id(user.getId(), productId);
    }

    private StaffAccount getAuthenticatedUser(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new BadRequestException("Authentication required");
        }
        return staffAccountRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new BadRequestException("User not found"));
    }
}
