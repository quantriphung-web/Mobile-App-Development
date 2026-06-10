package com.phungtriquan.service;

import com.phungtriquan.model.Coupon;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CouponService {
    List<Coupon> findAll();
    Optional<Coupon> findById(UUID id);
    Coupon save(Coupon coupon);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
