package com.phungtriquan.service;

import com.phungtriquan.model.ProductAttributeValue;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductAttributeValueService {
    List<ProductAttributeValue> findAll();
    Optional<ProductAttributeValue> findById(UUID id);
    ProductAttributeValue save(ProductAttributeValue productAttributeValue);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
