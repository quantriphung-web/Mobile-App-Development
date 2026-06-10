package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductAttribute;
import com.phungtriquan.repository.ProductAttributeRepository;
import com.phungtriquan.service.ProductAttributeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductAttributeServiceImpl implements ProductAttributeService {

    private final ProductAttributeRepository productAttributeRepository;

    @Override
    public List<ProductAttribute> findAll() {
        return productAttributeRepository.findAll();
    }

    @Override
    public Optional<ProductAttribute> findById(UUID id) {
        return productAttributeRepository.findById(id);
    }

    @Override
    public ProductAttribute save(ProductAttribute productAttribute) {
        return productAttributeRepository.save(productAttribute);
    }

    @Override
    public boolean existsById(UUID id) {
        return productAttributeRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productAttributeRepository.deleteById(id);
    }
}
