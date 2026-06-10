package com.phungtriquan.controller;

import com.phungtriquan.model.ShippingCountryZone;
import com.phungtriquan.service.ShippingCountryZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/shipping-country-zones")
@RequiredArgsConstructor
public class ShippingCountryZoneController {

    private final ShippingCountryZoneService shippingCountryZoneService;

    @GetMapping
    public List<ShippingCountryZone> getAll() {
        return shippingCountryZoneService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShippingCountryZone> getById(@PathVariable UUID id) {
        return shippingCountryZoneService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ShippingCountryZone> create(@RequestBody ShippingCountryZone shippingCountryZone) {
        ShippingCountryZone saved = shippingCountryZoneService.save(shippingCountryZone);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShippingCountryZone> update(@PathVariable UUID id, @RequestBody ShippingCountryZone shippingCountryZone) {
        if (!shippingCountryZoneService.existsById(id)) return ResponseEntity.notFound().build();
        shippingCountryZone.setId(id);
        return ResponseEntity.ok(shippingCountryZoneService.save(shippingCountryZone));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!shippingCountryZoneService.existsById(id)) return ResponseEntity.notFound().build();
        shippingCountryZoneService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
