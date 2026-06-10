package com.phungtriquan.service.impl;

import com.phungtriquan.model.VariantValue;
import com.phungtriquan.repository.VariantValueRepository;
import com.phungtriquan.service.VariantValueService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VariantValueServiceImpl implements VariantValueService {

    private final VariantValueRepository variantValueRepository;

    @Override
    public List<VariantValue> findAll() {
        return variantValueRepository.findAll();
    }

    @Override
    public Optional<VariantValue> findById(UUID id) {
        return variantValueRepository.findById(id);
    }

    @Override
    public VariantValue save(VariantValue variantValue) {
        return variantValueRepository.save(variantValue);
    }

    @Override
    public boolean existsById(UUID id) {
        return variantValueRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        variantValueRepository.deleteById(id);
    }
}
