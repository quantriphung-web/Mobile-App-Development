package com.phungtriquan.service.impl;

import com.phungtriquan.model.Attribute;
import com.phungtriquan.repository.AttributeRepository;
import com.phungtriquan.service.AttributeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AttributeServiceImpl implements AttributeService {

    private final AttributeRepository attributeRepository;
    private final AuditDefaultsService auditDefaultsService;

    @Override
    public List<Attribute> findAll() {
        return attributeRepository.findAll();
    }

    @Override
    public Optional<Attribute> findById(UUID id) {
        return attributeRepository.findById(id);
    }

    @Override
    public Attribute save(Attribute attribute) {
        Instant now = Instant.now();
        if (attribute.getId() == null) {
            attribute.setId(UUID.randomUUID());
            if (attribute.getCreatedAt() == null) {
                attribute.setCreatedAt(now);
            }
            if (attribute.getCreatedBy() == null) {
                attribute.setCreatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
            if (attribute.getUpdatedBy() == null) {
                attribute.setUpdatedBy(auditDefaultsService.getDefaultStaffAccountId());
            }
        }
        attribute.setUpdatedAt(now);
        return attributeRepository.save(attribute);
    }

    @Override
    public boolean existsById(UUID id) {
        return attributeRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        attributeRepository.deleteById(id);
    }
}
