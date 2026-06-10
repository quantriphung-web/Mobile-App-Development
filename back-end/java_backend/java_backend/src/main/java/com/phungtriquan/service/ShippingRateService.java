package com.phungtriquan.service;

import com.phungtriquan.model.ShippingRate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ShippingRateService {
    List<ShippingRate> findAll();
    Optional<ShippingRate> findById(UUID id);
    ShippingRate save(ShippingRate shippingRate);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
