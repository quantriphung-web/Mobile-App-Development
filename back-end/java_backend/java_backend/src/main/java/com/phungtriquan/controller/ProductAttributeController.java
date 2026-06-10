package com.phungtriquan.controller;

import com.phungtriquan.model.ProductAttribute;
import com.phungtriquan.service.ProductAttributeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-attributes")
@RequiredArgsConstructor
public class ProductAttributeController {

    private final ProductAttributeService productAttributeService;

    @GetMapping
    public List<ProductAttribute> getAll() {
        return productAttributeService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductAttribute> getById(@PathVariable UUID id) {
        return productAttributeService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductAttribute> create(@RequestBody ProductAttribute productAttribute) {
        ProductAttribute saved = productAttributeService.save(productAttribute);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductAttribute> update(@PathVariable UUID id, @RequestBody ProductAttribute productAttribute) {
        if (!productAttributeService.existsById(id)) return ResponseEntity.notFound().build();
        productAttribute.setId(id);
        return ResponseEntity.ok(productAttributeService.save(productAttribute));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productAttributeService.existsById(id)) return ResponseEntity.notFound().build();
        productAttributeService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
