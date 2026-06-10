package com.phungtriquan.service.impl;

import com.phungtriquan.model.Sell;
import com.phungtriquan.repository.SellRepository;
import com.phungtriquan.service.SellService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;


@Service
@RequiredArgsConstructor
public class SellServiceImpl implements SellService {

    private final SellRepository sellRepository;

    @Override
    public List<Sell> findAll() {
        return sellRepository.findAll();
    }

    @Override
    public Optional<Sell> findById(Long id) {
        return sellRepository.findById(id);
    }

    @Override
    public Sell save(Sell sell) {
        return sellRepository.save(sell);
    }

    @Override
    public boolean existsById(Long id) {
        return sellRepository.existsById(id);
    }

    @Override
    public void deleteById(Long id) {
        sellRepository.deleteById(id);
    }
}
