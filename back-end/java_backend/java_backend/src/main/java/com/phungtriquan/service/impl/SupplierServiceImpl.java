package com.phungtriquan.service.impl;

import com.phungtriquan.model.Supplier;
import com.phungtriquan.repository.SupplierRepository;
import com.phungtriquan.service.SupplierService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepository supplierRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    @Override
    public Optional<Supplier> findById(UUID id) {
        return supplierRepository.findById(id);
    }

    @Override
    public Supplier save(Supplier supplier) {
        Instant now = Instant.now();
        if (supplier.getId() == null) {
            if (supplier.getCreatedAt() == null) {
                supplier.setCreatedAt(now);
            }
            if (supplier.getCreatedBy() == null) {
                supplier.setCreatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
            if (supplier.getUpdatedBy() == null) {
                supplier.setUpdatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
        }
        supplier.setUpdatedAt(now);
        return supplierRepository.save(supplier);
    }

    @Override
    public boolean existsById(UUID id) {
        return supplierRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        supplierRepository.deleteById(id);
    }
}
