package com.phungtriquan.controller;

import com.phungtriquan.model.VariantValue;
import com.phungtriquan.service.VariantValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/variant-values")
@RequiredArgsConstructor
public class VariantValueController {

    private final VariantValueService variantValueService;

    @GetMapping
    public List<VariantValue> getAll() {
        return variantValueService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<VariantValue> getById(@PathVariable UUID id) {
        return variantValueService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<VariantValue> create(@RequestBody VariantValue variantValue) {
        VariantValue saved = variantValueService.save(variantValue);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<VariantValue> update(@PathVariable UUID id, @RequestBody VariantValue variantValue) {
        if (!variantValueService.existsById(id)) return ResponseEntity.notFound().build();
        variantValue.setId(id);
        return ResponseEntity.ok(variantValueService.save(variantValue));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!variantValueService.existsById(id)) return ResponseEntity.notFound().build();
        variantValueService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
