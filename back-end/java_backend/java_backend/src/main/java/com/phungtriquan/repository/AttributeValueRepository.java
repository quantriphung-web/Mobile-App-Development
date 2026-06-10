package com.phungtriquan.repository;

import com.phungtriquan.model.AttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface AttributeValueRepository extends JpaRepository<AttributeValue, UUID> {
}
