package com.phungtriquan.service;

import com.phungtriquan.model.Card;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CardService {
    List<Card> findAll();
    Optional<Card> findById(UUID id);
    Card save(Card card);
    boolean existsById(UUID id);
    void deleteById(UUID id);
}
