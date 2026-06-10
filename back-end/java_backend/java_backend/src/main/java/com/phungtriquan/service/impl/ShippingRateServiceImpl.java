package com.phungtriquan.service.impl;

import com.phungtriquan.model.ShippingRate;
import com.phungtriquan.repository.ShippingRateRepository;
import com.phungtriquan.service.ShippingRateService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShippingRateServiceImpl implements ShippingRateService {

    private final ShippingRateRepository shippingRateRepository;

    @Override
    public List<ShippingRate> findAll() {
        return shippingRateRepository.findAll();
    }

    @Override
    public Optional<ShippingRate> findById(UUID id) {
        return shippingRateRepository.findById(id);
    }

    @Override
    public ShippingRate save(ShippingRate shippingRate) {
        Instant now = Instant.now();
        if (shippingRate.getCreatedAt() == null) {
            shippingRate.setCreatedAt(now);
        }
        shippingRate.setUpdatedAt(now);
        return shippingRateRepository.save(shippingRate);
    }

    @Override
    public boolean existsById(UUID id) {
        return shippingRateRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        shippingRateRepository.deleteById(id);
    }
}
