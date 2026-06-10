package com.phungtriquan.controller;

import com.phungtriquan.model.ProductCoupon;
import com.phungtriquan.service.ProductCouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/product-coupons")
@RequiredArgsConstructor
public class ProductCouponController {

    private final ProductCouponService productCouponService;

    @GetMapping
    public List<ProductCoupon> getAll() {
        return productCouponService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductCoupon> getById(@PathVariable UUID id) {
        return productCouponService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<ProductCoupon> create(@RequestBody ProductCoupon productCoupon) {
        ProductCoupon saved = productCouponService.save(productCoupon);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ProductCoupon> update(@PathVariable UUID id, @RequestBody ProductCoupon productCoupon) {
        if (!productCouponService.existsById(id)) return ResponseEntity.notFound().build();
        productCoupon.setId(id);
        return ResponseEntity.ok(productCouponService.save(productCoupon));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!productCouponService.existsById(id)) return ResponseEntity.notFound().build();
        productCouponService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
