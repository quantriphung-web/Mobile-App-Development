package com.phungtriquan.controller;

import com.phungtriquan.model.ProductCategory;
import com.phungtriquan.service.ProductCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-categories")
@RequiredArgsConstructor
public class ProductCategoryController {

    private final ProductCategoryService productCategoryService;

    @GetMapping
    public List<ProductCategory> getAll() {
        return productCategoryService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductCategory> getById(@PathVariable UUID id) {
        return productCategoryService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductCategory> create(@RequestBody ProductCategory productCategory) {
        ProductCategory saved = productCategoryService.save(productCategory);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductCategory> update(@PathVariable UUID id, @RequestBody ProductCategory productCategory) {
        if (!productCategoryService.existsById(id)) return ResponseEntity.notFound().build();
        productCategory.setId(id);
        return ResponseEntity.ok(productCategoryService.save(productCategory));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productCategoryService.existsById(id)) return ResponseEntity.notFound().build();
        productCategoryService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
