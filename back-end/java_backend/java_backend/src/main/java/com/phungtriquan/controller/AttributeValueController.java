package com.phungtriquan.controller;

import com.phungtriquan.model.AttributeValue;
import com.phungtriquan.service.AttributeValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/attribute-values")
@RequiredArgsConstructor
public class AttributeValueController {

    private final AttributeValueService attributeValueService;

    @GetMapping
    public List<AttributeValue> getAll() {
        return attributeValueService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttributeValue> getById(@PathVariable UUID id) {
        return attributeValueService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<AttributeValue> create(@RequestBody AttributeValue attributeValue) {
        AttributeValue saved = attributeValueService.save(attributeValue);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AttributeValue> update(@PathVariable UUID id, @RequestBody AttributeValue attributeValue) {
        if (!attributeValueService.existsById(id)) return ResponseEntity.notFound().build();
        attributeValue.setId(id);
        return ResponseEntity.ok(attributeValueService.save(attributeValue));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!attributeValueService.existsById(id)) return ResponseEntity.notFound().build();
        attributeValueService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
