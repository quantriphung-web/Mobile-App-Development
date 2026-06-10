package com.phungtriquan.controller;

import com.phungtriquan.model.Coupon;
import com.phungtriquan.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
public class CouponController {

    private final CouponService couponService;

    @GetMapping
    public List<Coupon> getAll() {
        return couponService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Coupon> getById(@PathVariable UUID id) {
        return couponService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Coupon> create(@RequestBody Coupon coupon) {
        Coupon saved = couponService.save(coupon);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Coupon> update(@PathVariable UUID id, @RequestBody Coupon coupon) {
        if (!couponService.existsById(id)) return ResponseEntity.notFound().build();
        coupon.setId(id);
        return ResponseEntity.ok(couponService.save(coupon));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        if (!couponService.existsById(id)) return ResponseEntity.notFound().build();
        couponService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
