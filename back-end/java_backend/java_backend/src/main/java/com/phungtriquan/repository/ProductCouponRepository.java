package com.phungtriquan.repository;

import com.phungtriquan.model.ProductCoupon;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductCouponRepository extends JpaRepository<ProductCoupon, UUID> {
}
