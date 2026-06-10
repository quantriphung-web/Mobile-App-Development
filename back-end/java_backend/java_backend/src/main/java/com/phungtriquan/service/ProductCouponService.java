package com.phungtriquan.service;

import com.phungtriquan.model.ProductCoupon;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductCouponService {
    List<ProductCoupon> findAll();
    Optional<ProductCoupon> findById(UUID id);
    ProductCoupon save(ProductCoupon productCoupon);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
