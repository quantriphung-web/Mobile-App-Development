package com.phungtriquan.controller;

import com.phungtriquan.model.ProductTag;
import com.phungtriquan.service.ProductTagService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-tags")
@RequiredArgsConstructor
public class ProductTagController {

    private final ProductTagService productTagService;

    @GetMapping
    public List<ProductTag> getAll() {
        return productTagService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductTag> getById(@PathVariable UUID id) {
        return productTagService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductTag> create(@RequestBody ProductTag productTag) {
        ProductTag saved = productTagService.save(productTag);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductTag> update(@PathVariable UUID id, @RequestBody ProductTag productTag) {
        if (!productTagService.existsById(id)) return ResponseEntity.notFound().build();
        productTag.setId(id);
        return ResponseEntity.ok(productTagService.save(productTag));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productTagService.existsById(id)) return ResponseEntity.notFound().build();
        productTagService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
