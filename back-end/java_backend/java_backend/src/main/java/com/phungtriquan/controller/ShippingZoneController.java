package com.phungtriquan.controller;

import com.phungtriquan.model.ShippingZone;
import com.phungtriquan.service.ShippingZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/shipping-zones")
@RequiredArgsConstructor
public class ShippingZoneController {

    private final ShippingZoneService shippingZoneService;

    @GetMapping
    public List<ShippingZone> getAll() {
        return shippingZoneService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShippingZone> getById(@PathVariable Long id) {
        return shippingZoneService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ShippingZone> create(@RequestBody ShippingZone shippingZone) {
        ShippingZone saved = shippingZoneService.save(shippingZone);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShippingZone> update(@PathVariable Long id, @RequestBody ShippingZone shippingZone) {
        if (!shippingZoneService.existsById(id)) return ResponseEntity.notFound().build();
        shippingZone.setId(id);
        return ResponseEntity.ok(shippingZoneService.save(shippingZone));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!shippingZoneService.existsById(id)) return ResponseEntity.notFound().build();
        shippingZoneService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
