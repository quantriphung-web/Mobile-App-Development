package com.phungtriquan.service;

import com.phungtriquan.model.ShippingZone;
import java.util.List;
import java.util.Optional;


public interface ShippingZoneService {
    List<ShippingZone> findAll();
    Optional<ShippingZone> findById(Long id);
    ShippingZone save(ShippingZone shippingZone);
    boolean existsById(Long id);
    void deleteById(Long id);
}
