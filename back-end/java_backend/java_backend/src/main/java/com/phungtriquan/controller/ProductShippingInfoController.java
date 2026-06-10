package com.phungtriquan.controller;

import com.phungtriquan.model.ProductShippingInfo;
import com.phungtriquan.service.ProductShippingInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-shipping-infos")
@RequiredArgsConstructor
public class ProductShippingInfoController {

    private final ProductShippingInfoService productShippingInfoService;

    @GetMapping
    public List<ProductShippingInfo> getAll() {
        return productShippingInfoService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductShippingInfo> getById(@PathVariable UUID id) {
        return productShippingInfoService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductShippingInfo> create(@RequestBody ProductShippingInfo productShippingInfo) {
        ProductShippingInfo saved = productShippingInfoService.save(productShippingInfo);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductShippingInfo> update(@PathVariable UUID id, @RequestBody ProductShippingInfo productShippingInfo) {
        if (!productShippingInfoService.existsById(id)) return ResponseEntity.notFound().build();
        productShippingInfo.setId(id);
        return ResponseEntity.ok(productShippingInfoService.save(productShippingInfo));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productShippingInfoService.existsById(id)) return ResponseEntity.notFound().build();
        productShippingInfoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
