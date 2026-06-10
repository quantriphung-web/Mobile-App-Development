package com.phungtriquan.controller;

import com.phungtriquan.model.Variant;
import com.phungtriquan.service.VariantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/variants")
@RequiredArgsConstructor
public class VariantController {

    private final VariantService variantService;

    @GetMapping
    public List<Variant> getAll() {
        return variantService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Variant> getById(@PathVariable UUID id) {
        return variantService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Variant> create(@RequestBody Variant variant) {
        Variant saved = variantService.save(variant);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Variant> update(@PathVariable UUID id, @RequestBody Variant variant) {
        if (!variantService.existsById(id)) return ResponseEntity.notFound().build();
        variant.setId(id);
        return ResponseEntity.ok(variantService.save(variant));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!variantService.existsById(id)) return ResponseEntity.notFound().build();
        variantService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
