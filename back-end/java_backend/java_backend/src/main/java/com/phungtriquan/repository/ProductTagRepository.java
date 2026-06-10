package com.phungtriquan.repository;

import com.phungtriquan.model.ProductTag;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface ProductTagRepository extends JpaRepository<ProductTag, UUID> {
}
