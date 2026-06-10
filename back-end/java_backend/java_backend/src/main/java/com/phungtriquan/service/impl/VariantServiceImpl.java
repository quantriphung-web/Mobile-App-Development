package com.phungtriquan.service.impl;

import com.phungtriquan.model.Variant;
import com.phungtriquan.repository.VariantRepository;
import com.phungtriquan.service.VariantService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VariantServiceImpl implements VariantService {

    private final VariantRepository variantRepository;

    @Override
    public List<Variant> findAll() {
        return variantRepository.findAll();
    }

    @Override
    public Optional<Variant> findById(UUID id) {
        return variantRepository.findById(id);
    }

    @Override
    public Variant save(Variant variant) {
        return variantRepository.save(variant);
    }

    @Override
    public boolean existsById(UUID id) {
        return variantRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        variantRepository.deleteById(id);
    }
}
