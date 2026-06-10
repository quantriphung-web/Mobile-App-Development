package com.phungtriquan.repository;

import com.phungtriquan.model.VariantValue;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface VariantValueRepository extends JpaRepository<VariantValue, UUID> {
}
