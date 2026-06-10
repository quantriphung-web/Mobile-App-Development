package com.phungtriquan.service;

import com.phungtriquan.model.ProductCategory;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductCategoryService {
    List<ProductCategory> findAll();
    Optional<ProductCategory> findById(UUID id);
    ProductCategory save(ProductCategory productCategory);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
