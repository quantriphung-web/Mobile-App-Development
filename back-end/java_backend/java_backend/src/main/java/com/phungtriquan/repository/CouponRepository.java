package com.phungtriquan.repository;

import com.phungtriquan.model.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface CouponRepository extends JpaRepository<Coupon, UUID> {
}
