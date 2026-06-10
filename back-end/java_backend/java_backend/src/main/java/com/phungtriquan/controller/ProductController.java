package com.phungtriquan.controller;

import com.phungtriquan.config.ProductRequest;
import com.phungtriquan.config.ProductResponse;
import com.phungtriquan.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ProductController {

    private final ProductService productService;

    // ───── THÊM MỚI ─────
    @GetMapping("/sale")
    public ResponseEntity<List<ProductResponse>> getSaleProducts() {
        return ResponseEntity.ok(productService.getSaleProducts());
    }

    @GetMapping("/new")
    public ResponseEntity<List<ProductResponse>> getNewProducts() {
        return ResponseEntity.ok(productService.getNewProducts());
    }
    // ────────────────────

    @GetMapping
    public ResponseEntity<List<ProductResponse>> getAll() {
        return ResponseEntity.ok(productService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(productService.getById(id));
    }

    @PostMapping
    public ResponseEntity<ProductResponse> create(@Valid @RequestBody ProductRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(productService.create(request));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductResponse> update(@PathVariable UUID id, @Valid @RequestBody ProductRequest request) {
        return ResponseEntity.ok(productService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{productId}/categories/{categoryId}")
    public ResponseEntity<Void> addCategory(@PathVariable UUID productId, @PathVariable UUID categoryId) {
        productService.addCategory(productId, categoryId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{productId}/categories/{categoryId}")
    public ResponseEntity<Void> removeCategory(@PathVariable UUID productId, @PathVariable UUID categoryId) {
        productService.removeCategory(productId, categoryId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{productId}/tags/{tagId}")
    public ResponseEntity<Void> addTag(@PathVariable UUID productId, @PathVariable UUID tagId) {
        productService.addTag(productId, tagId);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{productId}/tags/{tagId}")
    public ResponseEntity<Void> removeTag(@PathVariable UUID productId, @PathVariable UUID tagId) {
        productService.removeTag(productId, tagId);
        return ResponseEntity.noContent().build();
    }
}