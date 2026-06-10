package com.phungtriquan.repository;

import com.phungtriquan.model.Attribute;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface AttributeRepository extends JpaRepository<Attribute, UUID> {
}
