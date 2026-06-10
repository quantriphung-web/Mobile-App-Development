package com.phungtriquan.controller;

import com.phungtriquan.model.Attribute;
import com.phungtriquan.service.AttributeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/attributes")
@RequiredArgsConstructor
public class AttributeController {

    private final AttributeService attributeService;

    @GetMapping
    public List<Attribute> getAll() {
        return attributeService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Attribute> getById(@PathVariable UUID id) {
        return attributeService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Attribute> create(@RequestBody Attribute attribute) {
        Attribute saved = attributeService.save(attribute);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Attribute> update(@PathVariable UUID id, @RequestBody Attribute attribute) {
        if (!attributeService.existsById(id)) return ResponseEntity.notFound().build();
        attribute.setId(id);
        return ResponseEntity.ok(attributeService.save(attribute));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!attributeService.existsById(id)) return ResponseEntity.notFound().build();
        attributeService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
