package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductCoupon;
import com.phungtriquan.repository.ProductCouponRepository;
import com.phungtriquan.service.ProductCouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductCouponServiceImpl implements ProductCouponService {

    private final ProductCouponRepository productCouponRepository;

    @Override
    public List<ProductCoupon> findAll() {
        return productCouponRepository.findAll();
    }

    @Override
    public Optional<ProductCoupon> findById(UUID id) {
        return productCouponRepository.findById(id);
    }

    @Override
    public ProductCoupon save(ProductCoupon productCoupon) {
        return productCouponRepository.save(productCoupon);
    }

    @Override
    public boolean existsById(UUID id) {
        return productCouponRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productCouponRepository.deleteById(id);
    }
}
