package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductSupplier;
import com.phungtriquan.repository.ProductSupplierRepository;
import com.phungtriquan.service.ProductSupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductSupplierServiceImpl implements ProductSupplierService {

    private final ProductSupplierRepository productSupplierRepository;

    @Override
    public List<ProductSupplier> findAll() {
        return productSupplierRepository.findAll();
    }

    @Override
    public Optional<ProductSupplier> findById(UUID id) {
        return productSupplierRepository.findById(id);
    }

    @Override
    public ProductSupplier save(ProductSupplier productSupplier) {
        return productSupplierRepository.save(productSupplier);
    }

    @Override
    public boolean existsById(UUID id) {
        return productSupplierRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productSupplierRepository.deleteById(id);
    }
}
