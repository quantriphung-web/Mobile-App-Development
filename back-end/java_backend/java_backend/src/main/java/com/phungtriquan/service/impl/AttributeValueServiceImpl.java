package com.phungtriquan.service.impl;

import com.phungtriquan.model.AttributeValue;
import com.phungtriquan.repository.AttributeValueRepository;
import com.phungtriquan.service.AttributeValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AttributeValueServiceImpl implements AttributeValueService {

    private final AttributeValueRepository attributeValueRepository;

    @Override
    public List<AttributeValue> findAll() {
        return attributeValueRepository.findAll();
    }

    @Override
    public Optional<AttributeValue> findById(UUID id) {
        return attributeValueRepository.findById(id);
    }

    @Override
    public AttributeValue save(AttributeValue attributeValue) {
        return attributeValueRepository.save(attributeValue);
    }

    @Override
    public boolean existsById(UUID id) {
        return attributeValueRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        attributeValueRepository.deleteById(id);
    }
}
