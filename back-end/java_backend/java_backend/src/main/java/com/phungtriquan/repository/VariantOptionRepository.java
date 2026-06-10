package com.phungtriquan.repository;

import com.phungtriquan.model.VariantOption;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface VariantOptionRepository extends JpaRepository<VariantOption, UUID> {
}
