package com.phungtriquan.repository;

import com.phungtriquan.model.ProductAttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductAttributeValueRepository extends JpaRepository<ProductAttributeValue, UUID> {
}
