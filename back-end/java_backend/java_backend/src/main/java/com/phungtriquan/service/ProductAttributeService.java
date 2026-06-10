package com.phungtriquan.service;

import com.phungtriquan.model.ProductAttribute;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductAttributeService {
    List<ProductAttribute> findAll();
    Optional<ProductAttribute> findById(UUID id);
    ProductAttribute save(ProductAttribute productAttribute);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
