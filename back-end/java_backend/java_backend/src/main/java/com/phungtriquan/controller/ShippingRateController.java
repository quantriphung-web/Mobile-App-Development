package com.phungtriquan.controller;

import com.phungtriquan.model.ShippingRate;
import com.phungtriquan.service.ShippingRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/shipping-rates")
@RequiredArgsConstructor
public class ShippingRateController {

    private final ShippingRateService shippingRateService;

    @GetMapping
    public List<ShippingRate> getAll() {
        return shippingRateService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShippingRate> getById(@PathVariable UUID id) {
        return shippingRateService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ShippingRate> create(@RequestBody ShippingRate shippingRate) {
        ShippingRate saved = shippingRateService.save(shippingRate);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShippingRate> update(@PathVariable UUID id, @RequestBody ShippingRate shippingRate) {
        if (!shippingRateService.existsById(id)) return ResponseEntity.notFound().build();
        shippingRate.setId(id);
        return ResponseEntity.ok(shippingRateService.save(shippingRate));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!shippingRateService.existsById(id)) return ResponseEntity.notFound().build();
        shippingRateService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
