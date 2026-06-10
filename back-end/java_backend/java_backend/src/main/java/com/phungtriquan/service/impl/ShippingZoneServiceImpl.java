package com.phungtriquan.service.impl;

import com.phungtriquan.model.ShippingZone;
import com.phungtriquan.repository.ShippingZoneRepository;
import com.phungtriquan.service.ShippingZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


@Service
@RequiredArgsConstructor
public class ShippingZoneServiceImpl implements ShippingZoneService {

    private final ShippingZoneRepository shippingZoneRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<ShippingZone> findAll() {
        return shippingZoneRepository.findAll();
    }

    @Override
    public Optional<ShippingZone> findById(Long id) {
        return shippingZoneRepository.findById(id);
    }

    @Override
    public ShippingZone save(ShippingZone shippingZone) {
        Instant now = Instant.now();
        if (shippingZone.getId() == null) {
            UUID defaultStaffAccountId = auditDefaultsService.getDefaultStaffAccountId();
            if (shippingZone.getCreatedAt() == null) {
                shippingZone.setCreatedAt(now);
            }
            if (shippingZone.getCreatedBy() == null) {
                shippingZone.setCreatedBy(defaultStaffAccountId);
            }
            if (shippingZone.getUpdatedBy() == null) {
                shippingZone.setUpdatedBy(defaultStaffAccountId);
            }
        }
        shippingZone.setUpdatedAt(now);
        return shippingZoneRepository.save(shippingZone);
    }

    @Override
    public boolean existsById(Long id) {
        return shippingZoneRepository.existsById(id);
    }

    @Override
    public void deleteById(Long id) {
        shippingZoneRepository.deleteById(id);
    }
}
