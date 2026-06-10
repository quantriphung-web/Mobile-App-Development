package com.phungtriquan.service;

import com.phungtriquan.model.ShippingCountryZone;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ShippingCountryZoneService {
    List<ShippingCountryZone> findAll();
    Optional<ShippingCountryZone> findById(UUID id);
    ShippingCountryZone save(ShippingCountryZone shippingCountryZone);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
