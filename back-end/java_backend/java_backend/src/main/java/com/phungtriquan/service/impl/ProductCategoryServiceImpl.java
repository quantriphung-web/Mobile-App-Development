package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductCategory;
import com.phungtriquan.repository.ProductCategoryRepository;
import com.phungtriquan.service.ProductCategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductCategoryServiceImpl implements ProductCategoryService {

    private final ProductCategoryRepository productCategoryRepository;

    @Override
    public List<ProductCategory> findAll() {
        return productCategoryRepository.findAll();
    }

    @Override
    public Optional<ProductCategory> findById(UUID id) {
        return productCategoryRepository.findById(id);
    }

    @Override
    public ProductCategory save(ProductCategory productCategory) {
        return productCategoryRepository.save(productCategory);
    }

    @Override
    public boolean existsById(UUID id) {
        return productCategoryRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productCategoryRepository.deleteById(id);
    }
}
