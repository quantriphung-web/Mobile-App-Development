package com.phungtriquan.service;

import com.phungtriquan.model.AttributeValue;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AttributeValueService {
    List<AttributeValue> findAll();
    Optional<AttributeValue> findById(UUID id);
    AttributeValue save(AttributeValue attributeValue);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
