package com.phungtriquan.controller;

import com.phungtriquan.model.VariantOption;
import com.phungtriquan.service.VariantOptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/variant-options")
@RequiredArgsConstructor
public class VariantOptionController {

    private final VariantOptionService variantOptionService;

    @GetMapping
    public List<VariantOption> getAll() {
        return variantOptionService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<VariantOption> getById(@PathVariable UUID id) {
        return variantOptionService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<VariantOption> create(@RequestBody VariantOption variantOption) {
        VariantOption saved = variantOptionService.save(variantOption);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<VariantOption> update(@PathVariable UUID id, @RequestBody VariantOption variantOption) {
        if (!variantOptionService.existsById(id)) return ResponseEntity.notFound().build();
        variantOption.setId(id);
        return ResponseEntity.ok(variantOptionService.save(variantOption));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!variantOptionService.existsById(id)) return ResponseEntity.notFound().build();
        variantOptionService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
