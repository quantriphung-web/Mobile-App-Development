package com.phungtriquan.repository;

import com.phungtriquan.model.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface SupplierRepository extends JpaRepository<Supplier, UUID> {
}
