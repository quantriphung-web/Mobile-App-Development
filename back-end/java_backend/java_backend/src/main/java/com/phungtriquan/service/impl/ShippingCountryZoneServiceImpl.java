package com.phungtriquan.service.impl;

import com.phungtriquan.model.ShippingCountryZone;
import com.phungtriquan.repository.ShippingCountryZoneRepository;
import com.phungtriquan.service.ShippingCountryZoneService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShippingCountryZoneServiceImpl implements ShippingCountryZoneService {

    private final ShippingCountryZoneRepository shippingCountryZoneRepository;

    @Override
    public List<ShippingCountryZone> findAll() {
        return shippingCountryZoneRepository.findAll();
    }

    @Override
    public Optional<ShippingCountryZone> findById(UUID id) {
        return shippingCountryZoneRepository.findById(id);
    }

    @Override
    public ShippingCountryZone save(ShippingCountryZone shippingCountryZone) {
        return shippingCountryZoneRepository.save(shippingCountryZone);
    }

    @Override
    public boolean existsById(UUID id) {
        return shippingCountryZoneRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        shippingCountryZoneRepository.deleteById(id);
    }
}
