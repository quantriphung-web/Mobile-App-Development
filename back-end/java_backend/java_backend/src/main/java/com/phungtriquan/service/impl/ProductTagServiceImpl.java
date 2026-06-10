package com.phungtriquan.service.impl;

import com.phungtriquan.model.ProductTag;
import com.phungtriquan.repository.ProductTagRepository;
import com.phungtriquan.service.ProductTagService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductTagServiceImpl implements ProductTagService {

    private final ProductTagRepository productTagRepository;

    @Override
    public List<ProductTag> findAll() {
        return productTagRepository.findAll();
    }

    @Override
    public Optional<ProductTag> findById(UUID id) {
        return productTagRepository.findById(id);
    }

    @Override
    public ProductTag save(ProductTag productTag) {
        return productTagRepository.save(productTag);
    }

    @Override
    public boolean existsById(UUID id) {
        return productTagRepository.existsById(id);
    }

    @Override
    public void deleteById(UUID id) {
        productTagRepository.deleteById(id);
    }
}
