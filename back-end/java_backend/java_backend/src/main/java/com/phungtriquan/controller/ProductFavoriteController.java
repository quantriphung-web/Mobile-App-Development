package com.phungtriquan.controller;

import com.phungtriquan.config.ProductResponse;
import com.phungtriquan.service.ProductFavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProductFavoriteController {

    private final ProductFavoriteService favoriteService;

    @GetMapping
    public ResponseEntity<List<ProductResponse>> getFavorites(Authentication authentication) {
        return ResponseEntity.ok(favoriteService.getUserFavorites(authentication));
    }

    @GetMapping("/ids")
    public ResponseEntity<List<UUID>> getFavoriteIds(Authentication authentication) {
        return ResponseEntity.ok(favoriteService.getFavoriteProductIds(authentication));
    }

    @GetMapping("/{productId}/status")
    public ResponseEntity<Map<String, Boolean>> getFavoriteStatus(
            @PathVariable UUID productId,
            Authentication authentication) {
        boolean favorited = favoriteService.isFavorite(productId, authentication);
        return ResponseEntity.ok(Map.of("favorited", favorited));
    }

    @PostMapping("/{productId}")
    public ResponseEntity<Map<String, Boolean>> addFavorite(
            @PathVariable UUID productId,
            Authentication authentication) {
        favoriteService.addFavorite(productId, authentication);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("favorited", true));
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<Void> removeFavorite(
            @PathVariable UUID productId,
            Authentication authentication) {
        favoriteService.removeFavorite(productId, authentication);
        return ResponseEntity.noContent().build();
    }
}
