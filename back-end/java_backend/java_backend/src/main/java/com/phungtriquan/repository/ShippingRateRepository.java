package com.phungtriquan.repository;

import com.phungtriquan.model.ShippingRate;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ShippingRateRepository extends JpaRepository<ShippingRate, UUID> {
}
