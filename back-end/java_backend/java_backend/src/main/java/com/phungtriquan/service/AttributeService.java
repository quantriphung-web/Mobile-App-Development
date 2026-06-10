package com.phungtriquan.service;

import com.phungtriquan.model.Attribute;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AttributeService {
    List<Attribute> findAll();
    Optional<Attribute> findById(UUID id);
    Attribute save(Attribute attribute);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
