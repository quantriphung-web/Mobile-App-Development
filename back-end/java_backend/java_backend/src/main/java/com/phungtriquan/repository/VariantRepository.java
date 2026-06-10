package com.phungtriquan.repository;

import com.phungtriquan.model.Variant;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface VariantRepository extends JpaRepository<Variant, UUID> {
}
