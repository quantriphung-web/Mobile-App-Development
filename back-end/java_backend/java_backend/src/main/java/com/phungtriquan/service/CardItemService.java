package com.phungtriquan.service;

import com.phungtriquan.model.CardItem;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CardItemService {
    List<CardItem> findAll();
    Optional<CardItem> findById(UUID id);
    CardItem save(CardItem cardItem);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
