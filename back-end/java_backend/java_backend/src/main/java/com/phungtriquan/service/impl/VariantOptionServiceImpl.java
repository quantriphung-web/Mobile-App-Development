package com.phungtriquan.service.impl;

import com.phungtriquan.model.VariantOption;
import com.phungtriquan.repository.VariantOptionRepository;
import com.phungtriquan.service.VariantOptionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VariantOptionServiceImpl implements VariantOptionService {

    private final VariantOptionRepository variantOptionRepository;

    @Override
    public List<VariantOption> findAll() {
        return variantOptionRepository.findAll();
    }

    @Override
    public Optional<VariantOption> findById(UUID id) {
        return variantOptionRepository.findById(id);
    }

    @Override
    public VariantOption save(VariantOption variantOption) {
        return variantOptionRepository.save(variantOption);
    }

    @Override
    public boolean existsById(UUID id) {
        return variantOptionRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        variantOptionRepository.deleteById(id);
    }
}
