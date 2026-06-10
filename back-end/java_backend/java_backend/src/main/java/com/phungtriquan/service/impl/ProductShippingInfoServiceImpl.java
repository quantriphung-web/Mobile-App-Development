package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductShippingInfo;
import com.phungtriquan.repository.ProductShippingInfoRepository;
import com.phungtriquan.service.ProductShippingInfoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductShippingInfoServiceImpl implements ProductShippingInfoService {

    private final ProductShippingInfoRepository productShippingInfoRepository;

    @Override
    public List<ProductShippingInfo> findAll() {
        return productShippingInfoRepository.findAll();
    }

    @Override
    public Optional<ProductShippingInfo> findById(UUID id) {
        return productShippingInfoRepository.findById(id);
    }

    @Override
    public ProductShippingInfo save(ProductShippingInfo productShippingInfo) {
        return productShippingInfoRepository.save(productShippingInfo);
    }

    @Override
    public boolean existsById(UUID id) {
        return productShippingInfoRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productShippingInfoRepository.deleteById(id);
    }
}
