package com.phungtriquan.service;

import com.phungtriquan.model.VariantOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VariantOptionService {
    List<VariantOption> findAll();
    Optional<VariantOption> findById(UUID id);
    VariantOption save(VariantOption variantOption);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
