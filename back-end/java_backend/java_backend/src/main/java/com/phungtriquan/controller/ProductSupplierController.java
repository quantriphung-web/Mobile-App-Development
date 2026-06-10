package com.phungtriquan.controller;

import com.phungtriquan.model.ProductSupplier;
import com.phungtriquan.service.ProductSupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-suppliers")
@RequiredArgsConstructor
public class ProductSupplierController {

    private final ProductSupplierService productSupplierService;

    @GetMapping
    public List<ProductSupplier> getAll() {
        return productSupplierService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductSupplier> getById(@PathVariable UUID id) {
        return productSupplierService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductSupplier> create(@RequestBody ProductSupplier productSupplier) {
        ProductSupplier saved = productSupplierService.save(productSupplier);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductSupplier> update(@PathVariable UUID id, @RequestBody ProductSupplier productSupplier) {
        if (!productSupplierService.existsById(id)) return ResponseEntity.notFound().build();
        productSupplier.setId(id);
        return ResponseEntity.ok(productSupplierService.save(productSupplier));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productSupplierService.existsById(id)) return ResponseEntity.notFound().build();
        productSupplierService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
