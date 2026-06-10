package com.phungtriquan.repository;

import com.phungtriquan.model.ProductShippingInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductShippingInfoRepository extends JpaRepository<ProductShippingInfo, UUID> {
}
