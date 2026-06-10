package com.phungtriquan.service;

import com.phungtriquan.model.ProductTag;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductTagService {
    List<ProductTag> findAll();
    Optional<ProductTag> findById(UUID id);
    ProductTag save(ProductTag productTag);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
