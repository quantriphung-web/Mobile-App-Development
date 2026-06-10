package com.phungtriquan.service;

import com.phungtriquan.model.ProductSupplier;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductSupplierService {
    List<ProductSupplier> findAll();
    Optional<ProductSupplier> findById(UUID id);
    ProductSupplier save(ProductSupplier productSupplier);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
