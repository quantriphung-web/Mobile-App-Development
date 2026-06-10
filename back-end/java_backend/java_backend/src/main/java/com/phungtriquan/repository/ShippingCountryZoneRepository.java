package com.phungtriquan.repository;

import com.phungtriquan.model.ShippingCountryZone;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ShippingCountryZoneRepository extends JpaRepository<ShippingCountryZone, UUID> {
}
