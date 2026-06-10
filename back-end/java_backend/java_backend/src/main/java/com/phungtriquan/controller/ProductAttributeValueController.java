package com.phungtriquan.controller;

import com.phungtriquan.model.ProductAttributeValue;
import com.phungtriquan.service.ProductAttributeValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-attribute-values")
@RequiredArgsConstructor
public class ProductAttributeValueController {

    private final ProductAttributeValueService productAttributeValueService;

    @GetMapping
    public List<ProductAttributeValue> getAll() {
        return productAttributeValueService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductAttributeValue> getById(@PathVariable UUID id) {
        return productAttributeValueService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductAttributeValue> create(@RequestBody ProductAttributeValue productAttributeValue) {
        ProductAttributeValue saved = productAttributeValueService.save(productAttributeValue);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductAttributeValue> update(@PathVariable UUID id, @RequestBody ProductAttributeValue productAttributeValue) {
        if (!productAttributeValueService.existsById(id)) return ResponseEntity.notFound().build();
        productAttributeValue.setId(id);
        return ResponseEntity.ok(productAttributeValueService.save(productAttributeValue));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productAttributeValueService.existsById(id)) return ResponseEntity.notFound().build();
        productAttributeValueService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
