package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductAttributeValue;
import com.phungtriquan.repository.ProductAttributeValueRepository;
import com.phungtriquan.service.ProductAttributeValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductAttributeValueServiceImpl implements ProductAttributeValueService {

    private final ProductAttributeValueRepository productAttributeValueRepository;

    @Override
    public List<ProductAttributeValue> findAll() {
        return productAttributeValueRepository.findAll();
    }

    @Override
    public Optional<ProductAttributeValue> findById(UUID id) {
        return productAttributeValueRepository.findById(id);
    }

    @Override
    public ProductAttributeValue save(ProductAttributeValue productAttributeValue) {
        return productAttributeValueRepository.save(productAttributeValue);
    }

    @Override
    public boolean existsById(UUID id) {
        return productAttributeValueRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productAttributeValueRepository.deleteById(id);
    }
}
