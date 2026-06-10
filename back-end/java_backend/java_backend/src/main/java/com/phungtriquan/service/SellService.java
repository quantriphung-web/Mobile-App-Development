package com.phungtriquan.service;

import com.phungtriquan.model.Sell;
import java.util.List;
import java.util.Optional;


public interface SellService {
    List<Sell> findAll();
    Optional<Sell> findById(Long id);
    Sell save(Sell sell);
    boolean existsById(Long id);
    void deleteById(Long id);
}
