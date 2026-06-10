package com.phungtriquan.repository;

import com.phungtriquan.model.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, UUID> {
}
