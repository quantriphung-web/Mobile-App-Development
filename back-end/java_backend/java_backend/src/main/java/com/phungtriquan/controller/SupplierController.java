package com.phungtriquan.controller;

import com.phungtriquan.model.Supplier;
import com.phungtriquan.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @GetMapping
    public List<Supplier> getAll() {
        return supplierService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Supplier> getById(@PathVariable UUID id) {
        return supplierService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Supplier> create(@RequestBody Supplier supplier) {
        Supplier saved = supplierService.save(supplier);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Supplier> update(@PathVariable UUID id, @RequestBody Supplier supplier) {
        if (!supplierService.existsById(id)) return ResponseEntity.notFound().build();
        supplier.setId(id);
        return ResponseEntity.ok(supplierService.save(supplier));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!supplierService.existsById(id)) return ResponseEntity.notFound().build();
        supplierService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
