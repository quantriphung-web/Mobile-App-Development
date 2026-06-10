package com.phungtriquan.service.impl;

import com.phungtriquan.model.Coupon;
import com.phungtriquan.repository.CouponRepository;
import com.phungtriquan.service.CouponService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CouponServiceImpl implements CouponService {

    private final CouponRepository couponRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<Coupon> findAll() {
        return couponRepository.findAll();
    }

    @Override
    public Optional<Coupon> findById(UUID id) {
        return couponRepository.findById(id);
    }

 @Override
public Coupon save(Coupon coupon) {
    Instant now = Instant.now();
    if (coupon.getId() == null) {
        coupon.setId(UUID.randomUUID());
        if (coupon.getCreatedAt() == null) {
            coupon.setCreatedAt(now);
        }
        if (coupon.getCreatedBy() == null) {
            coupon.setCreatedBy(auditDefaultsService.getDefaultStaffAccountId());
        }
        if (coupon.getUpdatedBy() == null) {
            coupon.setUpdatedBy(auditDefaultsService.getDefaultStaffAccountId());
        }
    }
    coupon.setUpdatedAt(now);
    return couponRepository.save(coupon);
}

    @Override
    public boolean existsById(UUID id) {
        return couponRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        couponRepository.deleteById(id);
    }
}
