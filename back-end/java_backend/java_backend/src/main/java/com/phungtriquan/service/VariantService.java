package com.phungtriquan.service;

import com.phungtriquan.model.Variant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VariantService {
    List<Variant> findAll();
    Optional<Variant> findById(UUID id);
    Variant save(Variant variant);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
