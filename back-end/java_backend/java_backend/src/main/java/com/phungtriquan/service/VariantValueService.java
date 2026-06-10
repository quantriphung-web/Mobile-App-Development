package com.phungtriquan.service;

import com.phungtriquan.model.VariantValue;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VariantValueService {
    List<VariantValue> findAll();
    Optional<VariantValue> findById(UUID id);
    VariantValue save(VariantValue variantValue);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
