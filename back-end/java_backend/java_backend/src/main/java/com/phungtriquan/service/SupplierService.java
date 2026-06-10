package com.phungtriquan.service;

import com.phungtriquan.model.Supplier;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SupplierService {
    List<Supplier> findAll();
    Optional<Supplier> findById(UUID id);
    Supplier save(Supplier supplier);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
